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
        
        print("[EnhancedStatsViewModel] Iniciando carga de estadísticas...")
        
        // Cargar datos secuencialmente para mejor manejo de errores
        var hasErrors = false
        var errorMessages: [String] = []
        
        // 1. Cargar dashboard data
        if let dashboardError = await loadDashboardStats() {
            print("[EnhancedStatsViewModel] Error en dashboard: \(dashboardError)")
            errorMessages.append("Dashboard: \(dashboardError)")
            hasErrors = true
        } else {
            print("[EnhancedStatsViewModel] Dashboard cargado exitosamente")
        }
        
        // 2. Cargar user stats (solo si dashboard fue exitoso o continuar de todos modos)
        if let userStatsError = await loadUserDetailedStats() {
            print("[EnhancedStatsViewModel] Error en user stats: \(userStatsError)")
            errorMessages.append("Estadísticas: \(userStatsError)")
            hasErrors = true
        } else {
            print("[EnhancedStatsViewModel] User stats cargado exitosamente")
        }
        
        // 3. Cargar activity log
        if let activityError = await loadActivityLog() {
            print("[EnhancedStatsViewModel] Error en activity log: \(activityError)")
            errorMessages.append("Actividades: \(activityError)")
            hasErrors = true
        } else {
            print("[EnhancedStatsViewModel] Activity log cargado exitosamente")
        }
        
        // Configurar mensaje de error final
        if hasErrors {
            if errorMessages.count == 3 {
                errorMessage = "Error al cargar estadísticas detalladas: \(errorMessages.first ?? "Error desconocido")"
            } else {
                errorMessage = "Algunos datos no se pudieron cargar: \(errorMessages.joined(separator: ", "))"
            }
        }
        
        print("[EnhancedStatsViewModel] Carga completada. Errores: \(hasErrors)")
        isLoading = false
    }
    
    // MARK: - Private Methods
    
    /// Carga estadísticas del dashboard
    private func loadDashboardStats() async -> String? {
        do {
            print("[EnhancedStatsViewModel] Solicitando datos del dashboard...")
            let dashboardData = try await networkService.fetchDashboardData()
            
            print("[EnhancedStatsViewModel] Dashboard data recibido: \(dashboardData.habitsConEstadisticas.count) hábitos")
            
            // Procesar datos del dashboard
            processDashboardData(dashboardData)
            
            return nil
        } catch let error as APIError {
            print("[EnhancedStatsViewModel] APIError en dashboard: \(error)")
            switch error {
            case .serverError(let statusCode, let description):
                return "Error del servidor (\(statusCode)): \(description)"
            case .requestFailed(let description):
                return "Fallo en la solicitud: \(description)"
            case .decodingError(let description):
                return "Error de datos: \(description)"
            default:
                return "Error de conexión: \(error.localizedDescription)"
            }
        } catch {
            print("[EnhancedStatsViewModel] Error genérico en dashboard: \(error)")
            return "Error al procesar la respuesta: \(error.localizedDescription)"
        }
    }
    
    /// Carga estadísticas detalladas del usuario
    private func loadUserDetailedStats() async -> String? {
        do {
            print("[EnhancedStatsViewModel] Solicitando estadísticas detalladas del usuario...")
            let userStats = try await networkService.fetchUserDetailedStats()
            
            print("[EnhancedStatsViewModel] User stats recibido: \(userStats.habitsWithStats.count) hábitos, racha actual: \(userStats.currentStreak)")
            
            // Procesar estadísticas detalladas
            processUserDetailedStats(userStats)
            
            return nil
        } catch let error as APIError {
            print("[EnhancedStatsViewModel] APIError en user stats: \(error)")
            switch error {
            case .serverError(let statusCode, let description):
                return "Error del servidor (\(statusCode)): \(description)"
            case .requestFailed(let description):
                return "Fallo en la solicitud: \(description)"
            case .decodingError(let description):
                return "Error de datos: \(description)"
            default:
                return "Error de conexión: \(error.localizedDescription)"
            }
        } catch {
            print("[EnhancedStatsViewModel] Error genérico en user stats: \(error)")
            return "Error al procesar la respuesta: \(error.localizedDescription)"
        }
    }
    
    /// Carga el registro de actividades
    private func loadActivityLog() async -> String? {
        do {
            print("[EnhancedStatsViewModel] Solicitando registro de actividades...")
            let activities = try await networkService.fetchActivityLog()
            
            print("[EnhancedStatsViewModel] Activity log recibido: \(activities.keys.count) días")
            
            // Procesar registro de actividades
            processActivityLog(activities)
            
            return nil
        } catch let error as APIError {
            print("[EnhancedStatsViewModel] APIError en activity log: \(error)")
            switch error {
            case .serverError(let statusCode, let description):
                return "Error del servidor (\(statusCode)): \(description)"
            case .requestFailed(let description):
                return "Fallo en la solicitud: \(description)"
            case .decodingError(let description):
                return "Error de datos: \(description)"
            default:
                return "Error de conexión: \(error.localizedDescription)"
            }
        } catch {
            print("[EnhancedStatsViewModel] Error genérico en activity log: \(error)")
            return "Error al procesar la respuesta: \(error.localizedDescription)"
        }
    }
    
    /// Procesa los datos del dashboard
    private func processDashboardData(_ dashboardData: DashboardData) {
        print("[EnhancedStatsViewModel] Procesando datos del dashboard...")
        
        habitsWithStats = dashboardData.habitsConEstadisticas
        
        // Calcular estadísticas generales
        totalHabits = habitsWithStats.count
        goodHabitsCount = habitsWithStats.filter { $0.tipo == .siNo || $0.tipo == .medibleNumerico }.count
        addictionsCount = habitsWithStats.filter { $0.tipo == .malHabito }.count
        
        // Calcular rachas desde los datos del dashboard
        currentStreak = habitsWithStats.map { $0.rachaActual }.max() ?? 0
        longestStreak = habitsWithStats.compactMap { $0.mejorRacha }.max() ?? currentStreak
        
        print("[EnhancedStatsViewModel] Dashboard procesado - Total: \(totalHabits), Buenos: \(goodHabitsCount), Adicciones: \(addictionsCount)")
        print("[EnhancedStatsViewModel] Rachas - Actual: \(currentStreak), Mejor: \(longestStreak)")
    }
    
    /// Procesa las estadísticas detalladas del usuario
    private func processUserDetailedStats(_ userStats: UserDetailedStatsModel) {
        print("[EnhancedStatsViewModel] Procesando estadísticas detalladas del usuario...")
        
        bestGoodHabitStreak = userStats.bestGoodHabitStreak
        bestAddictionStreak = userStats.bestAddictionStreak
        totalAchievements = userStats.totalAchievements
        joinDate = userStats.joinDate
        
        // Actualizar contadores desde la API de user stats (más precisos)
        totalHabits = userStats.goodHabitsCount + userStats.addictionsCount
        goodHabitsCount = userStats.goodHabitsCount
        addictionsCount = userStats.addictionsCount
        
        // Usar las rachas de la API de user stats (más precisas)
        longestStreak = userStats.longestStreak
        currentStreak = userStats.currentStreak
        
        print("[EnhancedStatsViewModel] User stats procesado - Mejor racha buena: \(bestGoodHabitStreak), Mejor racha adicción: \(bestAddictionStreak)")
        print("[EnhancedStatsViewModel] Logros: \(totalAchievements), Fecha ingreso: \(joinDate ?? "N/A")")
        print("[EnhancedStatsViewModel] Rachas actualizadas - Actual: \(currentStreak), Mejor: \(longestStreak)")
        
        // Si tenemos datos de hábitos desde user stats, combinarlos con dashboard
        if !userStats.habitsWithStats.isEmpty {
            print("[EnhancedStatsViewModel] Combinando \(userStats.habitsWithStats.count) hábitos de user stats")
            
            // Convertir los datos de user stats a HabitWithStats
            let userStatsHabits = userStats.habitsWithStats.map { $0.toHabitWithStats() }
            
            // Combinar con datos del dashboard si están disponibles
            if habitsWithStats.isEmpty {
                print("[EnhancedStatsViewModel] Usando solo datos de user stats")
                habitsWithStats = userStatsHabits
            } else {
                print("[EnhancedStatsViewModel] Combinando datos de dashboard y user stats")
                // Actualizar rachas actuales desde user stats
                habitsWithStats = habitsWithStats.map { dashboardHabit in
                    if let userStatsHabit = userStatsHabits.first(where: { $0.id == dashboardHabit.id }) {
                        var updatedHabit = dashboardHabit
                        return HabitWithStats(
                            id: updatedHabit.id,
                            nombre: updatedHabit.nombre,
                            tipo: updatedHabit.tipo,
                            descripcion: updatedHabit.descripcion,
                            metaObjetivo: updatedHabit.metaObjetivo,
                            fechaCreacion: updatedHabit.fechaCreacion,
                            rachaActual: userStatsHabit.rachaActual, // Usar racha de user stats
                            mejorRacha: updatedHabit.mejorRacha,
                            totalCompletados: updatedHabit.totalCompletados,
                            completadoHoy: updatedHabit.completadoHoy
                        )
                    }
                    return dashboardHabit
                }
            }
        } else {
            print("[EnhancedStatsViewModel] No hay hábitos en user stats para combinar")
        }
    }
    
    /// Procesa el registro de actividades
    private func processActivityLog(_ activities: ActivityLogResponse) {
        print("[EnhancedStatsViewModel] Procesando registro de actividades...")
        
        recentActivities = activities
        
        let totalCompletions = activities.values.reduce(0) { $0 + $1.completions }
        let totalRelapses = activities.values.filter { $0.hasRelapse }.count
        
        print("[EnhancedStatsViewModel] Activity log procesado - \(activities.count) días, \(totalCompletions) completados, \(totalRelapses) recaídas")
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

/// Modelo para hábitos con estadísticas desde la API de user stats
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
    
    /// Convierte HabitStatsFromAPI a HabitWithStats para compatibilidad
    func toHabitWithStats() -> HabitWithStats {
        let apiHabitType: ApiHabitType
        switch tipo {
        case "SI_NO":
            apiHabitType = .siNo
        case "MEDIBLE_NUMERICO":
            apiHabitType = .medibleNumerico
        case "MAL_HABITO":
            apiHabitType = .malHabito
        default:
            apiHabitType = .siNo // fallback
        }
        
        return HabitWithStats(
            id: id,
            nombre: nombre,
            tipo: apiHabitType,
            descripcion: nil,
            metaObjetivo: nil,
            fechaCreacion: "",
            rachaActual: rachaActual,
            mejorRacha: nil,
            totalCompletados: nil,
            completadoHoy: nil
        )
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