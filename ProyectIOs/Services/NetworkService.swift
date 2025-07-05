import Foundation

// --- Structs para el cuerpo de las solicitudes ---

struct CreateHabitRequest: Encodable {
    let nombre: String
    let tipo: ApiHabitType
    let descripcion: String?
    let meta_objetivo: Double?
}

// --- STRUCT CORREGIDA: Se añade el campo que faltaba ---
struct UpdateProfileRequest: Encodable {
    let nombre: String?
    let contraseñaActual: String?
    let nuevaContraseña: String?
    // Este campo ahora se enviará a la API
    let confirmarNuevaContraseña: String?
}


// --- Structs para las respuestas de la API ---

struct HabitLogResponse: Decodable {
    let completionDates: [String]
}

struct MessageResponse: Decodable {
    let message: String
}

struct CreateHabitResponse: Codable {
    let habit: Habit
}


class NetworkService {
    
    static let shared = NetworkService()
    
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

    // MARK: - Profile Endpoints
    
    func fetchUserProfile() async throws -> UserProfile {
        let url = baseURL.appendingPathComponent("profile")
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        return try await performRequest(for: request, withAuth: true)
    }
    
    // --- FUNCIÓN CORREGIDA: Se construye el cuerpo de la petición correctamente ---
    func updateUserProfile(name: String?, currentPassword: String?, newPassword: String?, confirmNewPassword: String?) async throws {
        let url = baseURL.appendingPathComponent("profile")
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        
        let body = UpdateProfileRequest(
            nombre: name,
            contraseñaActual: currentPassword,
            nuevaContraseña: newPassword,
            confirmarNuevaContraseña: confirmNewPassword // Ahora se incluye en la petición
        )
        
        request.httpBody = try encoder.encode(body)
        
        _ = try await performRequest(for: request, withAuth: true, expecting: MessageResponse.self)
    }

    // MARK: - Habit Endpoints
    
    func fetchHabits() async throws -> [Habit] {
        let url = baseURL.appendingPathComponent("habits")
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let response = try await performRequest(for: request, withAuth: true, expecting: HabitListResponse.self)
        return response.habits
    }

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

    func deleteHabit(habitId: Int) async throws {
        let url = baseURL.appendingPathComponent("habits/\(habitId)")
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        _ = try await performRequest(for: request, withAuth: true, expecting: MessageResponse.self)
    }

    func logHabitProgress(log: HabitLogRequest) async throws {
        let url = baseURL.appendingPathComponent("habits/log")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try encoder.encode(log)
        _ = try await performRequest(for: request, withAuth: true, expecting: MessageResponse.self)
    }

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
}
