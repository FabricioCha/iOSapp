//
//  ProfileView.swift
//  ProyectIOs
//
//  Created by Fabricio Chavez on 16/06/25.
//

import SwiftUI

struct ProfileView: View {
    
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 30) {
                        
                        if let user = authViewModel.currentUser {
                            // Tarjeta de Información del Usuario
                            VStack(alignment: .leading, spacing: 15) {
                                HStack {
                                    Image(systemName: "person.fill")
                                    Text("Nombre")
                                        .font(.caption)
                                        .foregroundColor(Color.appTextSecondary)
                                }
                                Text(user.nombre)
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                
                                Divider()
                                
                                HStack {
                                    Image(systemName: "at")
                                    Text("Correo Electrónico")
                                        .font(.caption)
                                        .foregroundColor(Color.appTextSecondary)
                                }
                                Text(user.email)
                                    .font(.body)
                            }
                            .padding()
                            .background(Color.gray.opacity(0.15))
                            .cornerRadius(15)
                            .padding(.horizontal)
                            
                            // Navegación a Insignias (Restaurada)
                            // Este NavigationLink ahora apunta a la BadgesView funcional.
                            NavigationLink {
                                BadgesView()
                            } label: {
                                HStack {
                                    Image(systemName: "rosette")
                                        .font(.title2)
                                        .foregroundColor(.yellow)
                                    Text("Mis Insignias")
                                        .fontWeight(.semibold)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.gray)
                                }
                                .padding()
                                .background(Color.gray.opacity(0.15))
                                .cornerRadius(15)
                                .padding(.horizontal)
                            }
                        }
                        
                        Spacer()
                        
                        // Botón de Cerrar Sesión
                        GradientButton(
                            title: "Cerrar Sesión",
                            icon: "rectangle.portrait.and.arrow.right",
                            action: {
                                authViewModel.logout()
                            }
                        )
                        .padding(.bottom, 40)
                    }
                    .padding(.top)
                }
                .foregroundColor(Color.appTextPrimary)
                .navigationTitle("Perfil")
            }
        }
    }
}


#Preview {
    struct PreviewWrapper: View {
        private static let authViewModel: AuthViewModel = {
            let vm = AuthViewModel()
            vm.currentUser = User(
                id: "previewUser",
                nombre: "Usuario de Prueba",
                email: "preview@test.com",
                unlockedBadgeIDs: ["first_habit_completed"]
            )
            return vm
        }()
        
        var body: some View {
            ProfileView()
                .environmentObject(Self.authViewModel)
        }
    }
    
    return PreviewWrapper()
}
