//
//  StatsViewModel.swift
//  ProyectIOs
//
//  Created by Fabricio Chavez on 16/06/25.
//

import Foundation

// Este ViewModel ahora solo se encarga de pedir los datos del dashboard y presentarlos.
class StatsViewModel: ObservableObject {
    
    private let networkService: NetworkService = .shared
    
    // Propiedades para las estadísticas globales.
    @Published var overallCompletionRate: Double = 0
    @Published var totalCompletions: Int = 0
    @Published var longestStreak: Int = 0
    @Published var currentStreak: Int = 0
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    @MainActor
    func fetchGlobalStats() {
        isLoading = true
        errorMessage = nil
        
        Task {
            defer { isLoading = false }
            do {
                // Hacemos la llamada al endpoint del dashboard.
                let dashboardData = try await networkService.fetchDashboardData()
                
                // Aquí, procesaríamos la respuesta.
                // La API que describiste devuelve hábitos individuales con sus rachas.
                // Para obtener una racha global, necesitaríamos sumarizar los datos.
                // Por ahora, encontraremos la racha más larga y la racha actual más alta
                // entre todos los hábitos como un ejemplo.
                
                let habitsWithStats = dashboardData.habitsConEstadisticas
                
                self.currentStreak = habitsWithStats.map { $0.rachaActual }.max() ?? 0
                self.longestStreak = habitsWithStats.map { $0.mejorRacha }.max() ?? 0
                self.totalCompletions = habitsWithStats.map { $0.totalCompletados }.reduce(0, +)
                
                // El cálculo de "Tasa de Éxito" global requeriría más información del backend,
                // como desde cuándo se está siguiendo cada hábito. Lo dejaremos en 0 por ahora.
                self.overallCompletionRate = 0.0

            } catch {
                self.errorMessage = (error as? APIError)?.localizedDescription ?? "Error al cargar estadísticas."
            }
        }
    }
}
