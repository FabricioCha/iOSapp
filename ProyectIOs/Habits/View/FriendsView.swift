//
//  FriendsView.swift
//  ProyectIOs
//
//  Created by Trae AI on 2024.
//

import SwiftUI

struct FriendsView: View {
    @StateObject private var viewModel = FriendsViewModel()
    @State private var selectedTab = 0
    @State private var showingSearchView = false
    @State private var showingFriendDetail: Friend? = nil
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                headerView
                
                // Tab Selector
                tabSelector
                
                // Content
                TabView(selection: $selectedTab) {
                    // Mis Amigos
                    friendsListView
                        .tag(0)
                    
                    // Invitaciones
                    invitationsView
                        .tag(1)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            .background(Color.appBackground)
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingSearchView) {
            FriendSearchView(viewModel: viewModel)
        }
        .sheet(item: $showingFriendDetail) { friend in
            FriendDetailView(friend: friend, viewModel: viewModel)
        }
        .task {
            await loadInitialData()
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") {
                viewModel.clearMessages()
            }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .alert("Éxito", isPresented: .constant(viewModel.successMessage != nil)) {
            Button("OK") {
                viewModel.clearMessages()
            }
        } message: {
            Text(viewModel.successMessage ?? "")
        }
    }
    
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Amigos")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.appTextPrimary)
                
                Text("\(viewModel.friends.count) amigos")
                    .font(.subheadline)
                    .foregroundColor(.appTextSecondary)
            }
            
            Spacer()
            
            Button(action: {
                showingSearchView = true
            }) {
                Image(systemName: "person.badge.plus")
                    .font(.title2)
                    .foregroundColor(.appPrimaryAction)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }
    
    private var tabSelector: some View {
        HStack(spacing: 0) {
            TabButton(title: "Mis Amigos", isSelected: selectedTab == 0) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    selectedTab = 0
                }
            }
            
            TabButton(title: "Invitaciones", isSelected: selectedTab == 1, badgeCount: viewModel.receivedInvitations.count) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    selectedTab = 1
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
    
    private var friendsListView: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                if viewModel.isLoading {
                    ProgressView("Cargando amigos...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .foregroundColor(.appTextSecondary)
                } else if viewModel.friends.isEmpty {
                    emptyFriendsView
                } else {
                    ForEach(viewModel.friends) { friend in
                        FriendRowView(friend: friend) {
                            showingFriendDetail = friend
                        } onDelete: {
                            Task {
                                await viewModel.deleteFriend(friend)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
        }
        .refreshable {
            await viewModel.loadFriends()
        }
    }
    
    private var invitationsView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                if viewModel.isLoading {
                    ProgressView("Cargando invitaciones...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .foregroundColor(.appTextSecondary)
                } else {
                    // Invitaciones recibidas
                    if !viewModel.receivedInvitations.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Solicitudes recibidas")
                                .font(.headline)
                                .foregroundColor(.appTextPrimary)
                                .padding(.horizontal, 20)
                            
                            ForEach(viewModel.receivedInvitations) { invitation in
                                ReceivedInvitationRowView(invitation: invitation) {
                                    Task {
                                        await viewModel.acceptInvitation(invitation)
                                    }
                                } onReject: {
                                    Task {
                                        await viewModel.rejectInvitation(invitation)
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                    }
                    
                    // Invitaciones enviadas
                    if !viewModel.sentInvitations.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Solicitudes enviadas")
                                .font(.headline)
                                .foregroundColor(.appTextPrimary)
                                .padding(.horizontal, 20)
                            
                            ForEach(viewModel.sentInvitations) { invitation in
                                SentInvitationRowView(invitation: invitation)
                                    .padding(.horizontal, 20)
                            }
                        }
                    }
                    
                    if viewModel.receivedInvitations.isEmpty && viewModel.sentInvitations.isEmpty {
                        emptyInvitationsView
                    }
                }
            }
            .padding(.top, 8)
        }
        .refreshable {
            await viewModel.loadInvitations()
        }
    }
    
    private var emptyFriendsView: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.2")
                .font(.system(size: 60))
                .foregroundColor(.appTextSecondary)
            
            Text("No tienes amigos aún")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.appTextPrimary)
            
            Text("Busca usuarios y envía solicitudes de amistad para comenzar a conectar con otros")
                .font(.body)
                .foregroundColor(.appTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button(action: {
                showingSearchView = true
            }) {
                Text("Buscar Amigos")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.appPrimaryAction)
                    .cornerRadius(25)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
    }
    
    private var emptyInvitationsView: some View {
        VStack(spacing: 16) {
            Image(systemName: "envelope")
                .font(.system(size: 60))
                .foregroundColor(.appTextSecondary)
            
            Text("No hay invitaciones")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.appTextPrimary)
            
            Text("Aquí aparecerán las solicitudes de amistad que envíes y recibas")
                .font(.body)
                .foregroundColor(.appTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
    }
    
    private func loadInitialData() async {
        await viewModel.loadFriends()
        await viewModel.loadInvitations()
    }
}

// MARK: - Supporting Views

struct TabButton: View {
    let title: String
    let isSelected: Bool
    let badgeCount: Int?
    let action: () -> Void
    
    init(title: String, isSelected: Bool, badgeCount: Int? = nil, action: @escaping () -> Void) {
        self.title = title
        self.isSelected = isSelected
        self.badgeCount = badgeCount
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.system(size: 16, weight: isSelected ? .semibold : .medium))
                    .foregroundColor(isSelected ? .appPrimaryAction : .appTextSecondary)
                
                if let count = badgeCount, count > 0 {
                    Text("\(count)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.red)
                        .clipShape(Capsule())
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.appPrimaryAction.opacity(0.1) : Color.clear)
            )
        }
    }
}

#Preview {
    FriendsView()
}