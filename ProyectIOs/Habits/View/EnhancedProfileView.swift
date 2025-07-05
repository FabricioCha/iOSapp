//
//  EnhancedProfileView.swift
//  ProyectIOs
//
//  Created by Fabricio Chavez on Enhanced Profile - Phase 2
//

import SwiftUI

struct EnhancedProfileView: View {
    
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var habitsViewModel: HabitsViewModel
    
    @StateObject private var viewModel = ProfileViewModel()
    @StateObject private var statsViewModel = EnhancedStatsViewModel()
    
    @State private var showingEditProfile = false
    @State private var showingSettings = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                
                if viewModel.isLoading && viewModel.userProfile == nil {
                    ProgressView("Cargando perfil...")
                        .foregroundColor(Color.appTextPrimary)
                } else if let profile = viewModel.userProfile {
                    ScrollView {
                        VStack(spacing: 24) {
                            
                            // MARK: - Header Section
                            profileHeaderSection(profile: profile)
                            
                            // MARK: - Quick Stats Section
                            quickStatsSection
                            
                            // MARK: - Profile Information
                            profileInformationSection(profile: profile)
                            
                            // MARK: - Navigation Links
                            navigationLinksSection
                            
                            // MARK: - Account Actions
                            accountActionsSection
                            
                            Spacer(minLength: 100)
                        }
                        .padding(.top)
                    }
                    .refreshable {
                        await loadAllData()
                    }
                } else {
                    errorStateView
                }
            }
            .foregroundColor(Color.appTextPrimary)
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        Button {
                            showingSettings = true
                        } label: {
                            Image(systemName: "gearshape")
                                .font(.title3)
                        }
                        
                        Button {
                            showingEditProfile = true
                        } label: {
                            Image(systemName: "pencil")
                                .font(.title3)
                        }
                        .disabled(viewModel.userProfile == nil)
                    }
                }
            }
            .onAppear {
                Task {
                    await loadAllData()
                }
            }
            .alert(item: $viewModel.alertItem) { alertItem in
                Alert(title: alertItem.title, message: alertItem.message, dismissButton: alertItem.dismissButton)
            }
            .sheet(isPresented: $showingEditProfile) {
                if let profile = viewModel.userProfile {
                    EditProfileView(viewModel: viewModel)
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
        }
    }
    
    // MARK: - Profile Header Section
    private func profileHeaderSection(profile: UserProfile) -> some View {
        VStack(spacing: 16) {
            // Avatar y nombre
            VStack(spacing: 12) {
                // Avatar circular
                ZStack {
                    Circle()
                        .fill(LinearGradient(
                            colors: [Color.appPrimaryAction, Color.appPrimaryAction.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 100, height: 100)
                    
                    Text(getInitials(from: profile.nombre))
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                
                VStack(spacing: 4) {
                    Text(profile.nombre)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(profile.email)
                        .font(.callout)
                        .foregroundColor(Color.appTextSecondary)
                    
                    // Badge del rol
                    Text(profile.rol?.capitalized ?? "Estándar")
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Color.appPrimaryAction.opacity(0.2))
                        .foregroundColor(Color.appPrimaryAction)
                        .cornerRadius(12)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(20)
        .padding(.horizontal)
    }
    
    // MARK: - Quick Stats Section
    private var quickStatsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Resumen de Actividad")
                .font(.headline)
                .fontWeight(.semibold)
                .padding(.horizontal)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                QuickStatCard(
                    title: "Racha Actual",
                    value: String(statsViewModel.currentStreak),
                    subtitle: "días",
                    iconName: "flame.fill",
                    color: .orange
                )
                
                QuickStatCard(
                    title: "Total Hábitos",
                    value: String(statsViewModel.totalHabits),
                    subtitle: "activos",
                    iconName: "target",
                    color: .blue
                )
                
                QuickStatCard(
                    title: "Logros",
                    value: String(statsViewModel.totalAchievements),
                    subtitle: "desbloqueados",
                    iconName: "star.fill",
                    color: .yellow
                )
                
                QuickStatCard(
                    title: "Mejor Racha",
                    value: String(statsViewModel.longestStreak),
                    subtitle: "días",
                    iconName: "crown.fill",
                    color: .purple
                )
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Profile Information Section
    private func profileInformationSection(profile: UserProfile) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Información del Perfil")
                .font(.headline)
                .fontWeight(.semibold)
                .padding(.horizontal)
            
            VStack(spacing: 12) {
                ProfileInfoRow(
                    icon: "calendar.badge.plus",
                    label: "Miembro desde",
                    value: formatDate(profile.fechaCreacion ?? ""),
                    color: .green
                )
                
                Divider()
                
                ProfileInfoRow(
                    icon: "checkmark.circle.fill",
                    label: "Hábitos Buenos",
                    value: String(statsViewModel.goodHabitsCount),
                    color: .blue
                )
                
                Divider()
                
                ProfileInfoRow(
                    icon: "xmark.shield.fill",
                    label: "Adicciones Controladas",
                    value: String(statsViewModel.addictionsCount),
                    color: .red
                )
            }
            .padding()
            .background(Color.gray.opacity(0.05))
            .cornerRadius(16)
            .padding(.horizontal)
        }
    }
    
    // MARK: - Navigation Links Section
    private var navigationLinksSection: some View {
        VStack(spacing: 12) {
            NavigationLink {
                BadgesView()
            } label: {
                NavigationRowView(
                    icon: "rosette",
                    title: "Mis Insignias",
                    subtitle: "\(String(statsViewModel.totalAchievements)) desbloqueadas",
                    color: .yellow
                )
            }
            
            NavigationLink {
                EnhancedStatsView()
            } label: {
                NavigationRowView(
                    icon: "chart.pie.fill",
                    title: "Estadísticas Detalladas",
                    subtitle: "Ver progreso completo",
                    color: .blue
                )
            }
            
            NavigationLink {
                HabitHistoryView()
            } label: {
                NavigationRowView(
                    icon: "clock.arrow.circlepath",
                    title: "Historial de Hábitos",
                    subtitle: "Revisar actividad pasada",
                    color: .purple
                )
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - Account Actions Section
    private var accountActionsSection: some View {
        VStack(spacing: 16) {
            Divider()
                .padding(.horizontal)
            
            GradientButton(
                title: "Cerrar Sesión",
                icon: "rectangle.portrait.and.arrow.right",
                action: {
                    authViewModel.logout(habitsViewModel: habitsViewModel)
                }
            )
            .padding(.horizontal)
        }
    }
    
    // MARK: - Error State View
    private var errorStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.crop.circle.badge.exclamationmark")
                .font(.system(size: 60))
                .foregroundColor(.red)
            
            Text("Error al cargar perfil")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("No se pudo cargar la información del perfil.")
                .font(.callout)
                .foregroundColor(Color.appTextSecondary)
                .multilineTextAlignment(.center)
            
            Button("Reintentar") {
                Task {
                    await loadAllData()
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(Color.appPrimaryAction)
        }
        .padding()
    }
    
    // MARK: - Helper Methods
    
    private func loadAllData() async {
        async let profileTask = viewModel.fetchProfile()
        async let statsTask = statsViewModel.loadAllStats()
        
        await (profileTask, statsTask)
    }
    
    private func getInitials(from name: String) -> String {
        let components = name.components(separatedBy: " ")
        let initials = components.compactMap { $0.first }.map { String($0) }
        return initials.prefix(2).joined().uppercased()
    }
    
    private func formatDate(_ dateString: String) -> String {
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

// MARK: - Supporting Views

struct QuickStatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let iconName: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: iconName)
                    .font(.title3)
                    .foregroundColor(color)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(value)
                        .font(.title2)
                        .fontWeight(.bold)
                    Spacer()
                }
                
                HStack {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(Color.appTextSecondary)
                    Spacer()
                }
                
                HStack {
                    Text(title)
                        .font(.caption)
                        .fontWeight(.medium)
                    Spacer()
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
}

struct ProfileInfoRow: View {
    let icon: String
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption)
                    .foregroundColor(Color.appTextSecondary)
                
                Text(value)
                    .font(.callout)
                    .fontWeight(.medium)
            }
            
            Spacer()
        }
    }
}

struct NavigationRowView: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 32, height: 32)
                .background(color.opacity(0.2))
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.callout)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.appTextPrimary)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(Color.appTextSecondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(Color.appTextSecondary)
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
}

// MARK: - Placeholder Views

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Configuración")
                    .font(.title)
                    .padding()
                
                Text("Próximamente: Configuraciones de la aplicación")
                    .foregroundColor(Color.appTextSecondary)
                
                Spacer()
            }
            .navigationTitle("Configuración")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cerrar") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct HabitHistoryView: View {
    var body: some View {
        VStack {
            Text("Historial de Hábitos")
                .font(.title)
                .padding()
            
            Text("Próximamente: Historial detallado de todos tus hábitos")
                .foregroundColor(Color.appTextSecondary)
                .multilineTextAlignment(.center)
                .padding()
            
            Spacer()
        }
        .navigationTitle("Historial")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Preview

//#Preview {
//    struct PreviewWrapper: View {
//        private static let authViewModel: AuthViewModel = {
//            let vm = AuthViewModel()
//            vm.currentUser = User(
//                //id: 1,
//                name: "Usuario de Prueba",
//                email: "preview@test.com"
//            )
//            return vm
//        }()
//        
//        var body: some View {
//            EnhancedProfileView()
//                .environmentObject(Self.authViewModel)
//                .environmentObject(HabitsViewModel())
//        }
//    }
//    
//    return PreviewWrapper()
//}
