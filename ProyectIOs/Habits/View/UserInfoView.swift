//
//  UserInfoView.swift
//  ProyectIOs
//
//  Created by Fabricio Chavez on 04/07/25.
//

import SwiftUI

struct UserInfoView: View {
    let userId: Int
    @StateObject private var viewModel = UserManagementViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()
                
                if viewModel.isLoading {
                    ProgressView("Cargando información del usuario...")
                        .foregroundColor(.appTextPrimary)
                } else {
                    ScrollView {
                        VStack(spacing: 24) {
                            if let userInfo = viewModel.userBasicInfo {
                                userProfileSection(userInfo)
                            } else {
                                Text("No se pudo cargar la información del usuario")
                                    .foregroundColor(.appTextSecondary)
                                    .padding()
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Información de Usuario")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cerrar") {
                        dismiss()
                    }
                    .foregroundColor(.appAccent)
                }
            }
        }
        .task {
            await viewModel.fetchUserBasicInfo(userId: userId)
        }
        .alert(item: $viewModel.alertItem) { alertItem in
            Alert(
                title: alertItem.title,
                message: alertItem.message,
                dismissButton: alertItem.dismissButton
            )
        }
    }
    
    @ViewBuilder
    private func userProfileSection(_ userInfo: UserBasicInfo) -> some View {
        VStack(spacing: 20) {
            // Avatar y nombre
            VStack(spacing: 12) {
                Circle()
                    .fill(Color.appAccent.opacity(0.2))
                    .frame(width: 80, height: 80)
                    .overlay {
                        Text(getInitials(from: userInfo.nombre))
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundColor(.appAccent)
                    }
                
                Text(userInfo.nombre)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.appTextPrimary)
            }
            
            // Información básica
            VStack(spacing: 16) {
                userInfoRow(
                    icon: "envelope.fill",
                    label: "Email",
                    value: userInfo.email
                )
                
                userInfoRow(
                    icon: "calendar",
                    label: "Miembro desde",
                    value: viewModel.formatCreationDate(userInfo.fechaCreacion)
                )
                
                userInfoRow(
                    icon: "person.badge.key.fill",
                    label: "ID de Usuario",
                    value: "#\(userInfo.id)"
                )
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.appCardBackground)
                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
            )
        }
    }
    
    @ViewBuilder
    private func userInfoRow(icon: String, label: String, value: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.appAccent)
                .frame(width: 25)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.appTextSecondary)
                
                Text(value)
                    .font(.body)
                    .foregroundColor(.appTextPrimary)
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
    UserInfoView(userId: 1)
}