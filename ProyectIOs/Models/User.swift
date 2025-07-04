// ProyectIOs/Models/User.swift
import Foundation

// MARK: - CAMBIO 1: Modelo de Usuario principal de la App
// Este es el modelo que usará la aplicación internamente.
// El 'id' ahora es String para coincidir con la API.
struct User: Codable, Identifiable {
    let id: String
    var name: String // El nombre unificado para la app
    let email: String
    var unlockedBadgeIDs: [String]? //= []

    enum CodingKeys: String, CodingKey {
        case id, email, name
        case unlockedBadgeIDs
    }
}

// MARK: - CAMBIO 2: Nueva estructura para credenciales de registro
// Coincide con lo que espera tu endpoint /api/auth/register
struct SignupCredentials: Codable {
    let nombre: String
    let email: String
    let password: String
}

// MARK: - CAMBIO 3: Nueva estructura para la respuesta del login
// Coincide con la respuesta de /api/auth/token
struct AuthResponse: Codable {
    let token: String
    let user: User //LoginUserResponse
}

// Estructura anidada para el usuario en la respuesta de login
struct LoginUserResponse: Codable {
    let id: String
    let name: String
    let email: String
}

// MARK: - CAMBIO 4: Nueva estructura para la respuesta del registro
// Coincide con la respuesta de /api/auth/register
struct RegisterResponse: Codable {
    let message: String
    let user: RegisterUserResponse
}

// Estructura anidada para el usuario en la respuesta de registro
struct RegisterUserResponse: Codable {
    let id: String
    let nombre: String
    let email: String
}

// Credenciales de Login (sin cambios, ya debería existir)
struct LoginCredentials: Codable {
    let email: String
    let password: String
}

// MARK: - CAMBIO 5: Modelo para decodificar mensajes de error de la API
struct APIErrorResponse: Decodable {
    let message: String
}
