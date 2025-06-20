//
//  CustomTabBar.swift
//  ProyectIOs
//
//  Created by Fabricio Chavez on 15/06/25.
//

import SwiftUI

struct CustomTabBar: View {
    // Binding a la pestaña seleccionada en la vista padre (MainTabView).
    @Binding var selectedTab: Tab
    
    // Binding para controlar si se muestra la hoja de creación.
    @Binding var isAddingHabit: Bool

    var body: some View {
        HStack {
            // Iteramos sobre todos los casos de nuestro enum Tab.
            ForEach(Tab.allCases, id: \.self) { tab in
                
                Spacer()
                
                if tab == .add {
                    // Botón especial para añadir hábito.
                    Button {
                        isAddingHabit = true
                    } label: {
                        Image(systemName: tab.rawValue)
                            .font(.largeTitle)
                            .foregroundColor(.white)
                            .padding(15)
                            .background(Color.appPrimaryAction)
                            .clipShape(Circle())
                            .shadow(color: .appPrimaryAction.opacity(0.5), radius: 5, y: 3)
                    }
                    // Lo movemos un poco hacia arriba para que destaque.
                    .offset(y: -25)
                    
                } else {
                    // Botones de pestañas normales.
                    Button {
                        // Cambiamos la pestaña seleccionada con una animación suave.
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedTab = tab
                        }
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: tab.rawValue)
                                .font(.title2)
                            
                            Text(tab.title)
                                .font(.caption)
                        }
                        // Cambia de color si la pestaña está seleccionada.
                        .foregroundColor(selectedTab == tab ? Color.appPrimaryAction : .gray)
                    }
                }
                
                Spacer()
            }
        }
        .padding(.top, 10)
        .frame(maxWidth: .infinity, minHeight: 80) // Damos una altura mínima
        .background(Color.appBackground.opacity(0.95))
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: -2)
    }
}

// Añadimos una propiedad computada a nuestro enum Tab para obtener un título legible.
extension Tab {
    var title: String {
        switch self {
        case .home:
            return "Inicio"
        case .stats:
            return "Progreso"
        case .add:
            return ""
        case .quotes:
            return "Frases"
        case .profile:
            return "Perfil"
        }
    }
}


#Preview {
    struct PreviewWrapper: View {
        @State private var selectedTab: Tab = .home
        @State private var isAddingHabit = false
        var body: some View {
            VStack {
                Spacer()
                Text("Contenido de la Vista")
                Spacer()
                CustomTabBar(selectedTab: $selectedTab, isAddingHabit: $isAddingHabit)
            }
            .background(Color.gray.opacity(0.2))
        }
    }
    return PreviewWrapper()
}
