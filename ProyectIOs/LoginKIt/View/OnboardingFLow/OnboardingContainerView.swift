//
//  OnboardingContainerView.swift
//  ProyectIOs
//
//  Created by Fabricio Chavez on 16/06/25.
//

import SwiftUI

// Esta vista contiene el flujo completo para crear un nuevo hábito.
// Ha sido simplificada a 2 pasos para coincidir con la API.
struct OnboardingContainerView: View {
    
    // ViewModel para gestionar el estado del flujo de creación.
    @StateObject private var onboardingViewModel = OnboardingViewModel()
    
    // ViewModels del entorno para guardar el hábito y cerrar la vista.
    @EnvironmentObject var habitsViewModel: HabitsViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            VStack {
                // MARK: - Top Bar (Close Button)
                HStack {
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.headline)
                            .foregroundColor(Color.appTextSecondary)
                    }
                }
                .padding()
                
                // MARK: - Page Content
                // El TabView ahora solo tiene 2 páginas.
                TabView(selection: $onboardingViewModel.currentPage) {
                    Step1_HabitTypeView()
                        .tag(0)
                    
                    Step3_DefineHabitView()
                        .tag(1)
                }
                .tabViewStyle(.page(indexDisplayMode: .never)) // Oculta los puntos del paginador.
                
                // MARK: - Bottom Navigation
                HStack {
                    // Muestra el botón "Atrás" solo si no estamos en la primera página.
                    if onboardingViewModel.currentPage > 0 {
                        Button("Atrás") {
                            withAnimation {
                                onboardingViewModel.currentPage -= 1
                            }
                        }
                        .fontWeight(.semibold)
                        .foregroundColor(Color.appTextSecondary)
                    }
                    
                    Spacer()
                    
                    // El botón principal cambia su título y acción según la página actual.
                    GradientButton(
                        title: onboardingViewModel.currentPage == 1 ? "Finalizar" : "Siguiente",
                        icon: onboardingViewModel.currentPage == 1 ? "checkmark.circle" : "arrow.right"
                    ) {
                        if onboardingViewModel.currentPage == 1 {
                            saveHabit()
                            dismiss() // Cierra la vista modal al finalizar.
                        } else {
                            withAnimation {
                                onboardingViewModel.currentPage += 1
                            }
                        }
                    }
                    // El botón se deshabilita si no se ha cumplido la condición de la página actual.
                    .disabled(onboardingViewModel.isNextButtonDisabled)
                }
                .padding(30)
            }
        }
        .foregroundColor(Color.appTextPrimary)
        .environmentObject(onboardingViewModel) // Pasa el onboardingViewModel a las vistas hijas (Step1 y Step3).
    }
    
    /// Recopila los datos del OnboardingViewModel y llama a la función del HabitsViewModel para guardar el hábito.
    private func saveHabit() {
        // Nos aseguramos de que el usuario haya seleccionado un tipo de hábito.
        guard let habitType = onboardingViewModel.habitType else {
            print("Error: No se seleccionó un tipo de hábito.")
            return
        }
        
        // Llama a la función del HabitsViewModel que se comunica con la API.
        habitsViewModel.addHabit(
            nombre: onboardingViewModel.habitTitle,
            tipo: habitType,
            descripcion: nil, // La descripción es opcional y podría añadirse al formulario.
            metaObjetivo: onboardingViewModel.habitGoal
        )
    }
}

// Para la Preview, necesitamos inyectar los ViewModels necesarios.
#Preview {
    // Creamos una vista contenedora para simular el entorno.
    struct PreviewWrapper: View {
        var body: some View {
            // Un botón para presentar la hoja modal, simulando el flujo real.
            StatefulPreviewWrapper(false) { isPresented in
                Button("Crear Hábito") {
                    isPresented.wrappedValue = true
                }
                .sheet(isPresented: isPresented) {
                    OnboardingContainerView()
                        .environmentObject(HabitsViewModel()) // Inyectamos una instancia de HabitsViewModel
                }
            }
        }
    }
    
    // Una pequeña utilidad para manejar el estado de la presentación en la preview.
    struct StatefulPreviewWrapper<Value, Content: View>: View {
        @State var value: Value
        var content: (Binding<Value>) -> Content

        var body: some View {
            content($value)
        }

        init(_ value: Value, content: @escaping (Binding<Value>) -> Content) {
            _value = State(wrappedValue: value)
            self.content = content
        }
    }
    
    return PreviewWrapper()
}
