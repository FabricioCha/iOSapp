//
//  APIError.swift
//  ProyectIOs
//
//  Created by Fabricio Chavez on 20/06/25.
//

import Foundation

// Define los posibles errores que nuestra API puede devolver.
// Esto nos ayuda a manejar los problemas de forma más clara en la UI.
enum APIError: Error, LocalizedError {
    case invalidURL
    case requestFailed(description: String)
    case invalidResponse
    case decodingError(description: String)
    case encodingError
    case serverError(statusCode: Int, description: String)
    case unknownError

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "La URL de la API no es válida."
        case .requestFailed(let description):
            return "Falló la solicitud: \(description)"
        case .invalidResponse:
            return "Respuesta inválida del servidor."
        case .decodingError(let description):
            return "Error al procesar la respuesta: \(description)"
        case .encodingError:
            return "Error al codificar los datos de la solicitud."
        case .serverError(let statusCode, let description):
            return "Error del servidor (\(statusCode)): \(description)"
        case .unknownError:
            return "Ocurrió un error desconocido."
        }
    }
}
