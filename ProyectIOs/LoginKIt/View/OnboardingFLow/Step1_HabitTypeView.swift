//
//  Step1_HabitTypeView.swift
//  ProyectIOs
//
//  Created by Fabricio Chavez on 16/06/25.
//

import SwiftUI

struct Step1_HabitTypeView: View {
    
    // Obtenemos el ViewModel del entorno para poder actualizarlo.
    @EnvironmentObject var onboardingViewModel: OnboardingViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 30) {
            Text("¿Qué tipo de hábito quieres construir?")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            // Iteramos sobre todos los casos de nuestro nuevo enum ApiHabitType.
            ForEach(ApiHabitType.allCases, id: \.self) { type in
                SelectionCard(
                    title: type.displayName, // Usamos el nombre legible del enum.
                    iconName: iconForHabitType(type), // Usamos un ícono para cada tipo.
                    isSelected: onboardingViewModel.habitType == type // La comparación ahora es correcta.
                )
                .onTapGesture {
                    onboardingViewModel.habitType = type
                }
            }
            
            Spacer()
        }
        .padding(.top, 20)
    }
    
    /// Función de ayuda para devolver un ícono específico para cada tipo de hábito.
    private func iconForHabitType(_ type: ApiHabitType) -> String {
        switch type {
        case .siNo:
            return "checkmark.circle.fill"
        case .medibleNumerico:
            return "number.circle.fill"
        case .malHabito:
            return "xmark.circle.fill"
        }
    }
}

// La vista reutilizable para las tarjetas de selección no necesita cambios.
struct SelectionCard: View {
    let title: String
    let iconName: String
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: 20) {
            Image(systemName: iconName)
                .font(.largeTitle)
                .foregroundColor(isSelected ? Color.appPrimaryAction : Color.appTextSecondary)
            
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
            
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.gray.opacity(0.15))
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(isSelected ? Color.appPrimaryAction : Color.clear, lineWidth: 2)
        )
        .padding(.horizontal)
    }
}


#Preview {
    ZStack {
        Color.appBackground.ignoresSafeArea()
        Step1_HabitTypeView()
            .environmentObject(OnboardingViewModel())
            .foregroundColor(.white)
    }
}
