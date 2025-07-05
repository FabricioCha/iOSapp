//
//  AdminUserSearchView.swift
//  ProyectIOs
//
//  Created by Fabricio Chavez on 04/07/25.
//

import SwiftUI

struct AdminUserSearchView: View {
    @State private var searchText = ""
    @State private var selectedUserId: Int?
    @State private var showingUserManagement = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Campo de búsqueda
                VStack(alignment: .leading, spacing: 8) {
                    Text("ID de Usuario")
                        .font(.headline)
                        .foregroundColor(.appTextPrimary)
                    
                    TextField("Ingresa el ID del usuario (ej: 123)", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numberPad)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.appCardBackground)
                        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                )
                
                // Botón de gestión
                Button(action: manageUser) {
                    HStack {
                        Image(systemName: "person.crop.circle.badge.plus")
                        Text("Gestionar Usuario")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .disabled(searchText.trimmingCharacters(in: .whitespaces).isEmpty)
                
                // Advertencia de administrador
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "exclamationmark.triangle")
                            .foregroundColor(.orange)
                        Text("Acceso Administrativo")
                            .font(.headline)
                            .foregroundColor(.appTextPrimary)
                    }
                    
                    Text("Esta función permite editar detalles completos de cualquier usuario, incluyendo nombre, apellido, email y contraseña. Úsala con responsabilidad.")
                        .font(.body)
                        .foregroundColor(.appTextSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.orange.opacity(0.1))
                )
                
                // Información de permisos
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundColor(.blue)
                        Text("Permisos Requeridos")
                            .font(.headline)
                            .foregroundColor(.appTextPrimary)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("• Rol de Administrador o Moderador de Contenido")
                        Text("• Los moderadores no pueden editar otros usuarios privilegiados")
                        Text("• Todos los cambios quedan registrados en el sistema")
                    }
                    .font(.body)
                    .foregroundColor(.appTextSecondary)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.blue.opacity(0.1))
                )
                
                Spacer()
            }
            .padding()
            .background(Color.appBackground.ignoresSafeArea())
            .navigationTitle("Gestión Administrativa")
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $showingUserManagement) {
            if let userId = selectedUserId {
                UserManagementView(userId: userId)
            }
        }
    }
    
    private func manageUser() {
        guard let userId = Int(searchText.trimmingCharacters(in: .whitespaces)) else {
            return
        }
        
        selectedUserId = userId
        showingUserManagement = true
    }
}

#Preview {
    AdminUserSearchView()
}