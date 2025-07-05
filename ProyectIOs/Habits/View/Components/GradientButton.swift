//
//  GradientButton.swift
//  ProyectIOs
//
//  Created by Fabricio Chavez on Enhanced Profile - Phase 2
//

import SwiftUI

struct GradientButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    let isDestructive: Bool
    let isDisabled: Bool
    
    init(
        title: String,
        icon: String? = nil,
        isDestructive: Bool = false,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.isDestructive = isDestructive
        self.isDisabled = isDisabled
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.title3)
                }
                
                Text(title)
                    .font(.callout)
                    .fontWeight(.semibold)
            }
            .foregroundColor(isDestructive ? .white : Color.appTextPrimary)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                Group {
                    if isDestructive {
                        LinearGradient(
                            colors: [.red, .red.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    } else {
                        LinearGradient(
                            colors: [Color.appPrimaryAction, Color.appPrimaryAction.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    }
                }
            )
            .cornerRadius(16)
            .opacity(isDisabled ? 0.6 : 1.0)
        }
        .disabled(isDisabled)
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        GradientButton(
            title: "Botón Principal",
            icon: "checkmark.circle.fill"
        ) {
            print("Botón principal presionado")
        }
        
        GradientButton(
            title: "Botón Destructivo",
            icon: "trash.fill",
            isDestructive: true
        ) {
            print("Botón destructivo presionado")
        }
        
        GradientButton(
            title: "Botón Deshabilitado",
            icon: "lock.fill",
            isDisabled: true
        ) {
            print("Este botón está deshabilitado")
        }
    }
    .padding()
    .background(Color.appBackground)
}