// ProyectIOs/Models/User.swift
import Foundation

// MARK: - Modelo de Sesión (para Login/Registro)
/// Representa al usuario autenticado en la sesión. Se utiliza para la respuesta de /api/auth/token.
struct User: Codable, Identifiable {
    let id: String
    var name: String
    let email: String
    var unlockedBadgeIDs: [String]?

    enum CodingKeys: String, CodingKey {
        case id, email, name
        case unlockedBadgeIDs
    }
}

// MARK: - Modelo de Perfil (para la vista de Perfil)
/// Representa la estructura de datos del perfil de un usuario tal como la devuelve el endpoint GET /api/profile.
struct UserProfile: Codable, Identifiable {
    let id: Int
    let nombre: String
    let email: String
    
    // --- CAMBIO CLAVE: Hacer más campos opcionales para evitar errores de decodificación ---
    let rol: String?
    let fechaCreacion: String? // Ahora es opcional
    let ultimoLogin: String?
    let estado: String?        // Ahora es opcional
    let suspensionFin: String?

    // Mapea las claves snake_case del JSON a camelCase en Swift.
    enum CodingKeys: String, CodingKey {
        case id, nombre, email, rol, estado
        case fechaCreacion = "fecha_creacion"
        case ultimoLogin = "ultimo_login"
        case suspensionFin = "suspension_fin"
    }
}


// MARK: - Estructuras de Soporte para Autenticación

struct SignupCredentials: Codable {
    let nombre: String
    let email: String
    let password: String
}

struct AuthResponse: Codable {
    let token: String
    let user: User
}

struct RegisterResponse: Codable {
    let message: String
    let user: RegisterUserResponse
}

struct RegisterUserResponse: Codable {
    let id: String
    let nombre: String
    let email: String
}

struct LoginCredentials: Codable {
    let email: String
    let password: String
}

struct APIErrorResponse: Decodable {
    let message: String
}
