//
//  EnhancedDashboardViewModel.swift
//  ProyectIOs
//
//  Created by Fabricio Chavez on Enhanced Dashboard - Phase 2
//

import SwiftUI
import Foundation

@MainActor
class EnhancedDashboardViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var isLoading = false
    @Published var alertItem: AlertItem?
    
    // Dashboard Statistics
    @Published var currentStreak: Int = 0
    @Published var longestStreak: Int = 0
    @Published var totalHabits: Int = 0
    @Published var goodHabits: Int = 0
    @Published var addictions: Int = 0
    @Published var habitsWithStats: [HabitWithStats] = []
    
    // MARK: - Private Properties
    
    private let networkService = NetworkService.shared
    
    // MARK: - Network Connectivity Check
    
    private func checkNetworkConnectivity() async -> Bool {
        do {
            let url = URL(string: "https://www.google.com")!
            let (_, response) = try await URLSession.shared.data(from: url)
            if let httpResponse = response as? HTTPURLResponse {
                return httpResponse.statusCode == 200
            }
            return false
        } catch {
            return false
        }
    }
    
    // MARK: - Public Methods
    
    func retryLoadDashboardData() async {
        await loadDashboardData()
    }
    
    func loadDashboardData() async {
        isLoading = true
        alertItem = nil
        
        // Verificar estado de autenticación
        let hasToken = KeychainService.shared.getToken() != nil
        print("[EnhancedDashboardViewModel] Token de autenticación disponible: \(hasToken)")
        
        // Verificar conectividad de red
        let hasConnectivity = await checkNetworkConnectivity()
        print("[EnhancedDashboardViewModel] Conectividad de red: \(hasConnectivity)")
        
        if !hasConnectivity {
            let error = APIError.requestFailed(description: "Sin conexión a internet")
            handleError(error)
            isLoading = false
            return
        }
        
        if !hasToken {
            let error = APIError.requestFailed(description: "Auth token no disponible")
            handleError(error)
            isLoading = false
            return
        }
        
        do {
            print("[EnhancedDashboardViewModel] Iniciando carga de datos del dashboard...")
            let dashboardData = try await networkService.fetchDashboardData()
            print("[EnhancedDashboardViewModel] Datos del dashboard recibidos exitosamente")
            print("[EnhancedDashboardViewModel] Número de hábitos: \(dashboardData.habitsConEstadisticas.count)")
            
            // Process dashboard data
            processDashboardData(dashboardData)
            
        } catch {
            print("[EnhancedDashboardViewModel] Error al cargar datos del dashboard: \(error)")
            if let apiError = error as? APIError {
                print("[EnhancedDashboardViewModel] Tipo de error API: \(apiError)")
            }
            handleError(error)
        }
        
        isLoading = false
    }
    
    // MARK: - Private Methods
    
    private func processDashboardData(_ data: DashboardData) {
        // Update habits with stats
        habitsWithStats = data.habitsConEstadisticas
        
        // Calculate statistics
        calculateStatistics()
    }
    
    private func calculateStatistics() {
        totalHabits = habitsWithStats.count
        
        // Count good habits vs addictions
        goodHabits = habitsWithStats.filter { $0.tipo == .siNo || $0.tipo == .medibleNumerico }.count
        addictions = habitsWithStats.filter { $0.tipo == .malHabito }.count
        
        // Calculate current streak (average of all habits)
        if !habitsWithStats.isEmpty {
            let totalStreak = habitsWithStats.map { $0.rachaActual }.reduce(0, +)
            currentStreak = totalStreak / habitsWithStats.count
        }
        
        // Calculate longest streak
        longestStreak = habitsWithStats.compactMap { $0.mejorRacha }.max() ?? 0
    }
    
    private func handleError(_ error: Error) {
        print("[EnhancedDashboardViewModel] Error loading dashboard data: \(error.localizedDescription)")
        
        let title = Text("Error")
        var message: Text
        
        if let apiError = error as? APIError {
            switch apiError {
            case .requestFailed(let description):
                if description.contains("Auth token") {
                    message = Text("Sesión expirada. Por favor, inicia sesión nuevamente.")
                } else {
                    message = Text("Error de conexión: \(description)")
                }
            case .serverError(let statusCode, let description):
                if statusCode == 401 {
                    message = Text("Sesión expirada. Por favor, inicia sesión nuevamente.")
                } else {
                    message = Text("Error del servidor (\(statusCode)): \(description)")
                }
            case .decodingError(let description):
                message = Text("Error procesando datos: \(description)")
            default:
                message = Text("No se pudieron cargar los datos del dashboard. Por favor, intenta de nuevo.")
            }
        } else {
            message = Text("No se pudieron cargar los datos del dashboard. Verifica tu conexión a internet.")
        }
        
        let dismissButton = Alert.Button.default(Text("OK"))
        alertItem = AlertItem(title: title, message: message, dismissButton: dismissButton)
    }
}

// MARK: - Supporting Models
// Using HabitWithStats from Dashboard.swift model