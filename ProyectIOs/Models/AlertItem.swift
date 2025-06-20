//
//  AlertItem.swift
//  ProyectIOs
//
//  Created by Fabricio Chavez on 20/06/25.
//

import Foundation
import SwiftUI

// Estructura para definir el contenido de una alerta.
// Hacemos que sea Identifiable para que el modificador .alert() de SwiftUI pueda usarla.
struct AlertItem: Identifiable {
    let id = UUID()
    let title: Text
    let message: Text
    let dismissButton: Alert.Button
    
    // Alerta genérica para errores de red.
    static func from(error: Error) -> AlertItem {
        return AlertItem(
            title: Text("Error de Red"),
            message: Text(error.localizedDescription),
            dismissButton: .default(Text("OK"))
        )
    }
}
