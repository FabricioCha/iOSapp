//
//  BadgesView.swift
//  ProyectIOs
//
//  Created by Fabricio Chavez on 17/06/25.
//

import SwiftUI

// Vista que muestra la colección completa de insignias del usuario.
struct BadgesView: View {
    
    // ViewModel para acceder a la información del usuario actual, incluyendo sus insignias.
    @EnvironmentObject var authViewModel: AuthViewModel
    
    // Cargamos todas las insignias posibles desde el archivo local badges.json.
    // Esto se hace una sola vez gracias a la clausura perezosa.
    private let allBadges: [Badge] = {
        do {
            guard let fileUrl = Bundle.main.url(forResource: "badges", withExtension: "json") else {
                print("Error: No se encontró badges.json en el bundle.")
                return []
            }
            let data = try Data(contentsOf: fileUrl)
            return try JSONDecoder().decode([Badge].self, from: data)
        } catch {
            print("Error al decodificar badges.json: \(error)")
            return []
        }
    }()
    
    // Define el layout de la cuadrícula: 3 columnas de tamaño flexible.
    private let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        // Obtenemos un Set con los IDs de las insignias desbloqueadas para una búsqueda eficiente.
        let unlockedBadgeIDs = Set(authViewModel.currentUser?.unlockedBadgeIDs ?? [])
        
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Tu Colección")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Aquí puedes ver todas las insignias que has ganado y las que te quedan por descubrir.")
                        .foregroundStyle(Color.appTextSecondary)
                    
                    // Cuadrícula que muestra todas las insignias.
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(allBadges) { badge in
                            // Comprobamos si la insignia actual está desbloqueada.
                            let isUnlocked = unlockedBadgeIDs.contains(badge.id)
                            
                            BadgeCellView(badge: badge, isUnlocked: isUnlocked)
                        }
                    }
                }
                .padding()
            }
            .foregroundColor(Color.appTextPrimary)
            .navigationTitle("Insignias")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Celda para una Sola Insignia

// Vista reutilizable que representa una única insignia en la cuadrícula.
struct BadgeCellView: View {
    let badge: Badge
    let isUnlocked: Bool
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: badge.iconName)
                .font(.largeTitle)
                .padding()
                .background(
                    Circle()
                        .fill(isUnlocked ? Color.appPrimaryAction.opacity(0.3) : Color.gray.opacity(0.1))
                )
            
            Text(badge.name)
                .font(.headline)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Text(badge.description)
                .font(.caption2)
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.appTextSecondary)
                .frame(height: 50) // Altura fija para alinear las celdas de la cuadrícula
        }
        .padding(10)
        .background(Color.gray.opacity(0.15))
        .cornerRadius(15)
        // Aplicamos los efectos visuales si la insignia está bloqueada.
        .grayscale(isUnlocked ? 0 : 1)
        .opacity(isUnlocked ? 1 : 0.6)
        .animation(.easeInOut, value: isUnlocked)
    }
}


// MARK: - Preview

#Preview {
    // Creamos un entorno simulado para la previsualización.
    struct PreviewWrapper: View {
        // Creamos una instancia del AuthViewModel para la preview.
        private static let authViewModel: AuthViewModel = {
            let vm = AuthViewModel()
            // Simulamos un usuario con algunas insignias desbloqueadas.
            vm.currentUser = User(
                id: "previewUser",
                nombre: "Usuario de Prueba",
                email: "preview@test.com",
                unlockedBadgeIDs: ["first_habit_completed", "three_day_streak"]
            )
            return vm
        }()
        
        var body: some View {
            NavigationStack {
                BadgesView()
                    .environmentObject(Self.authViewModel)
            }
        }
    }
    
    return PreviewWrapper()
}
