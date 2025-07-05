//
//  EnhancedStatsViewModel.swift
//  ProyectIOs
//
//  Created by Fabricio Chavez on Enhanced Stats ViewModel - Phase 2
//

import Foundation
import Combine

@MainActor
class EnhancedStatsViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Dashboard stats
    @Published var currentStreak = 0
    @Published var longestStreak = 0
    @Published var totalHabits = 0
    @Published var goodHabitsCount = 0
    @Published var addictionsCount = 0
    @Published var habitsWithStats: [HabitWithStats] = []
    
    // User detailed stats
    @Published var bestGoodHabitStreak = 0
    @Published var bestAddictionStreak = 0
    @Published var totalAchievements = 0
    @Published var joinDate: String?
    
    // Activity log
    @Published var recentActivities: ActivityLogResponse = [:]
    
    // MARK: - Private Properties
    private let networkService = NetworkService.shared
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init() {
        // Inicialización si es necesaria
    }
    
    // MARK: - Public Methods
    
    /// Carga todas las estadísticas desde los diferentes endpoints
    func loadAllStats() async {
        isLoading = true
        errorMessage = nil
        
        async let dashboardTask = loadDashboardStats()
        async let userStatsTask = loadUserDetailedStats()
        async let activityLogTask = loadActivityLog()
        
        // Ejecutar todas las tareas en paralelo
        let results = await (dashboardTask, userStatsTask, activityLogTask)
        
        // Procesar resultados
        if let dashboardError = results.0 {
            errorMessage = dashboardError
        }
        
        if let userStatsError = results.1 {
            if errorMessage == nil {
                errorMessage = userStatsError
            }
        }
        
        if let activityError = results.2 {
            if errorMessage == nil {
                errorMessage = activityError
            }
        }
        
        isLoading = false
    }
    
    // MARK: - Private Methods
    
    /// Carga estadísticas del dashboard
    private func loadDashboardStats() async -> String? {
        do {
            let dashboardData = try await networkService.fetchDashboardData()
            
            // Procesar datos del dashboard
            processDashboardData(dashboardData)
            
            return nil
        } catch {
            print("Error loading dashboard stats: \(error)")
            return "Error al cargar estadísticas del dashboard: \(error.localizedDescription)"
        }
    }
    
    /// Carga estadísticas detalladas del usuario
    private func loadUserDetailedStats() async -> String? {
        do {
            let userStats = try await networkService.fetchUserDetailedStats()
            
            // Procesar estadísticas detalladas
            processUserDetailedStats(userStats)
            
            return nil
        } catch {
            print("Error loading user detailed stats: \(error)")
            return "Error al cargar estadísticas detalladas: \(error.localizedDescription)"
        }
    }
    
    /// Carga el registro de actividades
    private func loadActivityLog() async -> String? {
        do {
            let activities = try await networkService.fetchActivityLog()
            
            // Procesar registro de actividades
            processActivityLog(activities)
            
            return nil
        } catch {
            print("Error loading activity log: \(error)")
            return "Error al cargar registro de actividades: \(error.localizedDescription)"
        }
    }
    
    /// Procesa los datos del dashboard
    private func processDashboardData(_ dashboardData: DashboardData) {
        habitsWithStats = dashboardData.habitsConEstadisticas
        
        // Calcular estadísticas generales
        totalHabits = habitsWithStats.count
        goodHabitsCount = habitsWithStats.filter { $0.tipo == .siNo || $0.tipo == .medibleNumerico }.count
        addictionsCount = habitsWithStats.filter { $0.tipo == .malHabito }.count
        
        // Calcular rachas
        currentStreak = habitsWithStats.map { $0.rachaActual }.max() ?? 0
        longestStreak = habitsWithStats.compactMap { $0.mejorRacha }.max() ?? 0
    }
    
    /// Procesa las estadísticas detalladas del usuario
    private func processUserDetailedStats(_ userStats: UserDetailedStatsModel) {
        bestGoodHabitStreak = userStats.bestGoodHabitStreak
        bestAddictionStreak = userStats.bestAddictionStreak
        totalAchievements = userStats.totalAchievements
        joinDate = userStats.joinDate
        
        // También actualizar contadores desde la API
        totalHabits = userStats.goodHabitsCount + userStats.addictionsCount
        goodHabitsCount = userStats.goodHabitsCount
        addictionsCount = userStats.addictionsCount
        
        // Actualizar rachas desde la API si son mayores
        longestStreak = max(longestStreak, userStats.longestStreak)
        currentStreak = max(currentStreak, userStats.currentStreak)
    }
    
    /// Procesa el registro de actividades
    private func processActivityLog(_ activities: ActivityLogResponse) {
        recentActivities = activities
    }
}

// MARK: - Supporting Models

/// Modelo para estadísticas detalladas del usuario (coincide con la API)
struct UserDetailedStatsModel: Codable {
    let userId: Int
    let totalHabitsCompleted: Int
    let longestStreak: Int
    let currentStreak: Int
    let totalAchievements: Int
    let joinDate: String
    let goodHabitsCount: Int
    let addictionsCount: Int
    let bestGoodHabitStreak: Int
    let bestAddictionStreak: Int
    let habitsWithStats: [HabitStatsFromAPI]
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case totalHabitsCompleted = "total_habits_completed"
        case longestStreak = "longest_streak"
        case currentStreak = "current_streak"
        case totalAchievements = "total_achievements"
        case joinDate = "join_date"
        case goodHabitsCount = "good_habits_count"
        case addictionsCount = "addictions_count"
        case bestGoodHabitStreak = "best_good_habit_streak"
        case bestAddictionStreak = "best_addiction_streak"
        case habitsWithStats = "habits_with_stats"
    }
}

/// Modelo para hábitos con estadísticas desde la API
struct HabitStatsFromAPI: Codable {
    let id: Int
    let nombre: String
    let tipo: String
    let rachaActual: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case nombre
        case tipo
        case rachaActual = "racha_actual"
    }
}

/// Modelo para el registro de actividades (coincide con la API)
struct ActivityLogModel: Codable {
    let completions: Int
    let hasRelapse: Bool
    
    enum CodingKeys: String, CodingKey {
        case completions
        case hasRelapse = "hasRelapse"
    }
}

/// Tipo para el diccionario de actividades por fecha
typealias ActivityLogResponse = [String: ActivityLogModel]