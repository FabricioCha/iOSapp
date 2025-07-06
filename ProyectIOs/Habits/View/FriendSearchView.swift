//
//  FriendSearchView.swift
//  ProyectIOs
//
//  Created by Trae AI on 2024.
//

import SwiftUI

struct FriendSearchView: View {
    @ObservedObject var viewModel: FriendsViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                searchBar
                
                // Search Results
                if viewModel.isSearching {
                    ProgressView("Buscando usuarios...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .foregroundColor(.appTextSecondary)
                } else if viewModel.searchQuery.isEmpty {
                    emptySearchView
                } else if viewModel.searchResults.isEmpty {
                    noResultsView
                } else {
                    searchResultsList
                }
            }
            .background(Color.appBackground)
            .navigationTitle("Buscar Amigos")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !viewModel.searchQuery.isEmpty {
                        Button("Limpiar") {
                            viewModel.clearSearch()
                        }
                    }
                }
            }
        }
    }
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.appTextSecondary)
            
            TextField("Buscar por nombre o email", text: $viewModel.searchQuery)
                .textFieldStyle(PlainTextFieldStyle())
                .onSubmit {
                    Task {
                        await viewModel.searchUsers()
                    }
                }
                .onChange(of: viewModel.searchQuery) { newValue in
                    if newValue.isEmpty {
                        viewModel.clearSearch()
                    }
                }
            
            if !viewModel.searchQuery.isEmpty {
                Button(action: {
                    viewModel.clearSearch()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.appTextSecondary)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.appCardBackground)
        .cornerRadius(10)
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
    
    private var emptySearchView: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.crop.circle.badge.plus")
                .font(.system(size: 60))
                .foregroundColor(.appTextSecondary)
            
            Text("Buscar Nuevos Amigos")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.appTextPrimary)
            
            Text("Escribe el nombre o email de la persona que quieres agregar como amigo")
                .font(.body)
                .foregroundColor(.appTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var noResultsView: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.crop.circle.badge.questionmark")
                .font(.system(size: 60))
                .foregroundColor(.appTextSecondary)
            
            Text("No se encontraron usuarios")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.appTextPrimary)
            
            Text("Intenta con un nombre o email diferente")
                .font(.body)
                .foregroundColor(.appTextSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var searchResultsList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.searchResults) { user in
                    UserSearchRowView(
                        user: user,
                        isAlreadyFriend: viewModel.isUserAlreadyFriend(user),
                        hasInvitationSent: viewModel.hasInvitationSentTo(user),
                        hasInvitationReceived: viewModel.hasInvitationReceivedFrom(user)
                    ) {
                        Task {
                            await viewModel.sendFriendInvitation(to: user)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
        }
    }
}

struct UserSearchRowView: View {
    let user: SearchUser
    let isAlreadyFriend: Bool
    let hasInvitationSent: Bool
    let hasInvitationReceived: Bool
    let onSendInvitation: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            Circle()
                .fill(Color.appPrimaryAction.opacity(0.2))
                .frame(width: 50, height: 50)
                .overlay(
                    Text(user.nombre.prefix(1).uppercased())
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.appPrimaryAction)
                )
            
            // User Info
            VStack(alignment: .leading, spacing: 4) {
                Text(user.nombre)
                    .font(.headline)
                    .foregroundColor(.appTextPrimary)
                    .lineLimit(1)
                
                Text(user.email ?? "Sin email")
                    .font(.subheadline)
                    .foregroundColor(.appTextSecondary)
                    .lineLimit(1)
                
                Text("Miembro desde \(formatDate(user.fechaCreacion))")
                    .font(.caption)
                    .foregroundColor(.appTextSecondary)
            }
            
            Spacer()
            
            // Action Button
            actionButton
        }
        .padding(16)
        .background(Color.appCardBackground)
        .cornerRadius(12)
    }
    
    @ViewBuilder
    private var actionButton: some View {
        if isAlreadyFriend {
            Text("Amigo")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.green)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.green.opacity(0.1))
                .cornerRadius(12)
        } else if hasInvitationSent {
            Text("Enviada")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.orange)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.orange.opacity(0.1))
                .cornerRadius(12)
        } else if hasInvitationReceived {
            Text("Pendiente")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.blue)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(12)
        } else {
            Button(action: onSendInvitation) {
                Image(systemName: "person.badge.plus")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 36, height: 36)
                    .background(Color.appPrimaryAction)
                    .clipShape(Circle())
            }
        }
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        if let date = formatter.date(from: dateString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateFormat = "MMM yyyy"
            return displayFormatter.string(from: date)
        }
        
        return dateString
    }
}

#Preview {
    FriendSearchView(viewModel: FriendsViewModel())
}