import Foundation

// --- NUEVO: Struct para el cuerpo de la solicitud de creación de hábito ---
struct CreateHabitRequest: Encodable {
    let nombre: String
    let tipo: ApiHabitType
    let descripcion: String?
    let meta_objetivo: Double?
}

// --- NUEVO: Struct para la respuesta de logs de hábitos ---
struct HabitLogResponse: Decodable {
    let completionDates: [String]
}

// --- NUEVO: Struct para respuestas simples con mensaje ---
struct MessageResponse: Decodable {
    let message: String
}

// --- NUEVO: Struct para la respuesta de creación de hábito ---
struct CreateHabitResponse: Codable {
    let habit: Habit
}

class NetworkService {
    
    static let shared = NetworkService()
    
    // MARK: - Configuración base
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
        let url = baseURL.appendingPathComponent("auth/token")
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
        let response = try await performRequest(for: request, withAuth: true, expecting: HabitListResponse.self)
        return response.habits
    }

    /// Crea un nuevo hábito para el usuario autenticado.
    func createHabit(nombre: String, tipo: ApiHabitType, descripcion: String?, metaObjetivo: Double?) async throws -> Habit {
        let url = baseURL.appendingPathComponent("habits")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let requestBody = CreateHabitRequest(
            nombre: nombre,
            tipo: tipo,
            descripcion: descripcion,
            meta_objetivo: metaObjetivo
        )
        
        request.httpBody = try encoder.encode(requestBody)
        
        let response = try await performRequest(for: request, withAuth: true, expecting: CreateHabitResponse.self)
        return response.habit
    }

    // CORREGIDO: Ahora maneja correctamente la respuesta JSON del DELETE
    func deleteHabit(habitId: Int) async throws {
        let url = baseURL.appendingPathComponent("habits/\(habitId)")
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        // Cambiado para esperar MessageResponse en lugar de Data
        _ = try await performRequest(for: request, withAuth: true, expecting: MessageResponse.self)
    }

    // CORREGIDO: Ahora maneja correctamente la respuesta JSON del POST
    func logHabitProgress(log: HabitLogRequest) async throws {
        let url = baseURL.appendingPathComponent("habits/log")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try encoder.encode(log)
        // Cambiado para esperar MessageResponse en lugar de Data
        _ = try await performRequest(for: request, withAuth: true, expecting: MessageResponse.self)
    }

    /// --- NUEVO: Obtener logs de un hábito por ID ---
    func fetchLogs(for habitID: Int) async throws -> HabitLogResponse {
        let url = baseURL.appendingPathComponent("habits/\(habitID)/logs")
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        return try await performRequest(for: request, withAuth: true, expecting: HabitLogResponse.self)
    }
    
    // MARK: - Dashboard Endpoint
    
    func fetchDashboardData() async throws -> DashboardData {
        let url = baseURL.appendingPathComponent("dashboard")
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        return try await performRequest(for: request, withAuth: true)
    }
    
    // MARK: - Private Request Helper
    
    private func performRequest<T: Decodable>(for request: URLRequest, withAuth: Bool = false, expecting: T.Type = T.self) async throws -> T {
        var mutableRequest = request
        
        if withAuth {
            guard let token = getAuthToken() else {
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

        if let jsonString = String(data: data, encoding: .utf8) {
            print("Respuesta JSON recibida: \(jsonString)")
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            let errorDescription = String(data: data, encoding: .utf8) ?? "Sin descripción"
            throw APIError.serverError(statusCode: httpResponse.statusCode, description: errorDescription)
        }
        
        // CORREGIDO: Eliminado el manejo especial para Data.self que causaba problemas
        // Ahora todos los endpoints devuelven respuestas JSON estructuradas
        
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            print("Error de decodificación: \(error)")
            print("Datos recibidos: \(String(data: data, encoding: .utf8) ?? "No se pudo convertir a string")")
            throw APIError.decodingError(description: error.localizedDescription)
        }
    }
}
