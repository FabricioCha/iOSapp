//
//  HabitsViewModel.swift
//  ProyectIOs
//
//  Created by Fabricio Chavez on 15/06/25.
//

import Foundation
import Combine

class HabitsViewModel: ObservableObject {
    
    private let networkService: NetworkService = .shared
    
    @Published var habits: [Habit] = []
    @Published var isLoading = false
    @Published var alertItem: AlertItem?
    
    @Published var completionStatus: [String: Bool] = [:]

    init() {}
    
    // MARK: - Lógica de Hábitos con API
    
    /// Carga los hábitos y el estado de completado desde el endpoint del dashboard.
    /// Ahora es una función async para funcionar con .refreshable.
    @MainActor
    func loadHabits() async {
        // Solo muestra el indicador de carga grande si la lista está vacía.
        if habits.isEmpty {
            isLoading = true
        }
        
        // Usamos defer para asegurarnos de que isLoading se ponga en false al final,
        // incluso si ocurre un error.
        defer { isLoading = false }
        
        do {
            let dashboardData = try await networkService.fetchDashboardData()
            
            // Actualizamos la lista de hábitos y el estado de completado.
            let habitsWithStats = dashboardData.habitsConEstadisticas
            self.habits = habitsWithStats.map { Habit(id: $0.id, nombre: $0.nombre, tipo: $0.tipo, descripcion: $0.descripcion, meta_objetivo: $0.meta_objetivo) }
            
            var statusDict: [String: Bool] = [:]
            for habit in habitsWithStats {
                statusDict[habit.id] = habit.completadoHoy
            }
            self.completionStatus = statusDict
            
        } catch {
            self.alertItem = AlertItem.from(error: error)
        }
    }
    
    @MainActor
    func addHabit(nombre: String, tipo: ApiHabitType, descripcion: String?, metaObjetivo: String?) {
        isLoading = true
        Task {
            defer { isLoading = false }
            do {
                _ = try await networkService.createHabit(nombre: nombre, tipo: tipo, descripcion: descripcion, metaObjetivo: metaObjetivo)
                // En lugar de llamar a la función async directamente, la envolvemos en una Task.
                await loadHabits()
            } catch {
                self.alertItem = AlertItem.from(error: error)
            }
        }
    }
    
    @MainActor
    func deleteHabit(_ habit: Habit) {
        // La UI se actualiza inmediatamente para una mejor experiencia.
        habits.removeAll { $0.id == habit.id }
        
        Task {
            do {
                try await networkService.deleteHabit(habitId: habit.id)
            } catch {
                 self.alertItem = AlertItem.from(error: error)
                 // Si falla, recargamos los hábitos para restaurar el que no se pudo borrar.
                 await loadHabits()
            }
        }
    }
    
    @MainActor
    func toggleCompletion(for habit: Habit, authViewModel: AuthViewModel) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: Date())
        
        let logRequest = HabitLogRequest(
            habito_id: habit.id,
            fecha_registro: dateString,
            valor_booleano: true,
            valor_numerico: nil
        )
        
        // Actualizamos la UI inmediatamente para dar feedback instantáneo.
        completionStatus[habit.id] = true
        
        Task {
            do {
                try await networkService.logHabitProgress(log: logRequest)
                authViewModel.checkAwards()
            } catch {
                // Si falla, revertimos el estado en la UI y mostramos una alerta.
                completionStatus[habit.id] = false
                self.alertItem = AlertItem.from(error: error)
            }
        }
    }
}
