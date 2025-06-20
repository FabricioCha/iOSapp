//
//  BadgeUnlockedView.swift
//  ProyectIOs
//
//  Created by Fabricio Chavez on 17/06/25.
//

import SwiftUI

// Una vista modal para celebrar cuando el usuario desbloquea una o más insignias.
struct BadgeUnlockedView: View {
    
    // Las insignias que se acaban de ganar.
    let badges: [Badge]
    
    // La acción para cerrar la vista.
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            
            Text("¡Nuevo Logro!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(Color.appPrimaryAction)
            
            Text(badges.count > 1 ? "¡Has desbloqueado nuevas insignias!" : "¡Has desbloqueado una nueva insignia!")
                .font(.headline)
                .multilineTextAlignment(.center)
                .foregroundColor(Color.appTextSecondary)
            
            // Usamos un ScrollView por si se desbloquean varias insignias a la vez.
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(badges) { badge in
                        VStack(spacing: 10) {
                            Image(systemName: badge.iconName)
                                .font(.system(size: 60))
                                .foregroundColor(Color.appPrimaryAction)
                                .padding(25)
                                .background(
                                    Circle().fill(Color.appPrimaryAction.opacity(0.2))
                                )
                                .overlay(
                                    Circle().stroke(Color.appPrimaryAction, lineWidth: 2)
                                )
                            
                            Text(badge.name)
                                .font(.title3)
                                .fontWeight(.bold)
                            
                            Text(badge.description)
                                .font(.caption)
                                .multilineTextAlignment(.center)
                                .foregroundColor(Color.appTextSecondary)
                        }
                        .frame(width: 200) // Ancho fijo para cada tarjeta de insignia.
                    }
                }
                .padding()
            }
            
            GradientButton(title: "¡Genial!", icon: "checkmark", action: onDismiss)
        }
        .padding(30)
        .background(Color.appBackground)
        .cornerRadius(25)
        .shadow(radius: 10)
        .padding(40) // Padding exterior para que no ocupe toda la pantalla.
    }
}


#Preview {
    // Creamos datos de muestra para la preview.
    let sampleBadges: [Badge] = [
        Badge(id: "three_day_streak", name: "Constancia de Bronce", description: "¡Mantuviste una racha de 3 días seguidos!", iconName: "medal.fill")
    ]
    
    // Usamos un ZStack para simular cómo se vería sobre otra vista.
    return ZStack {
        Color.gray.opacity(0.4).ignoresSafeArea()
        BadgeUnlockedView(badges: sampleBadges, onDismiss: { print("Cerrar vista") })
            .foregroundColor(Color.appTextPrimary)
    }
}

