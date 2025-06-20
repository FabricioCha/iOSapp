//
//  StatsView.swift
//  ProyectIOs
//
//  Created by Fabricio Chavez on 16/06/25.
//

import SwiftUI

struct StatsView: View {
    
    @StateObject private var viewModel = StatsViewModel()
    
    private let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            if viewModel.isLoading {
                ProgressView()
            } else if let errorMessage = viewModel.errorMessage {
                VStack {
                    Text("Error")
                        .font(.largeTitle)
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                    Button("Reintentar") {
                        viewModel.fetchGlobalStats()
                    }
                    .buttonStyle(.borderedProminent)
                }
            } else {
                ScrollView {
                    VStack(spacing: 20) {
                        Text("Tu Progreso")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .hSpacing(.leading)
                        
                        // El CircularProgressView ahora muestra la mejor racha.
                        CircularProgressView(progress: Double(viewModel.longestStreak) / 30.0, text: "\(viewModel.longestStreak)")
                            .frame(width: 180, height: 180)
                            .padding(.vertical, 20)

                        LazyVGrid(columns: columns, spacing: 16) {
                            StatCardView(title: "Racha Actual", value: "\(viewModel.currentStreak)", iconName: "flame.fill", color: .orange)
                            StatCardView(title: "Mejor Racha", value: "\(viewModel.longestStreak)", iconName: "crown.fill", color: .yellow)
                            StatCardView(title: "Total Completado", value: "\(viewModel.totalCompletions)", iconName: "checkmark.circle.fill", color: .green)
                            StatCardView(title: "Tasa de Éxito", value: "\(Int((viewModel.overallCompletionRate * 100).rounded()))%", iconName: "chart.bar.xaxis", color: .blue)
                        }
                    }
                    .padding()
                }
            }
        }
        .foregroundColor(Color.appTextPrimary)
        .onAppear {
            viewModel.fetchGlobalStats()
        }
    }
}

// MARK: - Componentes Reutilizables (Restaurados)

/// Una tarjeta para mostrar una estadística individual.
struct StatCardView: View {
    let title: String
    let value: String
    let iconName: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: iconName)
                    .font(.title2)
                    .foregroundColor(color)
                Spacer()
            }
            
            Text(title)
                .font(.caption)
                .foregroundColor(Color.appTextSecondary)
            
            Text(value)
                .font(.title)
                .fontWeight(.bold)
        }
        .padding()
        .background(Color.gray.opacity(0.15))
        .cornerRadius(15)
    }
}

/// Una vista que dibuja un gráfico de progreso circular.
struct CircularProgressView: View {
    let progress: Double // Valor entre 0.0 y 1.0
    let text: String
    
    var body: some View {
        ZStack {
            // Círculo de fondo
            Circle()
                .stroke(lineWidth: 20.0)
                .opacity(0.2)
                .foregroundColor(Color.appPrimaryAction)
            
            // Círculo de progreso
            Circle()
                .trim(from: 0.0, to: min(progress, 1.0))
                .stroke(style: StrokeStyle(lineWidth: 20.0, lineCap: .round, lineJoin: .round))
                .fill(Color.primaryGradient)
                .rotationEffect(Angle(degrees: 270.0)) // Empezar desde arriba
            
            // Texto en el centro
            Text(text)
                .font(.largeTitle)
                .fontWeight(.bold)
        }
    }
}

// MARK: - Preview

#Preview {
    StatsView()
}
