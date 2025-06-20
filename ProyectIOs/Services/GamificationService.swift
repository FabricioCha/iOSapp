//
//  GamificationService.swift
//  ProyectIOs
//
//  Created by Fabricio Chavez on 16/06/25.
//

import Foundation

// El servicio ahora solo contiene la lógica para comprobar si se cumplen los criterios de las insignias.
class GamificationService {
    
    // Cargamos todas las insignias posibles desde el JSON local.
    private let allBadges: [Badge]
    
    init() {
        // La mejor práctica es manejar la posible falla al cargar el archivo.
        do {
            guard let fileUrl = Bundle.main.url(forResource: "badges", withExtension: "json") else {
                throw APIError.requestFailed(description: "badges.json no encontrado")
            }
            let data = try Data(contentsOf: fileUrl)
            self.allBadges = try JSONDecoder().decode([Badge].self, from: data)
        } catch {
            print("Error fatal al cargar badges.json: \(error)")
            self.allBadges = []
        }
    }
    
    /// Comprueba las estadísticas del dashboard contra las insignias no desbloqueadas.
    /// - Parameters:
    ///   - dashboardData: Los datos más recientes del endpoint /api/dashboard.
    ///   - currentUser: El usuario actual, para saber qué insignias ya tiene.
    /// - Returns: Un array con las nuevas insignias que se acaban de ganar.
    func checkAndAwardBadges(dashboardData: DashboardData, for currentUser: User) -> [Badge] {
        var newlyAwardedBadges: [Badge] = []
        let unlockedIDs = Set(currentUser.unlockedBadgeIDs)
        
        let stats = dashboardData.habitsConEstadisticas
        
        // Obtenemos las estadísticas globales (usando la misma lógica que en StatsViewModel).
        let currentStreak = stats.map { $0.rachaActual }.max() ?? 0
        let hasAnyCompletion = stats.contains { $0.totalCompletados > 0 }
        
        // 1. Revisa la insignia "Pionero" (se otorga al crear el primer hábito).
        // Esta lógica ahora debe vivir en HabitsViewModel, después de crear un hábito con éxito.
        // Por simplicidad, la dejaremos fuera de este servicio por ahora.
        
        // 2. Revisa la insignia "Primer Paso" (primer hábito completado)
        let firstStepId = "first_habit_completed"
        if hasAnyCompletion && !unlockedIDs.contains(firstStepId) {
            if let badge = allBadges.first(where: { $0.id == firstStepId }) {
                newlyAwardedBadges.append(badge)
            }
        }
        
        // 3. Revisa las insignias de rachas
        let threeDayId = "three_day_streak"
        if currentStreak >= 3 && !unlockedIDs.contains(threeDayId) {
            if let badge = allBadges.first(where: { $0.id == threeDayId }) {
                newlyAwardedBadges.append(badge)
            }
        }
        
        let sevenDayId = "seven_day_streak"
        if currentStreak >= 7 && !unlockedIDs.contains(sevenDayId) {
            if let badge = allBadges.first(where: { $0.id == sevenDayId }) {
                newlyAwardedBadges.append(badge)
            }
        }
        
        return newlyAwardedBadges
    }
}
