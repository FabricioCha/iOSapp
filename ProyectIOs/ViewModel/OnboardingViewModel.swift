//
//  OnboardingViewModel.swift
//  ProyectIOs
//
//  Created by Fabricio Chavez on 16/06/25.
//
import Foundation
import Combine

// ViewModel para gestionar el estado del flujo de creación de un nuevo hábito.
// Ha sido actualizado para un flujo de 2 pasos y para usar ApiHabitType.
class OnboardingViewModel: ObservableObject {
    
    // MARK: - Published Properties for User Input
    
    // La propiedad ahora es del tipo correcto: ApiHabitType
    @Published var habitType: ApiHabitType?
    
    // Estos campos ya no son necesarios porque la API no los soporta.
    // @Published var lifeArea: LifeArea? -> ELIMINADO
    // @Published var difficultyLevel: DifficultyLevel? -> ELIMINADO
    
    @Published var habitTitle: String = ""
    @Published var habitGoal: String = ""
    
    // Para controlar la página actual en nuestro flujo.
    @Published var currentPage: Int = 0
    
    // MARK: - Validation
    
    /// Propiedad computada que nos dice si podemos pasar a la siguiente página.
    /// La lógica ahora refleja el flujo de 2 pasos.
    var isNextButtonDisabled: Bool {
        switch currentPage {
        case 0:
            // Deshabilitado si no se ha elegido tipo de hábito.
            return habitType == nil
        case 1:
            // Deshabilitado si el título o la meta están vacíos.
            return habitTitle.isEmpty || habitGoal.isEmpty
        default:
            return false
        }
    }
    
    // MARK: - Methods
    
    /// Reinicia todos los campos a su estado inicial.
    func reset() {
        habitType = nil
        habitTitle = ""
        habitGoal = ""
        currentPage = 0
    }
}

