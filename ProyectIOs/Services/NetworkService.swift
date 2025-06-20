//
//  NetworkService.swift
//  ProyectIOs
//
//  Created by Fabricio Chavez on 20/06/25.
//

import Foundation

class NetworkService {
    
    static let shared = NetworkService()
    
    // IMPORTANTE: Reemplaza esta URL con la URL base de tu API.
    private let baseURL = URL(string: "https://ery-app-turso.vercel.app/api")!
    
    private let keychainService = KeychainService.shared
    
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    
    private let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }()
    
    private init() {}

    func setAuthToken(_ token: String?) {
        if let token = token {
            keychainService.saveToken(token)
        } else {
            keychainService.deleteToken()
        }
    }
    
    private func getAuthToken() -> String? {
        return keychainService.getToken()
    }
    
    // MARK: - Auth Endpoints
    
    func register(nombre: String, email: String, password: String) async throws -> AuthResponse {
        let url = baseURL.appendingPathComponent("auth/register")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let body = ["nombre": nombre, "email": email, "password": password]
        request.httpBody = try JSONEncoder().encode(body)
        return try await performRequest(for: request)
    }

    func login(email: String, password: String) async throws -> AuthResponse {
        let url = baseURL.appendingPathComponent("auth/callback/credentials")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let body = ["email": email, "password": password]
        request.httpBody = try JSONEncoder().encode(body)
        return try await performRequest(for: request)
    }
    
    func fetchCurrentUser() async throws -> User {
        let url = baseURL.appendingPathComponent("auth/session")
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        return try await performRequest(for: request, withAuth: true)
    }

    // MARK: - Habit Endpoints
    
    func fetchHabits() async throws -> [Habit] {
        let url = baseURL.appendingPathComponent("habits")
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        return try await performRequest(for: request, withAuth: true)
    }

    func createHabit(nombre: String, tipo: ApiHabitType, descripcion: String?, metaObjetivo: String?) async throws -> Habit {
        let url = baseURL.appendingPathComponent("habits")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let body = ["nombre": nombre, "tipo": tipo.rawValue, "descripcion": descripcion, "meta_objetivo": metaObjetivo]
        request.httpBody = try encoder.encode(body.compactMapValues { $0 })
        return try await performRequest(for: request, withAuth: true)
    }
    
    func deleteHabit(habitId: String) async throws {
        let url = baseURL.appendingPathComponent("habits/\(habitId)")
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        _ = try await performRequest(for: request, withAuth: true, expecting: Data.self)
    }

    func logHabitProgress(log: HabitLogRequest) async throws {
        let url = baseURL.appendingPathComponent("habits/log")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try encoder.encode(log)
        _ = try await performRequest(for: request, withAuth: true, expecting: Data.self)
    }
    
    // MARK: - Dashboard Endpoint
    
    func fetchDashboardData() async throws -> DashboardData {
        let url = baseURL.appendingPathComponent("dashboard")
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        return try await performRequest(for: request, withAuth: true)
    }
    
    // MARK: - Habit Log Endpoint (Nuevo)
    
    /// Obtiene el historial de completados para un hábito específico.
    func fetchLogs(for habitId: String) async throws -> HabitLogResponse {
        let url = baseURL.appendingPathComponent("habits/\(habitId)/logs")
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        return try await performRequest(for: request, withAuth: true)
    }
    
    // MARK: - Private Helper
    
    private func performRequest<T: Decodable>(for request: URLRequest, withAuth: Bool = false, expecting: T.Type = T.self) async throws -> T {
        var mutableRequest = request
        
        if withAuth {
            guard let token = getAuthToken() else {
                throw APIError.requestFailed(description: "Auth token no disponible. Por favor, inicie sesión.")
            }
            mutableRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if mutableRequest.httpMethod == "POST" || mutableRequest.httpMethod == "PUT" {
            mutableRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        let (data, response) = try await URLSession.shared.data(for: mutableRequest)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            let errorDescription = String(data: data, encoding: .utf8) ?? "Sin descripción"
            throw APIError.serverError(statusCode: httpResponse.statusCode, description: errorDescription)
        }
        
        if T.self == Data.self {
            return Data() as! T
        }
        
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            print("Error de decodificación: \(error)")
            throw APIError.decodingError(description: error.localizedDescription)
        }
    }
}
