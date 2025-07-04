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
            
            // Mapeamos el estado de completado.
            var statusDict: [String: Bool] = [:]
            for habit in habitsWithStats {
                // Usamos String(habit.id) como clave porque el diccionario espera un String.
                statusDict[String(habit.id)] = habit.completadoHoy
            }
            self.completionStatus = statusDict
            
        } catch {
            self.alertItem = AlertItem.from(error: error)
        }
    }
    
    // --- FUNCIÓN CORREGIDA ---
    /// Añade un nuevo hábito, convirtiendo la meta de String a Double.
    @MainActor
    func addHabit(nombre: String, tipo: ApiHabitType, descripcion: String?, metaObjetivoString: String?) {
        isLoading = true
        
        // Convertimos el String de la meta a un Double. Si no es un número válido, será nil.
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
    
    // --- FUNCIÓN CORREGIDA ---
    /// Elimina un hábito, asegurándose de que el ID es Int.
    @MainActor
    func deleteHabit(_ habit: Habit) {
        habits.removeAll { $0.id == habit.id }
        
        Task {
            do {
                // habit.id ya es Int, por lo que la llamada es correcta.
                try await networkService.deleteHabit(habitId: habit.id)
            } catch {
                 self.alertItem = AlertItem.from(error: error)
                 await loadHabits()
            }
        }
    }
    
    // --- FUNCIÓN CORREGIDA ---
    /// Registra el progreso, asegurándose de que el ID es Int.
    @MainActor
    func toggleCompletion(for habit: Habit, authViewModel: AuthViewModel) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: Date())
        
        // Creamos el request con habit.id, que ya es Int.
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
