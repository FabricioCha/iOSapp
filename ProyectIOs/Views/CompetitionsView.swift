//
//  CompetitionsView.swift
//  ProyectIOs
//
//  Created by Fabricio Chavez on 05/01/25.
//

import SwiftUI

struct CompetitionsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "trophy.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.orange)
                
                Text("Competencias")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Compite con tus amigos y alcanza nuevos logros")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Spacer()
                
                VStack(spacing: 16) {
                    CompetitionFeatureRow(
                        icon: "person.2.fill",
                        title: "Desafíos con Amigos",
                        description: "Crea competencias personalizadas"
                    )
                    
                    CompetitionFeatureRow(
                        icon: "chart.bar.fill",
                        title: "Tablas de Clasificación",
                        description: "Ve tu progreso vs otros usuarios"
                    )
                    
                    CompetitionFeatureRow(
                        icon: "medal.fill",
                        title: "Logros y Recompensas",
                        description: "Desbloquea insignias especiales"
                    )
                }
                .padding()
                .background(Color.orange.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                
                Spacer()
                
                Text("Próximamente...")
                    .font(.title2)
                    .foregroundColor(.orange)
                    .padding()
                    .background(Color.orange.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                
                Spacer()
            }
            .padding()
            .navigationTitle("Competencias")
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

struct CompetitionFeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.orange)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

#Preview {
    CompetitionsView()
}