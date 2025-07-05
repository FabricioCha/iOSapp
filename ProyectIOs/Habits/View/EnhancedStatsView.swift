//
//  EnhancedStatsView.swift
//  ProyectIOs
//
//  Created by Fabricio Chavez on Enhanced Stats - Phase 2
//

import SwiftUI

struct EnhancedStatsView: View {
    
    @StateObject private var viewModel = EnhancedStatsViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    
    private let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            if viewModel.isLoading {
                ProgressView("Cargando estadísticas...")
                    .foregroundColor(Color.appTextPrimary)
            } else if let errorMessage = viewModel.errorMessage {
                ErrorView(message: errorMessage) {
                    Task {
                        await viewModel.loadAllStats()
                    }
                }
            } else {
                ScrollView {
                    VStack(spacing: 24) {
                        headerSection
                        
                        progressCircleSection
                        
                        quickStatsGrid
                        
                        detailedStatsSection
                        
                        habitBreakdownSection
                    }
                    .padding()
                }
                .refreshable {
                    await viewModel.loadAllStats()
                }
            }
        }
        .foregroundColor(Color.appTextPrimary)
        .onAppear {
            Task {
                await viewModel.loadAllStats()
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Tu Progreso")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Spacer()
                
                // Botón de actualización
                Button {
                    Task {
                        await viewModel.loadAllStats()
                    }
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .font(.title2)
                        .foregroundColor(Color.appPrimaryAction)
                }
            }
            
            Text("Resumen de tu actividad y logros")
                .font(.callout)
                .foregroundColor(Color.appTextSecondary)
        }
    }
    
    // MARK: - Progress Circle Section
    private var progressCircleSection: some View {
        VStack(spacing: 16) {
            Text("Racha Actual")
                .font(.title2)
                .fontWeight(.semibold)
            
            ZStack {
                // Círculo de progreso principal
                CircularProgressView(
                    progress: min(Double(viewModel.currentStreak) / 30.0, 1.0),
                    text: String(viewModel.currentStreak)
                )
                .frame(width: 200, height: 200)
            }
            
            Text("días consecutivos")
                .font(.callout)
                .foregroundColor(Color.appTextSecondary)
        }
        .padding(.vertical)
    }
    
    // MARK: - Quick Stats Grid
    private var quickStatsGrid: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            StatCardView(
                title: "Mejor Racha",
                value: String(viewModel.longestStreak),
                iconName: "crown.fill",
                color: .yellow
            )
            
            StatCardView(
                title: "Total Hábitos",
                value: String(viewModel.totalHabits),
                iconName: "target",
                color: .blue
            )
            
            StatCardView(
                title: "Hábitos Buenos",
                value: String(viewModel.goodHabitsCount),
                iconName: "checkmark.circle.fill",
                color: .green
            )
            
            StatCardView(
                title: "Adicciones",
                value: String(viewModel.addictionsCount),
                iconName: "xmark.shield.fill",
                color: .red
            )
        }
    }
    
    // MARK: - Detailed Stats Section
    private var detailedStatsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Estadísticas Detalladas")
                .font(.title2)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                DetailedStatRow(
                    title: "Mejor racha en hábitos buenos",
                    value: "\(String(viewModel.bestGoodHabitStreak)) días",
                    iconName: "flame.fill",
                    color: .orange
                )
                
                DetailedStatRow(
                    title: "Mejor racha sin adicciones",
                    value: "\(String(viewModel.bestAddictionStreak)) días",
                    iconName: "shield.fill",
                    color: .green
                )
                
                DetailedStatRow(
                    title: "Total de logros",
                    value: String(viewModel.totalAchievements),
                    iconName: "star.fill",
                    color: .yellow
                )
                
                if let joinDate = viewModel.joinDate {
                    DetailedStatRow(
                        title: "Miembro desde",
                        value: formatJoinDate(joinDate),
                        iconName: "calendar.badge.plus",
                        color: .blue
                    )
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(16)
        }
    }
    
    // MARK: - Habit Breakdown Section
    private var habitBreakdownSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Desglose por Hábito")
                .font(.title2)
                .fontWeight(.semibold)
            
            if viewModel.habitsWithStats.isEmpty {
                Text("No hay hábitos para mostrar")
                    .font(.callout)
                    .foregroundColor(Color.appTextSecondary)
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.habitsWithStats, id: \.id) { habit in
                        HabitStatRow(habit: habit)
                    }
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    private func formatJoinDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        if let date = formatter.date(from: dateString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateFormat = "MMM yyyy"
            displayFormatter.locale = Locale(identifier: "es_ES")
            return displayFormatter.string(from: date)
        }
        
        return dateString
    }
}

// MARK: - Supporting Views

struct DetailedStatRow: View {
    let title: String
    let value: String
    let iconName: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: iconName)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 24)
            
            Text(title)
                .font(.callout)
                .foregroundColor(Color.appTextPrimary)
            
            Spacer()
            
            Text(value)
                .font(.callout)
                .fontWeight(.semibold)
                .foregroundColor(Color.appTextPrimary)
        }
    }
}

struct HabitStatRow: View {
    let habit: HabitWithStats
    
    var body: some View {
        HStack(spacing: 16) {
            // Icono del tipo de hábito
            Image(systemName: habitIcon)
                .font(.title3)
                .foregroundColor(habitColor)
                .frame(width: 32, height: 32)
                .background(habitColor.opacity(0.2))
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(habit.nombre)
                    .font(.callout)
                    .fontWeight(.medium)
                
                Text(habitTypeText)
                    .font(.caption2)
                    .foregroundColor(Color.appTextSecondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(String(habit.rachaActual))
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(habitColor)
                
                Text("días")
                    .font(.caption2)
                    .foregroundColor(Color.appTextSecondary)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
    
    var habitIcon: String {
        switch habit.tipo {
        case .siNo:
            return "checkmark.circle.fill"
        case .medibleNumerico:
            return "number.circle.fill"
        case .malHabito:
            return "xmark.circle.fill"
        }
    }
    
    var habitColor: Color {
        switch habit.tipo {
        case .siNo, .medibleNumerico:
            return .green
        case .malHabito:
            return .red
        }
    }
    
    var habitTypeText: String {
        switch habit.tipo {
        case .siNo:
            return "Hábito Sí/No"
        case .medibleNumerico:
            return "Hábito Numérico"
        case .malHabito:
            return "Mal hábito"
        }
    }
}

struct ErrorView: View {
    let message: String
    let onRetry: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.red)
            
            Text("Error")
                .font(.title)
                .fontWeight(.bold)
            
            Text(message)
                .font(.callout)
                .foregroundColor(Color.appTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("Reintentar") {
                onRetry()
            }
            .buttonStyle(.borderedProminent)
            .tint(Color.appPrimaryAction)
        }
        .padding()
    }
}

// MARK: - Preview

#Preview {
    struct PreviewWrapper: View {
        private static let authViewModel: AuthViewModel = {
            let vm = AuthViewModel()
            vm.currentUser = User(id: "1", name: "Usuario de Prueba", email: "preview@test.com")
            return vm
        }()
        
        var body: some View {
            EnhancedStatsView()
                .environmentObject(Self.authViewModel)
        }
    }
    
    return PreviewWrapper()
}