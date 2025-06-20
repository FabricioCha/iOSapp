//
//  Step3_DefineHabitView.swift
//  ProyectIOs
//
//  Created by Fabricio Chavez on 16/06/25.
//

import SwiftUI

struct Step3_DefineHabitView: View {
    
    // Obtenemos el ViewModel del entorno.
    @EnvironmentObject var onboardingViewModel: OnboardingViewModel
    
    // @FocusState nos permite controlar programáticamente qué campo de texto está activo.
    @FocusState private var isTitleFieldFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 30) {
            // 1. Título de la pregunta
            Text("¿Cuál es tu objetivo?")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            Text("Dale un nombre a tu hábito y define una meta clara y medible.")
                .font(.callout)
                .foregroundStyle(Color.appTextSecondary)
                .padding(.horizontal)
            
            // 2. Campos de texto
            VStack(spacing: 20) {
                // Usamos nuestro componente CustomTF reutilizable.
                CustomTF(sfIcon: "pencil", hint: "Ej: Leer un libro", value: $onboardingViewModel.habitTitle)
                    .focused($isTitleFieldFocused) // Vinculamos el foco a nuestra variable de estado.
                
                CustomTF(sfIcon: "target", hint: "Meta: Ej: 15 minutos al día", value: $onboardingViewModel.habitGoal)
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding(.top, 20)
        // Hacemos que el primer campo de texto se active automáticamente cuando aparece la vista.
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isTitleFieldFocused = true
            }
        }
    }
}


#Preview {
    ZStack {
        Color.appBackground.ignoresSafeArea()
        Step3_DefineHabitView()
            .environmentObject(OnboardingViewModel())
            .foregroundColor(.white)
    }
}
