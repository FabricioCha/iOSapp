//
//  RoutinesViewModel.swift
//  ProyectIOs
//
//  Created by Trae AI on 2024.
//

import Foundation
import SwiftUI

@MainActor
class RoutinesViewModel: ObservableObject {
    
    @Published var routines: [Routine] = []
    @Published var selectedRoutine: RoutineDetails?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showError = false
    
    // Estados para crear/editar rutinas
    @Published var showCreateRoutineSheet = false
    @Published var showEditRoutineSheet = false
    @Published var routineName = ""
    @Published var routineDescription = ""
    
    // Estados para gestión de hábitos
    @Published var showAddHabitSheet = false
    @Published var availableHabits: [Habit] = []
    @Published var selectedHabits: Set<Int> = []
    
    private let routinesService = RoutinesService.shared
    private let networkService = NetworkService.shared
    
    init() {
        loadRoutines()
    }
    
    // MARK: - Routines Management
    
    func loadRoutines() {
        Task {
            isLoading = true
            do {
                let response = try await routinesService.fetchRoutines()
                routines = response.routines
            } catch {
                handleError(error)
            }
            isLoading = false
        }
    }
    
    func loadRoutineDetails(routineId: Int) {
        Task {
            isLoading = true
            do {
                selectedRoutine = try await routinesService.fetchRoutineDetails(routineId: routineId)
            } catch {
                handleError(error)
            }
            isLoading = false
        }
    }
    
