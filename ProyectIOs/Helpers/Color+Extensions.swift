//
//  Color+Extensions.swift
//  ProyectIOs
//
//  Created by Fabricio Chavez on 16/06/25.
//

import Foundation
import SwiftUI

// Extendemos la estructura Color para añadir nuestra paleta de colores personalizada.
// Esto nos permite tener un único lugar para gestionar los colores de la app.
extension Color {
    
    // MARK: - Colores Base
    static let appBackground = Color("Background")
    static let appPrimaryAction = Color("PrimaryAction")
    static let appPrimaryActionGradientEnd = Color("PrimaryActionGradientEnd")
    
    // MARK: - Colores de UI
    static let appTextPrimary = Color.white
    static let appTextSecondary = Color.gray
    static let appSuccess = Color.green
    static let appError = Color.red
    static let appAccent = Color("AccentColor")
    static let appCardBackground = Color.gray.opacity(0.15)
    
    // MARK: - Gradientes
    /// El gradiente principal para todos los botones de acción importantes.
    static var primaryGradient: LinearGradient {
        LinearGradient(
            colors: [appPrimaryAction, appPrimaryActionGradientEnd],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}


// NOTA IMPORTANTE:
// Los colores definidos como Color("Nombre") requieren que estos colores
// sean añadidos en el catálogo de Assets (Assets.xcassets).
// Para este ejemplo, deberías crear un nuevo "Color Set" en tus Assets
// con los nombres "Background", "PrimaryAction", y "PrimaryActionGradientEnd"
// y asignarles los valores que desees.

// Valores de ejemplo que puedes usar:
// - Background: Un azul muy oscuro (Hex: #1A1A2E)
// - PrimaryAction: Un azul brillante (Hex: #3D52D5)
// - PrimaryActionGradientEnd: Un púrpura (Hex: #7B2CBF)
