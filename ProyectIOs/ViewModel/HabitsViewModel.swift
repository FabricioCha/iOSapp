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
    
    @MainActor
    func loadHabits() async {
        if habits.isEmpty {
            isLoading = true
        }
        defer { isLoading = false }
        
        do {
            let dashboardData = try await networkService.fetchDashboardData()
            
            let habitsWithStats = dashboardData.habitsConEstadisticas
            // Mapeamos los hábitos para la UI.
            self.habits = habitsWithStats.map { Habit(id: $0.id, nombre: $0.nombre, tipo: $0.tipo, descripcion: $0.descripcion, meta_objetivo: $0.meta_objetivo) }
            
            // --- AJUSTE CLAVE ---
            // Mapeamos el estado de completado. Si `completadoHoy` es nulo, asumimos `false`.
            var statusDict: [String: Bool] = [:]
            for habit in habitsWithStats {
                // Usamos el operador "nil-coalescing" (??) para dar un valor por defecto.
                statusDict[String(habit.id)] = habit.completadoHoy ?? false
            }
            self.completionStatus = statusDict
            
        } catch {
            // Ahora, si hay un error, lo imprimimos para una mejor depuración.
            print("❌ Error al cargar los hábitos: \(error)")
            if let decodingError = error as? DecodingError {
                print("Detalles del error de decodificación: \(decodingError)")
            }
            self.alertItem = AlertItem.from(error: error)
        }
    }
    
    // --- El resto de las funciones (addHabit, deleteHabit, toggleCompletion) no necesitan cambios ---
    
    @MainActor
    func addHabit(nombre: String, tipo: ApiHabitType, descripcion: String?, metaObjetivoString: String?) {
        isLoading = true
        
        let metaObjetivoDouble = Double(metaObjetivoString ?? "")
        
        Task {
            defer { isLoading = false }
            do {
                _ = try await networkService.createHabit(nombre: nombre, tipo: tipo, descripcion: descripcion, metaObjetivo: metaObjetivoDouble)
                await loadHabits()
            } catch {
                self.alertItem = AlertItem.from(error: error)
            }
        }
    }
    
    @MainActor
    func deleteHabit(_ habit: Habit) {
        habits.removeAll { $0.id == habit.id }
        
        Task {
            do {
                try await networkService.deleteHabit(habitId: habit.id)
            } catch {
                 self.alertItem = AlertItem.from(error: error)
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
            valor_numerico: nil,
            es_recaida: nil
        )
        
        completionStatus[String(habit.id)] = true
        
        Task {
            do {
                try await networkService.logHabitProgress(log: logRequest)
                authViewModel.checkAwards()
            } catch {
                completionStatus[String(habit.id)] = false
                self.alertItem = AlertItem.from(error: error)
            }
        }
    }
}
