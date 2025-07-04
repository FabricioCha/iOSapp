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
                
                let habitsWithStats = dashboardData.habitsConEstadisticas
                
                // --- LÓGICA CORREGIDA ---
                // Ahora, tanto la racha actual como la más larga se basan en `rachaActual`,
                // que es el único dato de racha que provee la API por cada hábito.
                // Buscamos la racha actual más alta entre todos los hábitos.
                self.currentStreak = habitsWithStats.map { $0.rachaActual }.max() ?? 0
                
                // Asumimos que la "Mejor Racha" global es la racha actual más alta que tienes.
                self.longestStreak = habitsWithStats.map { $0.rachaActual }.max() ?? 0
                
                // La API no provee un total de completados, por lo que esta estadística
                // no se puede calcular en el frontend. La dejamos en 0.
                self.totalCompletions = 0
                
                // La tasa de éxito tampoco se puede calcular sin el total de completados.
                self.overallCompletionRate = 0.0

            } catch {
                self.errorMessage = (error as? APIError)?.localizedDescription ?? "Error al cargar estadísticas."
            }
        }
    }
}
