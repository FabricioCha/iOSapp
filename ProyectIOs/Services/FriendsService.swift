//
//  FriendsService.swift
//  ProyectIOs
//
//  Created by Trae AI on 2024.
//

import Foundation

class FriendsService: ObservableObject {
    private let baseURL = URL(string: "https://ery-app-turso.vercel.app/api")!
    
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        // No usar convertFromSnakeCase para friends ya que los modelos tienen CodingKeys manuales
        return decoder
    }()
    
    private let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        // No usar convertToSnakeCase para friends ya que los modelos tienen CodingKeys manuales
        return encoder
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
        
        if mutableRequest.httpMethod == "POST" || mutableRequest.httpMethod == "PUT" {
            mutableRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
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
    
    // MARK: - Friends Management
    
    /// Obtiene la lista de amigos del usuario autenticado
    func getFriends() async throws -> FriendsResponse {
        let url = baseURL.appendingPathComponent("friends")
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        return try await performRequest(for: request, expecting: FriendsResponse.self)
    }
    
    /// Elimina una amistad
    func deleteFriend(friendId: Int) async throws -> FriendActionResponse {
        let url = baseURL.appendingPathComponent("friends/\(friendId)")
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        return try await performRequest(for: request, expecting: FriendActionResponse.self)
    }
    
    // MARK: - Friend Activity & Achievements
    
    /// Obtiene la actividad de un amigo
    func getFriendActivity(friendId: Int) async throws -> FriendActivityResponse {
        // Obtener el mes y año actual
        let now = Date()
        let calendar = Calendar.current
        let year = calendar.component(.year, from: now)
        let month = calendar.component(.month, from: now)
        
        // Construir URL con parámetros de consulta
        var urlComponents = URLComponents(url: baseURL.appendingPathComponent("friends/\(friendId)/activity"), resolvingAgainstBaseURL: false)!
        urlComponents.queryItems = [
            URLQueryItem(name: "year", value: String(year)),
            URLQueryItem(name: "month", value: String(month))
        ]
        
        guard let url = urlComponents.url else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // Obtener la actividad diaria del backend
        let dailyResponse = try await performRequest(for: request, expecting: FriendDailyActivityResponse.self)
        
        // Convertir la respuesta del backend al formato esperado por la UI
        let activities = convertDailyActivityToFriendActivity(dailyResponse.activity, friendId: friendId, year: year, month: month)
        
        return FriendActivityResponse(
            success: dailyResponse.success,
            activities: activities,
            total: activities.count
        )
    }
    
    func getFriendStats(friendId: Int) async throws -> UserStats {
        let url = baseURL.appendingPathComponent("users/\(friendId)/stats")
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        return try await performRequest(for: request, expecting: UserStats.self)
    }
    
    private func convertDailyActivityToFriendActivity(_ dailyActivity: [String: DailyActivity], friendId: Int, year: Int, month: Int) -> [FriendActivity] {
        var activities: [FriendActivity] = []
        
        for (dateString, activity) in dailyActivity {
            if activity.completions > 0 {
                activities.append(FriendActivity(
                    id: "\(friendId)-\(dateString)-completions",
                    tipo: "habit_completed",
                    descripcion: "Completó \(activity.completions) hábito(s)",
                    fecha: "\(dateString) 12:00:00",
                    detalles: ["completions": String(activity.completions)]
                ))
            }
            
            if activity.hasRelapse {
                activities.append(FriendActivity(
                    id: "\(friendId)-\(dateString)-relapse",
                    tipo: "relapse",
                    descripcion: "Tuvo una recaída",
                    fecha: "\(dateString) 12:00:00",
                    detalles: ["hasRelapse": "true"]
                ))
            }
        }
        
        // Ordenar por fecha descendente (más reciente primero)
        return activities.sorted { $0.fecha > $1.fecha }
    }
    
    /// Obtiene los logros de un amigo
    func getFriendAchievements(friendId: Int) async throws -> FriendAchievementsResponse {
        let url = baseURL.appendingPathComponent("friends/\(friendId)/achievements")
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        return try await performRequest(for: request, expecting: FriendAchievementsResponse.self)
    }
    
    // MARK: - Friend Invitations
    
    /// Envía una solicitud de amistad
    func sendFriendInvitation(to userId: Int) async throws -> FriendActionResponse {
        let url = baseURL.appendingPathComponent("friends/invitations")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let invitationRequest = SendInvitationRequest(solicitadoId: userId)
        request.httpBody = try encoder.encode(invitationRequest)
        
        return try await performRequest(for: request, expecting: FriendActionResponse.self)
    }
    
    /// Obtiene las invitaciones pendientes (enviadas y recibidas)
    func getInvitations() async throws -> InvitationsResponse {
        let url = baseURL.appendingPathComponent("friends/invitations")
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        return try await performRequest(for: request, expecting: InvitationsResponse.self)
    }
    
    /// Responde a una solicitud de amistad (aceptar o rechazar)
    func respondToInvitation(invitationId: Int, action: String) async throws -> FriendActionResponse {
        let url = baseURL.appendingPathComponent("friends/invitations/\(invitationId)")
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        
        let responseRequest = RespondInvitationRequest(action: action)
        request.httpBody = try encoder.encode(responseRequest)
        
        return try await performRequest(for: request, expecting: FriendActionResponse.self)
    }
    
    // MARK: - User Search
    
    /// Busca usuarios para agregar como amigos
    func searchUsers(query: String) async throws -> UserSearchResponse {
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            throw APIError.invalidURL
        }
        
        var urlComponents = URLComponents()
        urlComponents.scheme = baseURL.scheme
        urlComponents.host = baseURL.host
        urlComponents.path = baseURL.path + "/users/search"
        urlComponents.queryItems = [URLQueryItem(name: "q", value: encodedQuery)]
        
        guard let url = urlComponents.url else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        return try await performRequest(for: request, expecting: UserSearchResponse.self)
    }
}