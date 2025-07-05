//
//  UserManagementView.swift
//  ProyectIOs
//
//  Created by Fabricio Chavez on 04/07/25.
//

import SwiftUI

struct UserManagementView: View {
    let userId: Int
    @StateObject private var viewModel = UserManagementViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()
                
                if viewModel.isLoading {
                    ProgressView("Cargando detalles del usuario...")
                        .foregroundColor(.appTextPrimary)
                } else {
                    ScrollView {
                        VStack(spacing: 24) {
                            if let userDetails = viewModel.userDetails {
                                userDetailsForm(userDetails)
                            } else {
                                Text("No se pudieron cargar los detalles del usuario")
                                    .foregroundColor(.appTextSecondary)
                                    .padding()
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Gestión de Usuario")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                    .foregroundColor(.appTextSecondary)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Guardar") {
                        Task {
                            await viewModel.updateUserDetails(userId: userId)
                        }
                    }
                    .disabled(viewModel.isSaveChangesDisabled || viewModel.isLoading)
                    .foregroundColor(viewModel.isSaveChangesDisabled ? .appTextSecondary : .appAccent)
                }
            }
        }
        .task {
            await viewModel.fetchUserDetails(userId: userId)
        }
        .alert(item: $viewModel.alertItem) { alertItem in
            Alert(
                title: alertItem.title,
                message: alertItem.message,
                dismissButton: alertItem.dismissButton
            )
        }
        .onChange(of: viewModel.successMessage) { message in
            if message != nil {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    dismiss()
                }
            }
        }
    }
    
    @ViewBuilder
    private func userDetailsForm(_ userDetails: UserDetails) -> some View {
        VStack(spacing: 20) {
            // Header con información básica
            VStack(spacing: 12) {
                Circle()
                    .fill(Color.appAccent.opacity(0.2))
                    .frame(width: 80, height: 80)
                    .overlay {
                        Text(getInitials(from: userDetails.nombre))
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundColor(.appAccent)
                    }
                
                Text("ID: #\(userDetails.id)")
                    .font(.caption)
                    .foregroundColor(.appTextSecondary)
            }
            
            // Formulario de edición
            VStack(spacing: 16) {
                // Nombre
                VStack(alignment: .leading, spacing: 8) {
                    Text("Nombre")
                        .font(.headline)
                        .foregroundColor(.appTextPrimary)
                    
                    TextField("Nombre del usuario", text: $viewModel.editedName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.words)
                }
                
                // Apellido
                VStack(alignment: .leading, spacing: 8) {
                    Text("Apellido")
                        .font(.headline)
                        .foregroundColor(.appTextPrimary)
                    
                    TextField("Apellido del usuario (opcional)", text: $viewModel.editedLastName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.words)
                }
                
                // Email
                VStack(alignment: .leading, spacing: 8) {
                    Text("Email")
                        .font(.headline)
                        .foregroundColor(.appTextPrimary)
                    
                    TextField("Email del usuario", text: $viewModel.editedEmail)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }
                
                // Nueva contraseña
                VStack(alignment: .leading, spacing: 8) {
                    Text("Nueva Contraseña")
                        .font(.headline)
                        .foregroundColor(.appTextPrimary)
                    
                    SecureField("Nueva contraseña (opcional)", text: $viewModel.newPassword)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Text("Deja en blanco si no deseas cambiar la contraseña")
                        .font(.caption)
                        .foregroundColor(.appTextSecondary)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.appCardBackground)
                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
            )
            
            // Mensaje de éxito
            if let successMessage = viewModel.successMessage {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text(successMessage)
                        .foregroundColor(.green)
                        .font(.body)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.green.opacity(0.1))
                )
            }
            
            Spacer()
        }
    }
    
    private func getInitials(from name: String) -> String {
        let components = name.split(separator: " ")
        let initials = components.compactMap { $0.first }.map { String($0) }
        return initials.prefix(2).joined().uppercased()
    }
}

#Preview {
    UserManagementView(userId: 1)
}