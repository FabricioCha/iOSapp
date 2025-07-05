//
//  EditProfileView.swift
//  ProyectIOs
//
//  Created by Fabricio Chavez on 04/07/25.
//

import SwiftUI

struct EditProfileView: View {
    
    // El ViewModel se pasa desde la vista padre.
    @ObservedObject var viewModel: ProfileViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 25) {
                    // Sección para cambiar nombre
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Cambiar Nombre")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        CustomTF(sfIcon: "person.text.rectangle", hint: "Nuevo nombre", value: $viewModel.updatedName)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.15))
                    .cornerRadius(15)
                    
                    // Sección para cambiar contraseña
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Cambiar Contraseña")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        CustomTF(sfIcon: "lock.shield", hint: "Contraseña Actual", isPassword: true, value: $viewModel.currentPassword)
                        CustomTF(sfIcon: "lock.fill", hint: "Nueva Contraseña", isPassword: true, value: $viewModel.newPassword)
                        CustomTF(sfIcon: "lock.fill", hint: "Confirmar Nueva Contraseña", isPassword: true, value: $viewModel.confirmNewPassword)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.15))
                    .cornerRadius(15)
                    
                    Spacer()
                    
                    GradientButton(title: "Guardar Cambios", icon: "checkmark.circle.fill") {
                        Task {
                           await viewModel.updateProfile()
                        }
                    }
                }
                .padding()
            }
        }
        .foregroundColor(Color.appTextPrimary)
        .navigationTitle("Editar Perfil")
        .navigationBarTitleDisplayMode(.inline)
        // Muestra una alerta si hay un error o un mensaje de éxito.
        .alert(item: $viewModel.alertItem) { alertItem in
            Alert(title: alertItem.title, message: alertItem.message, dismissButton: alertItem.dismissButton)
        }
        .alert("Éxito", isPresented: .constant(viewModel.successMessage != nil), actions: {
            Button("OK", role: .cancel) {
                viewModel.successMessage = nil
                dismiss() // Cierra la vista al presionar OK
            }
        }, message: {
            Text(viewModel.successMessage ?? "")
        })
        // Muestra un indicador de carga mientras se actualiza.
        .overlay {
            if viewModel.isLoading {
                Color.black.opacity(0.4).ignoresSafeArea()
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
            }
        }
    }
}

#Preview {
    // Preview con datos de muestra
    struct PreviewWrapper: View {
        @StateObject private var vm = ProfileViewModel()
        
        init() {
            // Simula un perfil cargado para la preview
            vm.userProfile = UserProfile(id: 1, nombre: "Usuario de Prueba", email: "test@test.com", rol: "usuario_estandar", fechaCreacion: "2025-07-04T23:00:00Z", ultimoLogin: nil, estado: "activo", suspensionFin: nil)
            vm.updatedName = "Usuario de Prueba"
        }
        
        var body: some View {
            NavigationStack {
                EditProfileView(viewModel: vm)
            }
        }
    }
    return PreviewWrapper()
}