    func createRoutine() async {
        guard !routineName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "El nombre de la rutina es requerido"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let newRoutine = try await routinesService.createRoutine(
                nombre: routineName.trimmingCharacters(in: .whitespacesAndNewlines),
                descripcion: routineDescription.isEmpty ? nil : routineDescription.trimmingCharacters(in: .whitespacesAndNewlines)
            )
            
            await MainActor.run {
                routines.insert(newRoutine, at: 0)
                clearForm()
                showCreateRoutineSheet = false
                isLoading = false
            }
        } catch {
            await MainActor.run {
                handleError(error)
                isLoading = false
            }
        }
    }
    
    func updateRoutine(_ routine: Routine) async {
        guard !routineName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "El nombre de la rutina es requerido"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            try await routinesService.updateRoutine(
                routineId: routine.id,
                nombre: routineName.trimmingCharacters(in: .whitespacesAndNewlines),
                descripcion: routineDescription.isEmpty ? nil : routineDescription.trimmingCharacters(in: .whitespacesAndNewlines)
            )
            
            await MainActor.run {
                if let index = routines.firstIndex(where: { $0.id == routine.id }) {
                    routines[index] = Routine(
                        id: routine.id,
                        usuarioId: routine.usuarioId,
                        nombre: routineName.trimmingCharacters(in: .whitespacesAndNewlines),
                        descripcion: routineDescription.isEmpty ? nil : routineDescription.trimmingCharacters(in: .whitespacesAndNewlines),
                        fechaCreacion: routine.fechaCreacion
                    )
                }
                clearForm()
                showEditRoutineSheet = false
                isLoading = false
            }
        } catch {
            await MainActor.run {
                handleError(error)
                isLoading = false
            }
        }
    }
    
    func deleteRoutine(routineId: Int) {
        Task {
            isLoading = true
            do {
                _ = try await routinesService.deleteRoutine(routineId: routineId)
                
                // Remover de la lista local
                routines.removeAll { $0.id == routineId }
                
                // Limpiar selección si es la rutina eliminada
                if selectedRoutine?.id == routineId {
                    selectedRoutine = nil
                }
                
            } catch {
                handleError(error)
            }
            isLoading = false
        }
    }
    
    func deleteRoutineAndDismiss(routineId: Int) async {
        isLoading = true
        do {
            _ = try await routinesService.deleteRoutine(routineId: routineId)
            
            // Remover de la lista local
            await MainActor.run {
                routines.removeAll { $0.id == routineId }
                
                // Limpiar selección si es la rutina eliminada
                if selectedRoutine?.id == routineId {
                    selectedRoutine = nil
                }
            }
            
        } catch {
            await MainActor.run {
                handleError(error)
            }
        }
        await MainActor.run {
            isLoading = false
        }
    }
    
    // MARK: - Habit Management
    
    func loadAvailableHabits() {
        Task {
            do {
                availableHabits = try await networkService.fetchHabits()
            } catch {
                handleError(error)
            }
        }
    }
    
    func addHabitToRoutine(routineId: Int, habitId: Int) {
        Task {
            await MainActor.run {
                isLoading = true
            }
            
            do {
                _ = try await routinesService.addHabitToRoutine(routineId: routineId, habitId: habitId)
                
                // Recargar detalles de la rutina
                loadRoutineDetails(routineId: routineId)
                
            } catch {
                await MainActor.run {
                    handleError(error)
                }
            }
            
            await MainActor.run {
                isLoading = false
            }
        }
    }
    
    func removeHabitFromRoutine(routineId: Int, habitId: Int) {
        Task {
            await MainActor.run {
                isLoading = true
            }
            
            do {
                _ = try await routinesService.removeHabitFromRoutine(routineId: routineId, habitId: habitId)
                
                // Actualizar detalles localmente
                await MainActor.run {
                    if var details = selectedRoutine, details.id == routineId {
                        details = RoutineDetails(
                            id: details.id,
                            nombre: details.nombre,
                            descripcion: details.descripcion,
                            habits: details.habits.filter { $0.id != habitId }
                        )
                        selectedRoutine = details
                    }
                }
                
            } catch {
                await MainActor.run {
                    handleError(error)
                }
            }
            
            await MainActor.run {
                isLoading = false
            }
        }
    }
    
    func addSelectedHabitsToRoutine(routineId: Int) {
        Task {
            await MainActor.run {
                isLoading = true
            }
            
            let habitsToAdd = Array(selectedHabits)
            
            for habitId in habitsToAdd {
                do {
                    _ = try await routinesService.addHabitToRoutine(routineId: routineId, habitId: habitId)
                } catch {
                    await MainActor.run {
                        handleError(error)
                    }
                    break
                }
            }
            
            // Limpiar selección y recargar detalles
            await MainActor.run {
                selectedHabits.removeAll()
                showAddHabitSheet = false
                isLoading = false
            }
            
            loadRoutineDetails(routineId: routineId)
        }
    }
    
    // MARK: - Form Management
    
    func prepareForCreating() {
        clearForm()
        showCreateRoutineSheet = true
    }
    
    func prepareForEdit(_ routine: Routine) {
        selectedRoutine = RoutineDetails(
            id: routine.id,
            nombre: routine.nombre,
            descripcion: routine.descripcion,
            habits: []
        )
        routineName = routine.nombre
        routineDescription = routine.descripcion ?? ""
        showEditRoutineSheet = true
    }
    
    func prepareForAddingHabits(routineId: Int) {
        selectedHabits.removeAll()
        loadAvailableHabits()
        showAddHabitSheet = true
    }
    
    private func clearForm() {
        routineName = ""
        routineDescription = ""
    }
    
    // MARK: - Error Handling
    
    private func handleError(_ error: Error) {
        if let apiError = error as? APIError {
            switch apiError {
            case .serverError(let statusCode, let description):
                switch statusCode {
                case 401:
                    errorMessage = "Sesión expirada. Por favor, inicia sesión nuevamente."
                case 400:
                    errorMessage = "Datos inválidos. Verifica la información ingresada."
                case 404:
                    errorMessage = "Rutina no encontrada."
                case 409:
                    errorMessage = "Ya existe una rutina con ese nombre."
                default:
                    errorMessage = description
                }
            case .requestFailed(let description):
                errorMessage = description
            case .decodingError(let description):
                errorMessage = "Error procesando datos: \(description)"
            case .invalidResponse:
                errorMessage = "Respuesta inválida del servidor."
            case .invalidURL:
                errorMessage = "URL inválida."
            case .encodingError:
                errorMessage = "Error al enviar datos."
            case .unknownError:
                errorMessage = "Error desconocido."
            }
        } else {
            errorMessage = "Error de conexión: \(error.localizedDescription)"
        }
        showError = true
    }
    
    private func showErrorMessage(_ message: String) {
        errorMessage = message
        showError = true
    }
    
    // MARK: - Computed Properties
    
    var hasRoutines: Bool {
        !routines.isEmpty
    }
    
    var availableHabitsForRoutine: [Habit] {
        guard let selectedRoutine = selectedRoutine else { return availableHabits }
        let routineHabitIds = Set(selectedRoutine.habits.map { $0.id })
        return availableHabits.filter { !routineHabitIds.contains($0.id) }
    }
}