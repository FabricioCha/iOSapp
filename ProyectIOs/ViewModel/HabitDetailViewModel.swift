//
//  HabitDetailViewModel.swift
//  ProyectIOs
//
//  Created by Fabricio Chavez on 20/06/25.
//

import Foundation

@MainActor
class HabitDetailViewModel: ObservableObject {
    
    @Published var habit: Habit
    @Published var completedDates: Set<Date> = []
    @Published var isLoading = false
    @Published var alertItem: AlertItem?
    
    private let networkService = NetworkService.shared
    private let authViewModel: AuthViewModel
    
    // Formateador para convertir las fechas de la API (String) a objetos Date.
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(secondsFromGMT: 0) // Es crucial para la consistencia.
        return formatter
    }()
    
    init(habit: Habit, authViewModel: AuthViewModel) {
        self.habit = habit
        self.authViewModel = authViewModel
    }
    
    func fetchHabitLogs() async {
        isLoading = true
        do {
            let logResponse = try await networkService.fetchLogs(for: habit.id)
            // Convertimos los strings de fecha en objetos Date y los añadimos a nuestro Set.
            self.completedDates = Set(logResponse.completionDates.compactMap { dateString in
                dateFormatter.date(from: dateString)
            })
        } catch {
            self.alertItem = AlertItem.from(error: error)
        }
        isLoading = false
    }
    
    var isCompletedToday: Bool {
        // Comprueba si el día de hoy está en el set de fechas completadas.
        guard let today = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: Date()) else {
            return false
        }
        return completedDates.contains(today)
    }
    
    func toggleCompletionForToday() {
        let dateString = dateFormatter.string(from: Date())
        let logRequest = HabitLogRequest(
            habito_id: habit.id,
            fecha_registro: dateString,
            valor_booleano: true,
            valor_numerico: nil
        )
        
        // Actualización optimista de la UI
        if let today = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: Date()) {
            completedDates.insert(today)
        }
        
        Task {
            do {
                try await networkService.logHabitProgress(log: logRequest)
                // Después de un log exitoso, comprobamos si se ganaron insignias.
                authViewModel.checkAwards()
            } catch {
                // Si falla, revertimos el cambio y mostramos una alerta.
                if let today = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: Date()) {
                    completedDates.remove(today)
                }
                self.alertItem = AlertItem.from(error: error)
            }
        }
    }
}
