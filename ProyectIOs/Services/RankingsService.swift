//
//  RankingsService.swift
//  ProyectIOs
//
//  Created by Trae AI on 2024.
//

import Foundation

class RankingsService: ObservableObject {
    private let baseURL = URL(string: "https://ery-app-turso.vercel.app/api")!
    
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        // No usar convertFromSnakeCase ya que los modelos tienen CodingKeys manuales
        return decoder
    }()
    
    // MARK: - Private Request Helper
    
    private func performRequest<T: Decodable>(for request: URLRequest, withAuth: Bool = true, expecting: T.Type = T.self) async throws -> T {
        var mutableRequest = request
        
        if withAuth {
            guard let token = KeychainService.shared.getToken() else {
                throw APIError.requestFailed(description: "Auth token no disponible.")
            }
            mutableRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let (data, response) = try await URLSession.shared.data(for: mutableRequest)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            // Intenta decodificar el mensaje de error de la API
            if let apiError = try? decoder.decode(APIErrorResponse.self, from: data) {
                 throw APIError.serverError(statusCode: httpResponse.statusCode, description: apiError.message)
            }
            let errorDescription = String(data: data, encoding: .utf8) ?? "Sin descripción"
            throw APIError.serverError(statusCode: httpResponse.statusCode, description: errorDescription)
        }
        
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            print("Error de decodificación: \(error)")
            print("Datos recibidos: \(String(data: data, encoding: .utf8) ?? "No se pudo convertir a string")")
            throw APIError.decodingError(description: error.localizedDescription)
        }
    }
    
    // MARK: - Rankings Methods
    
    /// Obtiene los rankings globales o por país
    func getRankings(scope: RankingScope = .global, countryCode: String? = nil, limit: Int = 10) async throws -> RankingsResponse {
        var urlComponents = URLComponents()
        urlComponents.scheme = baseURL.scheme
        urlComponents.host = baseURL.host
        urlComponents.path = baseURL.path + "/rankings"
        
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "scope", value: scope.rawValue),
            URLQueryItem(name: "limit", value: String(limit))
        ]
        
        if scope == .country, let countryCode = countryCode {
            queryItems.append(URLQueryItem(name: "countryCode", value: countryCode))
        }
        
        urlComponents.queryItems = queryItems
        
        guard let url = urlComponents.url else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        return try await performRequest(for: request, expecting: RankingsResponse.self)
    }
}