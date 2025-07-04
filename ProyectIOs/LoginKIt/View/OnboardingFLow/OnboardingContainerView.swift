//
//  OnboardingContainerView.swift
//  ProyectIOs
//
//  Created by Fabricio Chavez on 16/06/25.
//

import SwiftUI

// Vista que contiene el flujo de creación de hábitos.
struct OnboardingContainerView: View {
    
    @StateObject private var onboardingViewModel = OnboardingViewModel()
    @EnvironmentObject var habitsViewModel: HabitsViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            VStack {
                // ... (Top Bar sin cambios)
                
                TabView(selection: $onboardingViewModel.currentPage) {
                    Step1_HabitTypeView()
                        .tag(0)
                    
                    Step3_DefineHabitView()
                        .tag(1)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                // ... (Bottom Navigation sin cambios)
                HStack {
                    if onboardingViewModel.currentPage > 0 {
                        Button("Atrás") {
                            withAnimation { onboardingViewModel.currentPage -= 1 }
                        }
                    }
                    
                    Spacer()
                    
                    GradientButton(
                        title: onboardingViewModel.currentPage == 1 ? "Finalizar" : "Siguiente",
                        icon: onboardingViewModel.currentPage == 1 ? "checkmark.circle" : "arrow.right"
                    ) {
                        if onboardingViewModel.currentPage == 1 {
                            saveHabit()
                            dismiss()
                        } else {
                            withAnimation { onboardingViewModel.currentPage += 1 }
                        }
                    }
                    .disabled(onboardingViewModel.isNextButtonDisabled)
                }
                .padding(30)
            }
        }
        .foregroundColor(Color.appTextPrimary)
        .environmentObject(onboardingViewModel)
    }
    
    // --- FUNCIÓN CORREGIDA ---
    private func saveHabit() {
        guard let habitType = onboardingViewModel.habitType else { return }
        
        // Llamamos a la función addHabit con el tipo de dato correcto para la meta (String?).
        // La conversión a Double se hará dentro del HabitsViewModel.
        habitsViewModel.addHabit(
            nombre: onboardingViewModel.habitTitle,
            tipo: habitType,
            descripcion: nil,
            metaObjetivoString: onboardingViewModel.habitGoal
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
