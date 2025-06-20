//
//  GradientButton.swift
//  ProyectIOs
//
//  Created by Fabricio Chavez on 12/06/25.
//
import SwiftUI

// Un botón reutilizable que muestra nuestro gradiente de marca principal.
// Diseñado para las acciones más importantes de la aplicación.
struct GradientButton: View {
    
    // MARK: - Properties
    var title: String
    var icon: String? // El ícono es opcional.
    var action: () -> Void // Una clausura (closure) que se ejecutará al tocar el botón.
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                Text(title)
                
                // Solo mostramos la imagen si se proporcionó un nombre de ícono.
                if let iconName = icon {
                    Image(systemName: iconName)
                }
            }
            .fontWeight(.bold)
            .foregroundColor(Color.appTextPrimary) // Usamos nuestro color de texto definido.
            .padding(.vertical, 12)
            .padding(.horizontal, 35)
            // Usamos el gradiente que definimos en nuestra extensión de Color.
            .background(Color.primaryGradient)
            // Usamos .capsule para obtener bordes perfectamente redondeados.
            .clipShape(Capsule())
        }
    }
}

// Preview para ver cómo se ve el botón en el lienzo de Xcode.
#Preview {
    VStack {
        GradientButton(title: "Iniciar Sesión", icon: "arrow.right") {
            print("Botón presionado!")
        }
    }
    .padding()
    .background(Color.appBackground)
}
