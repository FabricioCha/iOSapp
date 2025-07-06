//
//  FriendRowView.swift
//  ProyectIOs
//
//  Created by Trae AI on 2024.
//

import SwiftUI

struct FriendRowView: View {
    let friend: Friend
    let onTap: () -> Void
    let onDelete: () -> Void
    
    @State private var showingDeleteAlert = false
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Avatar
                Circle()
                    .fill(Color.appPrimaryAction.opacity(0.2))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Text(friend.nombre.prefix(1).uppercased())
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.appPrimaryAction)
                    )
                
                // Friend Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(friend.nombre)
                        .font(.headline)
                        .foregroundColor(.appTextPrimary)
                        .lineLimit(1)
                    
                    Text(friend.email)
                        .font(.subheadline)
                        .foregroundColor(.appTextSecondary)
                        .lineLimit(1)
                    
                    Text("Amigos desde \(formatDate(friend.fechaInicioAmistad))")
                        .font(.caption)
                        .foregroundColor(.appTextSecondary)
                }
                
                Spacer()
                
                // Actions
                Menu {
                    Button("Ver perfil", action: onTap)
                    
                    Button("Eliminar amistad", role: .destructive) {
                        showingDeleteAlert = true
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.title3)
                        .foregroundColor(.appTextSecondary)
                        .padding(8)
                }
            }
            .padding(16)
            .background(Color.appCardBackground)
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
        .alert("Eliminar Amistad", isPresented: $showingDeleteAlert) {
            Button("Cancelar", role: .cancel) { }
            Button("Eliminar", role: .destructive) {
                onDelete()
            }
        } message: {
            Text("¿Estás seguro de que quieres eliminar a \(friend.nombre) de tu lista de amigos?")
        }
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        if let date = formatter.date(from: dateString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateFormat = "dd/MM/yyyy"
            return displayFormatter.string(from: date)
        }
        
        return dateString
    }
}

struct ReceivedInvitationRowView: View {
    let invitation: FriendInvitation
    let onAccept: () -> Void
    let onReject: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            Circle()
                .fill(Color.appPrimaryAction.opacity(0.2))
                .frame(width: 45, height: 45)
                .overlay(
                    Text((invitation.solicitanteNombre ?? "?").prefix(1).uppercased())
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.appPrimaryAction)
                )
            
            // Invitation Info
            VStack(alignment: .leading, spacing: 4) {
                Text(invitation.solicitanteNombre ?? "Usuario desconocido")
                    .font(.headline)
                    .foregroundColor(.appTextPrimary)
                    .lineLimit(1)
                
                Text(invitation.solicitanteEmail ?? "")
                    .font(.subheadline)
                    .foregroundColor(.appTextSecondary)
                    .lineLimit(1)
                
                Text("Enviada \(formatDate(invitation.fechaEnvio))")
                    .font(.caption)
                    .foregroundColor(.appTextSecondary)
            }
            
            Spacer()
            
            // Action Buttons
            HStack(spacing: 8) {
                Button(action: onReject) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 32, height: 32)
                        .background(Color.red)
                        .clipShape(Circle())
                }
                
                Button(action: onAccept) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 32, height: 32)
                        .background(Color.green)
                        .clipShape(Circle())
                }
            }
        }
        .padding(16)
        .background(Color.appCardBackground)
        .cornerRadius(12)
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        if let date = formatter.date(from: dateString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateFormat = "dd/MM/yyyy"
            return displayFormatter.string(from: date)
        }
        
        return dateString
    }
}

struct SentInvitationRowView: View {
    let invitation: FriendInvitation
    
    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            Circle()
                .fill(Color.appTextSecondary.opacity(0.2))
                .frame(width: 45, height: 45)
                .overlay(
                    Text((invitation.solicitadoNombre ?? "?").prefix(1).uppercased())
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.appTextSecondary)
                )
            
            // Invitation Info
            VStack(alignment: .leading, spacing: 4) {
                Text(invitation.solicitadoNombre ?? "Usuario desconocido")
                    .font(.headline)
                    .foregroundColor(.appTextPrimary)
                    .lineLimit(1)
                
                Text(invitation.solicitadoEmail ?? "")
                    .font(.subheadline)
                    .foregroundColor(.appTextSecondary)
                    .lineLimit(1)
                
                Text("Enviada \(formatDate(invitation.fechaEnvio))")
                    .font(.caption)
                    .foregroundColor(.appTextSecondary)
            }
            
            Spacer()
            
            // Status
            Text("Pendiente")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.orange)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.orange.opacity(0.1))
                .cornerRadius(8)
        }
        .padding(16)
        .background(Color.appCardBackground)
        .cornerRadius(12)
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        if let date = formatter.date(from: dateString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateFormat = "dd/MM/yyyy"
            return displayFormatter.string(from: date)
        }
        
        return dateString
    }
}

#Preview {
    VStack(spacing: 16) {
        FriendRowView(
            friend: Friend(
                id: 1,
                nombre: "Juan Pérez",
                email: "juan@example.com",
                fechaCreacion: "2024-01-01 10:00:00",
                fechaInicioAmistad: "2024-01-15 14:30:00"
            ),
            onTap: {},
            onDelete: {}
        )
        
        ReceivedInvitationRowView(
            invitation: FriendInvitation(
                id: 1,
                solicitanteId: 2,
                solicitadoId: 1,
                estado: "pendiente",
                fechaEnvio: "2024-01-20 09:15:00",
                solicitadoNombre: nil,
                solicitadoEmail: nil,
                solicitanteNombre: "María García",
                solicitanteEmail: "maria@example.com"
            ),
            onAccept: {},
            onReject: {}
        )
        
        SentInvitationRowView(
            invitation: FriendInvitation(
                id: 2,
                solicitanteId: 1,
                solicitadoId: 3,
                estado: "pendiente",
                fechaEnvio: "2024-01-19 16:45:00",
                solicitadoNombre: "Carlos López",
                solicitadoEmail: "carlos@example.com",
                solicitanteNombre: nil,
                solicitanteEmail: nil
            )
        )
    }
    .padding()
    .background(Color.appBackground)
}