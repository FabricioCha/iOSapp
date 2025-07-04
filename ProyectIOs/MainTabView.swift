//
//  MainTabView.swift
//  ProyectIOs
//
//  Created by Fabricio Chavez on 16/06/25.
//

import SwiftUI

// Enum para definir cada una de las pestañas en la barra de navegación principal.
enum Tab: String, CaseIterable {
    case home = "house.fill"
    case stats = "person.2.fill"
    case add = "plus.square.fill"
    case rankings = "trophy.fill"
    case profile = "person.fill"
}

// Esta es la vista principal que contiene la barra de pestañas y el contenido correspondiente.
struct MainTabView: View {
    
    // Obtenemos el ViewModel de autenticación del entorno.
    @EnvironmentObject var authViewModel: AuthViewModel
    
    // Creamos y mantenemos una instancia del HabitsViewModel.
    @StateObject private var habitsViewModel = HabitsViewModel()
    
    // La vista recibe el objeto del usuario que ha iniciado sesión.
    let user: User
    
    // Estado para controlar la pestaña actualmente seleccionada.
    @State private var selectedTab: Tab = .home
    // Estado para controlar la presentación de la vista modal para añadir un hábito.
    @State private var isAddingHabit = false
    // Estado para controlar el menú circular
    @State private var showCircularMenu = false
    // Estados para las nuevas funcionalidades
    @State private var showManageRoutines = false
    @State private var showCompetitions = false
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // El switch determina qué vista mostrar basándose en la pestaña seleccionada.
                switch selectedTab {
                case .home:
                    EnhancedHomeView()
                case .stats:
                    FriendsView()
                case .profile:
                    EnhancedProfileView()
                case .rankings:
                    RankingsView()
                case .add:
                    EmptyView()
                }
                
                Spacer() // Empuja la barra de pestañas hacia la parte inferior.
                
                // Nuestra barra de pestañas personalizada.
                CustomTabBar(selectedTab: $selectedTab)
            }
            .background(Color.appBackground.ignoresSafeArea())
            
            // Menú circular flotante
            CircularMenu(
                isShowing: $showCircularMenu,
                onCreateHabit: {
                    isAddingHabit = true
                },
                onManageRoutines: {
                    showManageRoutines = true
                },
                onCompetitions: {
                    showCompetitions = true
                }
            )
            
            // --- Lógica de Celebración de Insignias Reactivada ---
            // Si hay insignias recién ganadas, muestra la vista de celebración.
            if !authViewModel.newlyAwardedBadges.isEmpty {
                // Un fondo oscuro semitransparente para enfocar la atención.
                Color.black.opacity(0.6).ignoresSafeArea()
                    .onTapGesture {
                        // Permite cerrar la vista de celebración tocando el fondo.
                        authViewModel.clearNewlyAwardedBadges()
                    }
                
                // La vista que muestra la(s) insignia(s) desbloqueada(s).
                BadgeUnlockedView(
                    badges: authViewModel.newlyAwardedBadges,
                    onDismiss: {
                        authViewModel.clearNewlyAwardedBadges()
                    }
                )
                // Añadimos una transición para que la aparición sea más agradable.
                .transition(.scale.combined(with: .opacity))
            }
        }
        // Animamos la aparición y desaparición de la vista de celebración.
        .animation(.spring(response: 0.5, dampingFraction: 0.7), value: authViewModel.newlyAwardedBadges.isEmpty)
        // Cuando isAddingHabit se pone en 'true', se presenta la vista de creación de hábitos.
        .sheet(isPresented: $isAddingHabit) {
            OnboardingContainerView()
        }
        // Sheet para gestionar rutinas
        .sheet(isPresented: $showManageRoutines) {
            ManageRoutinesView()
        }
        // Sheet para competencias
        .sheet(isPresented: $showCompetitions) {
            CompetitionsView()
        }
        // Inyectamos los ViewModels en el entorno.
        .environmentObject(habitsViewModel)
    }
}

// MARK: - Preview

#Preview {
    // Para que la preview funcione, necesitamos simular un entorno completo.
    struct PreviewWrapper: View {
        // Creamos una instancia del AuthViewModel para la preview.
        private static var authViewModel: AuthViewModel = {
            let vm = AuthViewModel()
            // Simulamos que un usuario ha iniciado sesión.
            vm.currentUser = User(id: "1", name: "Usuario de Prueba", email: "preview@test.com") // <--- CORREGIDO
            // Simulamos que el usuario acaba de ganar una insignia.
            vm.newlyAwardedBadges = [
                Badge(id: "three_day_streak", name: "Constancia de Bronce", description: "¡Mantuviste una racha de 3 días seguidos!", iconName: "medal.fill")
            ]
            return vm
        }()
        
        var body: some View {
            if let user = Self.authViewModel.currentUser {
                MainTabView(user: user)
                    .environmentObject(Self.authViewModel)
            } else {
                Text("Error: No hay usuario para la preview.")
            }
        }
    }
    
    return PreviewWrapper()
}
