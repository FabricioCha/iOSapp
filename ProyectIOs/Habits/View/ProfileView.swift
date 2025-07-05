//
//  ProfileView.swift
//  ProyectIOs
//
//  Created by Fabricio Chavez on 16/06/25.
//

import SwiftUI

struct ProfileView: View {
    
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var habitsViewModel: HabitsViewModel
    
    @StateObject private var viewModel = ProfileViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                
                if viewModel.isLoading && viewModel.userProfile == nil {
                    ProgressView()
                } else if let profile = viewModel.userProfile {
                    ScrollView {
                        VStack(spacing: 30) {
                            
                            VStack(alignment: .leading, spacing: 15) {
                                profileInfoRow(icon: "person.fill", label: "Nombre", value: profile.nombre)
                                Divider()
                                profileInfoRow(icon: "at", label: "Correo Electrónico", value: profile.email)
                                Divider()
                                profileInfoRow(icon: "person.badge.key.fill", label: "Rol", value: profile.rol?.capitalized ?? "Estándar")
                                Divider()
                                // --- SOLUCIÓN APLICADA AQUÍ ---
                                // Usamos '?? ""' para desenvolver de forma segura el valor opcional 'fechaCreacion'.
                                // Si 'profile.fechaCreacion' es nulo, se pasará un string vacío a la función formatDate.
                                profileInfoRow(icon: "calendar", label: "Miembro desde", value: formatDate(profile.fechaCreacion ?? ""))
                            }
                            .padding()
                            .background(Color.gray.opacity(0.15))
                            .cornerRadius(15)
                            .padding(.horizontal)
                            
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
                            
                            Spacer()
                            
                            GradientButton(
                                title: "Cerrar Sesión",
                                icon: "rectangle.portrait.and.arrow.right",
                                action: {
                                    authViewModel.logout(habitsViewModel: habitsViewModel)
                                }
                            )
                            .padding(.bottom, 40)
                        }
                        .padding(.top)
                    }
                    .refreshable {
                        await viewModel.fetchProfile()
                    }
                } else {
                    VStack {
                        Text("No se pudo cargar el perfil.")
                            .foregroundColor(Color.appTextSecondary)
                        Button("Reintentar") {
                            Task {
                                await viewModel.fetchProfile()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
            }
            .foregroundColor(Color.appTextPrimary)
            .navigationTitle("Perfil")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink {
                        EditProfileView(viewModel: viewModel)
                    } label: {
                        Image(systemName: "pencil")
                    }
                    .disabled(viewModel.userProfile == nil)
                }
            }
            .onAppear {
                if viewModel.userProfile == nil {
                    Task {
                        await viewModel.fetchProfile()
                    }
                }
            }
            .alert(item: $viewModel.alertItem) { alertItem in
                Alert(title: alertItem.title, message: alertItem.message, dismissButton: alertItem.dismissButton)
            }
        }
    }
    
    private func profileInfoRow(icon: String, label: String, value: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(Color.appTextSecondary)
                .frame(width: 25)
            VStack(alignment: .leading) {
                Text(label)
                    .font(.caption)
                    .foregroundColor(Color.appTextSecondary)
                Text(value)
                    .font(.body)
                    .fontWeight(.medium)
            }
        }
    }
    
    private func formatDate(_ dateString: String) -> String {
        // La función ahora maneja de forma segura el string vacío que podría recibir.
        guard !dateString.isEmpty else { return "No disponible" }
        
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: dateString) {
            return date.formatted(date: .long, time: .omitted)
        }
        
        let simpleFormatter = DateFormatter()
        simpleFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        if let date = simpleFormatter.date(from: dateString) {
            return date.formatted(date: .long, time: .omitted)
        }
        return dateString
    }
}


#Preview {
    struct PreviewWrapper: View {
        private static let authViewModel: AuthViewModel = {
            let vm = AuthViewModel()
            vm.currentUser = User(
                id: "1",
                name: "Usuario de Prueba",
                email: "preview@test.com",
                unlockedBadgeIDs: ["first_habit_completed"]
            )
            return vm
        }()
        
        var body: some View {
            ProfileView()
                .environmentObject(Self.authViewModel)
                .environmentObject(HabitsViewModel())
        }
    }
    
    return PreviewWrapper()
}
