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
    
    // MARK: - Public Methods
    
    func loadDashboardData() async {
        isLoading = true
        alertItem = nil
        
        do {
            let dashboardData = try await networkService.fetchDashboardData()
            
            // Process dashboard data
            processDashboardData(dashboardData)
            
        } catch {
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
        print("Error loading dashboard data: \(error.localizedDescription)")
        
        let title = Text("Error")
        let message = Text("No se pudieron cargar los datos del dashboard. Por favor, intenta de nuevo.")
        let dismissButton = Alert.Button.default(Text("OK"))
        
        alertItem = AlertItem(title: title, message: message, dismissButton: dismissButton)
    }
}

// MARK: - Supporting Models
// Using HabitWithStats from Dashboard.swift model