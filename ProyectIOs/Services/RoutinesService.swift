//
//  RoutinesService.swift
//  ProyectIOs
//
//  Created by Trae AI on 2024.
//

import Foundation

class RoutinesService {
    
    static let shared = RoutinesService()
    
    private let baseURL = URL(string: "https://ery-app-turso.vercel.app/api")!
    private let keychainService = KeychainService.shared
    
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        // Removido .convertFromSnakeCase porque usamos CodingKeys manuales
        return decoder
    }()
    
    private let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        // Removido .convertToSnakeCase porque usamos CodingKeys manuales
        return encoder
    }()
    
    private init() {}
    
    private func getAuthToken() -> String? {
        return keychainService.getToken()
    }
    
    // MARK: - Routines Management
    
    /// Obtiene todas las rutinas del usuario
    func fetchRoutines() async throws -> RoutinesResponse {
        let url = baseURL.appendingPathComponent("routines")
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        return try await performRequest(for: request, withAuth: true, expecting: RoutinesResponse.self)
    }
    
    /// Crea una nueva rutina
    func createRoutine(nombre: String, descripcion: String?) async throws -> Routine {
        let url = baseURL.appendingPathComponent("routines")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let requestBody = CreateRoutineRequest(
            nombre: nombre,
            descripcion: descripcion
        )
        
        request.httpBody = try encoder.encode(requestBody)
        
        let response = try await performRequest(for: request, withAuth: true, expecting: CreateRoutineResponse.self)
        return response.routine
    }
    
    /// Obtiene los detalles de una rutina específica
    func fetchRoutineDetails(routineId: Int) async throws -> RoutineDetails {
        let url = baseURL.appendingPathComponent("routines/\(routineId)")
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        return try await performRequest(for: request, withAuth: true, expecting: RoutineDetails.self)
    }
    
    /// Actualiza una rutina existente
    func updateRoutine(routineId: Int, nombre: String?, descripcion: String?) async throws {
        let url = baseURL.appendingPathComponent("routines/\(routineId)")
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        
        let requestBody = UpdateRoutineRequest(
            nombre: nombre,
            descripcion: descripcion
        )
        
        request.httpBody = try encoder.encode(requestBody)
        
        _ = try await performRequest(for: request, withAuth: true, expecting: MessageResponse.self)
    }
    
    /// Elimina una rutina
    func deleteRoutine(routineId: Int) async throws -> MessageResponse {
        let url = baseURL.appendingPathComponent("routines/\(routineId)")
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        return try await performRequest(for: request, withAuth: true, expecting: MessageResponse.self)
    }
    
    // MARK: - Habit Association
    
    /// Asocia un hábito a una rutina
    func addHabitToRoutine(routineId: Int, habitId: Int) async throws -> MessageResponse {
        let url = baseURL.appendingPathComponent("routines/\(routineId)/habits")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let requestBody = AddHabitToRoutineRequest(habitId: habitId)
        request.httpBody = try encoder.encode(requestBody)
        
        return try await performRequest(for: request, withAuth: true, expecting: MessageResponse.self)
    }
    
    /// Desasocia un hábito de una rutina
    func removeHabitFromRoutine(routineId: Int, habitId: Int) async throws -> MessageResponse {
        let url = baseURL.appendingPathComponent("routines/\(routineId)/habits")
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        let requestBody = RemoveHabitFromRoutineRequest(habitId: habitId)
        request.httpBody = try encoder.encode(requestBody)
        
        return try await performRequest(for: request, withAuth: true, expecting: MessageResponse.self)
    }
    
    // MARK: - Private Helper Methods
    
    private func performRequest<T: Decodable>(for request: URLRequest, withAuth: Bool = false, expecting: T.Type = T.self) async throws -> T {
        var mutableRequest = request
        
        if withAuth {
            guard let token = getAuthToken() else {
                throw APIError.requestFailed(description: "Auth token no disponible.")
            }
            mutableRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if mutableRequest.httpMethod == "POST" || mutableRequest.httpMethod == "PUT" || mutableRequest.httpMethod == "DELETE" {
            mutableRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        let (data, response) = try await URLSession.shared.data(for: mutableRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        if let jsonString = String(data: data, encoding: .utf8) {
            print("Respuesta JSON recibida (Routines): \(jsonString)")
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            do {
                return try decoder.decode(T.self, from: data)
            } catch {
                print("Error de decodificación: \(error)")
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("JSON que causó el error: \(jsonString)")
                }
                throw APIError.decodingError(description: error.localizedDescription)
            }
        case 400:
            throw APIError.serverError(statusCode: 400, description: "Solicitud inválida")
        case 401:
            throw APIError.serverError(statusCode: 401, description: "No autorizado")
        case 403:
            throw APIError.serverError(statusCode: 403, description: "Prohibido")
        case 404:
            throw APIError.serverError(statusCode: 404, description: "No encontrado")
        case 409:
            throw APIError.serverError(statusCode: 409, description: "Conflicto")
        case 500...599:
            throw APIError.serverError(statusCode: httpResponse.statusCode, description: "Error del servidor")
        default:
            throw APIError.requestFailed(description: "Error HTTP \(httpResponse.statusCode)")
        }
    }
}