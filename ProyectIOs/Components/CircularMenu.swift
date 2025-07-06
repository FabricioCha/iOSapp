//
//  CircularMenu.swift
//  ProyectIOs
//
//  Created by Fabricio Chavez on 05/01/25.
//

import SwiftUI

struct CircularMenu: View {
    @Binding var isShowing: Bool
    let onCreateHabit: () -> Void
    let onManageRoutines: () -> Void
    let onCompetitions: () -> Void
    
    @State private var animateButtons = false
    
    var body: some View {
        ZStack {
            // Fondo semitransparente
            if isShowing {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        closeMenu()
                    }
                    .transition(.opacity)
            }
            
            VStack {
                Spacer()
                
                HStack {
                    Spacer()
                    
                    ZStack {
                        // Botón principal (siempre visible)
                        Button {
                            if isShowing {
                                closeMenu()
                            } else {
                                openMenu()
                            }
                        } label: {
                            Image(systemName: isShowing ? "xmark" : "plus")
                                .font(.largeTitle)
                                .foregroundColor(.white)
                                .padding(15)
                                .background(Color.appPrimaryAction)
                                .clipShape(Circle())
                                .shadow(color: .appPrimaryAction.opacity(0.5), radius: 5, y: 3)
                                .rotationEffect(.degrees(isShowing ? 45 : 0))
                        }
                        .offset(y: -25) // Elevamos el botón para que destaque
                        
                        // Opciones del menú circular
                        if isShowing {
                            // Crear Hábitos (arriba)
                            CircularMenuButton(
                                icon: "plus.circle.fill",
                                title: "Crear Hábitos",
                                color: .green,
                                offset: CGSize(width: 0, height: -120),
                                delay: 0.1,
                                isVisible: animateButtons
                            ) {
                                closeMenu()
                                onCreateHabit()
                            }
                            
                            // Gestionar Rutinas (arriba izquierda)
                            CircularMenuButton(
                                icon: "calendar.circle.fill",
                                title: "Gestionar Rutinas",
                                color: .blue,
                                offset: CGSize(width: -85, height: -85),
                                delay: 0.2,
                                isVisible: animateButtons
                            ) {
                                closeMenu()
                                onManageRoutines()
                            }
                            
                            // Competencias (arriba derecha)
                            CircularMenuButton(
                                icon: "trophy.circle.fill",
                                title: "Competencias",
                                color: .orange,
                                offset: CGSize(width: 85, height: -85),
                                delay: 0.3,
                                isVisible: animateButtons
                            ) {
                                closeMenu()
                                onCompetitions()
                            }
                        }
                    }
                    
                    Spacer()
                }
                .padding(.bottom, 25) // Posicionar en el espacio de la tab bar
            }
        }
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isShowing)
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: animateButtons)
    }
    
    private func openMenu() {
        isShowing = true
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
            animateButtons = true
        }
    }
    
    private func closeMenu() {
        animateButtons = false
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8).delay(0.1)) {
            isShowing = false
        }
    }
}

struct CircularMenuButton: View {
    let icon: String
    let title: String
    let color: Color
    let offset: CGSize
    let delay: Double
    let isVisible: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding(12)
                    .background(color)
                    .clipShape(Circle())
                    .shadow(color: color.opacity(0.4), radius: 4, y: 2)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.black.opacity(0.7))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .offset(offset)
        .scaleEffect(isVisible ? 1 : 0)
        .opacity(isVisible ? 1 : 0)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(delay), value: isVisible)
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var isShowing = false
        
        var body: some View {
            ZStack {
                Color.gray.opacity(0.2).ignoresSafeArea()
                
                CircularMenu(
                    isShowing: $isShowing,
                    onCreateHabit: { print("Crear Hábito") },
                    onManageRoutines: { print("Gestionar Rutinas") },
                    onCompetitions: { print("Competencias") }
                )
            }
        }
    }
    
    return PreviewWrapper()
}