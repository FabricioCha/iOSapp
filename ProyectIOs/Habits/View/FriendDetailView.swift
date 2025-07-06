//
//  FriendDetailView.swift
//  ProyectIOs
//
//  Created by Trae AI on 2024.
//

import SwiftUI

struct FriendDetailView: View {
    let friend: Friend
    @ObservedObject var viewModel: FriendsViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                headerView
                
                // Tab Selector
                tabSelector
                
                // Content
                TabView(selection: $selectedTab) {
                    // Actividad
                    activityView
                        .tag(0)
                    
                    // Logros
                    achievementsView
                        .tag(1)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            .background(Color.appBackground)
            .navigationBarHidden(true)
        }
        .task {
            await loadFriendData()
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 16) {
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark")
                        .font(.title2)
                        .foregroundColor(.appTextPrimary)
                }
                
                Spacer()
                
                Menu {
                    Button("Eliminar amistad", role: .destructive) {
                        Task {
                            await viewModel.deleteFriend(friend)
                            dismiss()
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.title2)
                        .foregroundColor(.appTextPrimary)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            
            // Friend Info
            VStack(spacing: 12) {
                Circle()
                    .fill(Color.appPrimaryAction.opacity(0.2))
                    .frame(width: 80, height: 80)
                    .overlay(
                        Text(friend.nombre.prefix(1).uppercased())
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.appPrimaryAction)
                    )
                
                VStack(spacing: 4) {
                    Text(friend.nombre)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.appTextPrimary)
                    
                    Text(friend.email)
                        .font(.subheadline)
                        .foregroundColor(.appTextSecondary)
                    
                    Text("Amigos desde \(formatDate(friend.fechaInicioAmistad))")
                        .font(.caption)
                        .foregroundColor(.appTextSecondary)
                }
            }
        }
        .padding(.bottom, 20)
    }
    
    private var tabSelector: some View {
        HStack(spacing: 0) {
            TabButton(title: "Actividad", isSelected: selectedTab == 0) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    selectedTab = 0
                }
            }
            
            TabButton(title: "Logros", isSelected: selectedTab == 1) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    selectedTab = 1
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
    }
    
    private var activityView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                // Estadísticas del amigo (si están disponibles)
                if let stats = viewModel.friendStats {
                    friendStatsView(stats: stats)
                }
                
                if viewModel.isLoading {
                    ProgressView("Cargando actividad...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.top, 50)
                } else if viewModel.friendActivity.isEmpty {
                    emptyActivityView
                } else {
                    // Título de actividad reciente
                     HStack {
                         Text("Actividad Reciente")
                             .font(.headline)
                             .foregroundColor(.primary)
                         Spacer()
                     }
                    
                    ForEach(viewModel.friendActivity) { activity in
                        ActivityRowView(activity: activity)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
        }
        .refreshable {
            await viewModel.loadFriendActivity(friendId: friend.id)
        }
    }
    
    private var achievementsView: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                if viewModel.isLoading {
                    ProgressView("Cargando logros...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .foregroundColor(.appTextSecondary)
                        .gridCellColumns(2)
                } else if viewModel.friendAchievements.isEmpty {
                    emptyAchievementsView
                        .gridCellColumns(2)
                } else {
                    ForEach(viewModel.friendAchievements) { achievement in
                        AchievementCardView(achievement: achievement)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
        }
        .refreshable {
            await viewModel.loadFriendAchievements(friendId: friend.id)
        }
    }
    
    private var emptyActivityView: some View {
        VStack(spacing: 16) {
            Image(systemName: "clock")
                .font(.system(size: 50))
                .foregroundColor(.appTextSecondary)
            
            Text("Sin actividad reciente")
                .font(.headline)
                .foregroundColor(.appTextPrimary)
            
            Text("\(friend.nombre) no ha tenido actividad reciente")
                .font(.body)
                .foregroundColor(.appTextSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
    }
    
    private var emptyAchievementsView: some View {
        VStack(spacing: 16) {
            Image(systemName: "trophy")
                .font(.system(size: 50))
                .foregroundColor(.appTextSecondary)
            
            Text("Sin logros aún")
                .font(.headline)
                .foregroundColor(.appTextPrimary)
            
            Text("\(friend.nombre) aún no ha desbloqueado logros")
                .font(.body)
                .foregroundColor(.appTextSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
    }
    
    private func friendStatsView(stats: UserStats) -> some View {
        VStack(spacing: 16) {
            HStack {
                Text("Estadísticas de \(friend.nombre)")
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                StatCardView(
                    title: "Hábitos Totales",
                    value: "\(stats.totalHabits)",
                    iconName: "list.bullet",
                    color: .blue
                )
                
                StatCardView(
                    title: "Completados Hoy",
                    value: "\(stats.completedToday)",
                    iconName: "checkmark.circle.fill",
                    color: .green
                )
                
                StatCardView(
                    title: "Racha Actual",
                    value: "\(stats.currentStreak) días",
                    iconName: "flame.fill",
                    color: .orange
                )
                
                StatCardView(
                    title: "Mejor Racha",
                    value: "\(stats.longestStreak) días",
                    iconName: "trophy.fill",
                    color: .yellow
                )
            }
            
            // Tasa de completitud
            VStack(spacing: 8) {
                HStack {
                    Text("Tasa de Completitud")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(Int(stats.completionRate * 100))%")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                }
                
                ProgressView(value: stats.completionRate)
                    .progressViewStyle(LinearProgressViewStyle(tint: .blue))
            }
            .padding(16)
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
     }
    
    private func loadFriendData() async {
        await viewModel.loadFriendActivity(friendId: friend.id)
        await viewModel.loadFriendAchievements(friendId: friend.id)
        await viewModel.loadFriendStats(friendId: friend.id)
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

// MARK: - Supporting Views

struct ActivityRowView: View {
    let activity: FriendActivity
    
    var body: some View {
        HStack(spacing: 12) {
            // Activity Icon
            Circle()
                .fill(activityColor.opacity(0.2))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: activityIcon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(activityColor)
                )
            
            // Activity Info
            VStack(alignment: .leading, spacing: 4) {
                Text(activity.descripcion)
                    .font(.headline)
                    .foregroundColor(.appTextPrimary)
                    .lineLimit(2)
                
                Text(formatDate(activity.fecha))
                    .font(.caption)
                    .foregroundColor(.appTextSecondary)
            }
            
            Spacer()
        }
        .padding(16)
        .background(Color.appCardBackground)
        .cornerRadius(12)
    }
    
    private var activityIcon: String {
        switch activity.tipo.lowercased() {
        case "habit_completed":
            return "checkmark.circle"
        case "streak_achieved":
            return "flame"
        case "badge_earned":
            return "trophy"
        default:
            return "star"
        }
    }
    
    private var activityColor: Color {
        switch activity.tipo.lowercased() {
        case "habit_completed":
            return .green
        case "streak_achieved":
            return .orange
        case "badge_earned":
            return .yellow
        default:
            return .appPrimaryAction
        }
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        if let date = formatter.date(from: dateString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateFormat = "dd/MM/yyyy HH:mm"
            return displayFormatter.string(from: date)
        }
        
        return dateString
    }
}



struct AchievementCardView: View {
    let achievement: FriendAchievement
    
    var body: some View {
        VStack(spacing: 12) {
            // Achievement Icon
            Circle()
                .fill(Color.yellow.opacity(0.2))
                .frame(width: 60, height: 60)
                .overlay(
                    Group {
                        if let iconoUrl = achievement.icono, !iconoUrl.isEmpty {
                            AsyncImage(url: URL(string: iconoUrl)) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            } placeholder: {
                                Image(systemName: "trophy")
                                    .font(.system(size: 24, weight: .semibold))
                                    .foregroundColor(.yellow)
                            }
                            .frame(width: 30, height: 30)
                        } else {
                            Image(systemName: "trophy")
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundColor(.yellow)
                        }
                    }
                )
            
            // Achievement Info
            VStack(spacing: 4) {
                Text(achievement.nombre)
                    .font(.headline)
                    .foregroundColor(.appTextPrimary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                
                Text(achievement.descripcion)
                    .font(.caption)
                    .foregroundColor(.appTextSecondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                
                Text(formatDate(achievement.fechaObtencion))
                    .font(.caption2)
                    .foregroundColor(.appTextSecondary)
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

#Preview {
    FriendDetailView(
        friend: Friend(
            id: 1,
            nombre: "Juan Pérez",
            email: "juan@example.com",
            fechaCreacion: "2024-01-01 10:00:00",
            fechaInicioAmistad: "2024-01-15 14:30:00"
        ),
        viewModel: FriendsViewModel()
    )
}