//
//  User.swift
//  ProyectIOs
//
//  Created by Fabricio Chavez on 16/06/25.
//

import Foundation

// Modelo de Usuario adaptado para la API.
// Ya no contiene la contraseña, ya que la API no la devuelve por seguridad.
struct User: Identifiable, Codable {
    let id: String // La API probablemente use String o Int para los IDs.
    let nombre: String
    let email: String
    
    // Este campo lo mantendremos de momento para la gamificación,
    // pero no será guardado ni leído desde la API. Lo gestionaremos localmente.
    var unlockedBadgeIDs: [String] = []

    enum CodingKeys: String, CodingKey {
        case id, nombre, email
    }
}

// Estructura para la respuesta de login/registro si la API devuelve el usuario.
struct AuthResponse: Codable {
    let user: User
    let token: String // Suponiendo que la API devuelve el token aquí.
}
