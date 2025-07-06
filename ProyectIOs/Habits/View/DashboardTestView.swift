//
//  DashboardTestView.swift
//  ProyectIOs
//
//  Created for Dashboard Testing
//

import SwiftUI

struct DashboardTestView: View {
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var dashboardData: DashboardData?
    @State private var logs: [String] = []
    
    private let networkService = NetworkService.shared
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                
                // Test Button
                Button("Probar Dashboard API") {
                    Task {
                        await testDashboardAPI()
                    }
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .background(Color.blue)
                .cornerRadius(10)
                .disabled(isLoading)
                
                if isLoading {
                    ProgressView("Cargando...")
                        .padding()
                }
                
                // Results Section
                if let error = errorMessage {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Error:")
                            .font(.headline)
                            .foregroundColor(.red)
                        
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding()
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
                
                if let data = dashboardData {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Éxito:")
                            .font(.headline)
                            .foregroundColor(.green)
                        
                        Text("Hábitos encontrados: \(data.habitsConEstadisticas.count)")
                            .font(.callout)
                        
                        ForEach(data.habitsConEstadisticas.prefix(3), id: \.id) { habit in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(habit.nombre)
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                Text("Tipo: \(habit.tipo.rawValue), Racha: \(habit.rachaActual)")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            .padding(8)
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(6)
                        }
                    }
                }
                
                // Logs Section
                if !logs.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Logs:")
                            .font(.headline)
                        
                        ScrollView {
                            LazyVStack(alignment: .leading, spacing: 4) {
                                ForEach(logs.indices, id: \.self) { index in
                                    Text(logs[index])
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .frame(maxHeight: 200)
                        .padding(8)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Dashboard Test")
        }
    }
    
    private func testDashboardAPI() async {
        isLoading = true
        errorMessage = nil
        dashboardData = nil
        logs = []
        
        addLog("Iniciando prueba de Dashboard API...")
        
        // Check auth token
        let hasToken = KeychainService.shared.getToken() != nil
        addLog("Token disponible: \(hasToken)")
        
        if let token = KeychainService.shared.getToken() {
            addLog("Token: \(String(token.prefix(20)))...")
        }
        
        // Check network connectivity
        do {
            let url = URL(string: "https://www.google.com")!
            let (_, response) = try await URLSession.shared.data(from: url)
            if let httpResponse = response as? HTTPURLResponse {
                addLog("Conectividad: \(httpResponse.statusCode == 200 ? "OK" : "Error")")
            }
        } catch {
            addLog("Error de conectividad: \(error.localizedDescription)")
        }
        
        // Test dashboard API
        do {
            addLog("Llamando a fetchDashboardData()...")
            let data = try await networkService.fetchDashboardData()
            addLog("API exitosa - Hábitos: \(data.habitsConEstadisticas.count)")
            
            dashboardData = data
            
        } catch {
            addLog("Error en API: \(error)")
            errorMessage = error.localizedDescription
            
            if let apiError = error as? APIError {
                addLog("Tipo de error API: \(apiError)")
            }
        }
        
        isLoading = false
    }
    
    private func addLog(_ message: String) {
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
        logs.append("[\(timestamp)] \(message)")
    }
}

#Preview {
    DashboardTestView()
}