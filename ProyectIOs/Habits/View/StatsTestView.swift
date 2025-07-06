//
//  StatsTestView.swift
//  ProyectIOs
//
//  Created by Assistant for testing Enhanced Stats integration
//

import SwiftUI

struct StatsTestView: View {
    @StateObject private var viewModel = EnhancedStatsViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Prueba de Estadísticas")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                if viewModel.isLoading {
                    ProgressView("Cargando estadísticas...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let errorMessage = viewModel.errorMessage {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 50))
                            .foregroundColor(.red)
                        
                        Text("Error")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text(errorMessage)
                            .font(.callout)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Button("Reintentar") {
                            Task {
                                await viewModel.loadAllStats()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 20) {
                            // Estadísticas principales
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Estadísticas Principales")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                
                                HStack {
                                    StatItem(title: "Racha Actual", value: "\(viewModel.currentStreak)")
                                    Spacer()
                                    StatItem(title: "Mejor Racha", value: "\(viewModel.longestStreak)")
                                }
                                
                                HStack {
                                    StatItem(title: "Total Hábitos", value: "\(viewModel.totalHabits)")
                                    Spacer()
                                    StatItem(title: "Logros", value: "\(viewModel.totalAchievements)")
                                }
                                
                                HStack {
                                    StatItem(title: "Hábitos Buenos", value: "\(viewModel.goodHabitsCount)")
                                    Spacer()
                                    StatItem(title: "Adicciones", value: "\(viewModel.addictionsCount)")
                                }
                                
                                HStack {
                                    StatItem(title: "Mejor Racha Buena", value: "\(viewModel.bestGoodHabitStreak)")
                                    Spacer()
                                    StatItem(title: "Mejor Racha Sin Adicción", value: "\(viewModel.bestAddictionStreak)")
                                }
                                
                                if let joinDate = viewModel.joinDate {
                                    StatItem(title: "Miembro desde", value: joinDate)
                                }
                            }
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(12)
                            
                            // Lista de hábitos
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Hábitos con Estadísticas (\(viewModel.habitsWithStats.count))")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                
                                if viewModel.habitsWithStats.isEmpty {
                                    Text("No hay hábitos para mostrar")
                                        .foregroundColor(.secondary)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                } else {
                                    ForEach(viewModel.habitsWithStats, id: \.id) { habit in
                                        HabitTestRow(habit: habit)
                                    }
                                }
                            }
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(12)
                            
                            // Registro de actividades
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Registro de Actividades")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                
                                if viewModel.recentActivities.isEmpty {
                                    Text("No hay actividades registradas")
                                        .foregroundColor(.secondary)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                } else {
                                    ForEach(Array(viewModel.recentActivities.keys.sorted().reversed().prefix(5)), id: \.self) { date in
                                        if let activity = viewModel.recentActivities[date] {
                                            HStack {
                                                Text(date)
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                                
                                                Spacer()
                                                
                                                Text("\(activity.completions) completados")
                                                    .font(.caption)
                                                    .foregroundColor(.green)
                                                
                                                if activity.hasRelapse {
                                                    Text("• Recaída")
                                                        .font(.caption)
                                                        .foregroundColor(.red)
                                                }
                                            }
                                            .padding(.vertical, 4)
                                        }
                                    }
                                }
                            }
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(12)
                        }
                        .padding()
                    }
                }
                
                Button("Recargar Estadísticas") {
                    Task {
                        await viewModel.loadAllStats()
                    }
                }
                .buttonStyle(.borderedProminent)
                .padding()
            }
            .navigationTitle("Test Estadísticas")
            .onAppear {
                Task {
                    await viewModel.loadAllStats()
                }
            }
        }
    }
}

struct StatItem: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.title3)
                .fontWeight(.semibold)
        }
    }
}

struct HabitTestRow: View {
    let habit: HabitWithStats
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(habit.nombre)
                    .font(.callout)
                    .fontWeight(.medium)
                
                Text(habitTypeText)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(habit.rachaActual)")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(habitColor)
                
                Text("días")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
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
    
    var habitColor: Color {
        switch habit.tipo {
        case .siNo, .medibleNumerico:
            return .green
        case .malHabito:
            return .red
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        private static let authViewModel: AuthViewModel = {
            let vm = AuthViewModel()
            vm.currentUser = User(id: "1", name: "Usuario de Prueba", email: "preview@test.com")
            return vm
        }()
        
        var body: some View {
            StatsTestView()
                .environmentObject(Self.authViewModel)
        }
    }
    
    return PreviewWrapper()
}