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

// --- Nuevos structs para gestión de perfil ---
struct UserBasicInfo: Codable {
    let id: Int
    let nombre: String
    let email: String
    let fechaCreacion: String
    
    enum CodingKeys: String, CodingKey {
        case id, nombre, email
        case fechaCreacion = "fecha_creacion"
    }
}

struct UserBasicInfoResponse: Codable {
    let success: Bool
    let user: UserBasicInfo
}

struct UserDetails: Codable {
    let id: Int
    let nombre: String
    let apellido: String?
    let email: String
}

struct UserDetailsResponse: Codable {
    let user: UserDetails
}

struct UpdateUserDetailsRequest: Encodable {
    let nombre: String?
    let apellido: String?
    let email: String?
    let password: String?
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
    
    // MARK: - User Management Endpoints
    
    /// Obtiene información básica de un usuario específico
    func fetchUserBasicInfo(userId: Int) async throws -> UserBasicInfo {
        let url = baseURL.appendingPathComponent("users/\(userId)")
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let response = try await performRequest(for: request, withAuth: true, expecting: UserBasicInfoResponse.self)
        return response.user
    }
    
    /// Obtiene detalles completos de un usuario específico (requiere permisos de administrador)
    func fetchUserDetails(userId: Int) async throws -> UserDetails {
        let url = baseURL.appendingPathComponent("users/\(userId)/details")
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let response = try await performRequest(for: request, withAuth: true, expecting: UserDetailsResponse.self)
        return response.user
    }
    
    /// Actualiza detalles de un usuario específico (requiere permisos de administrador)
    func updateUserDetails(userId: Int, nombre: String?, apellido: String?, email: String?, password: String?) async throws {
        let url = baseURL.appendingPathComponent("users/\(userId)/details")
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        
        let body = UpdateUserDetailsRequest(
            nombre: nombre,
            apellido: apellido,
            email: email,
            password: password
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
    
    // MARK: - Enhanced Stats Endpoints (Phase 2)
    
    /// Obtiene estadísticas detalladas del usuario
    func fetchUserDetailedStats() async throws -> UserDetailedStatsModel {
        // Primero obtenemos el usuario actual para obtener su ID
        let currentUser = try await fetchCurrentUser()
        
        let url = baseURL.appendingPathComponent("users/\(currentUser.id)/stats")
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        return try await performRequest(for: request, withAuth: true)
    }
    
    /// Obtiene el registro de actividades del usuario para un mes específico
    func fetchActivityLog(year: Int? = nil, month: Int? = nil) async throws -> ActivityLogResponse {
        let currentDate = Date()
        let calendar = Calendar.current
        let currentYear = year ?? calendar.component(.year, from: currentDate)
        let currentMonth = month ?? calendar.component(.month, from: currentDate)
        
        var urlComponents = URLComponents()
        urlComponents.scheme = baseURL.scheme
        urlComponents.host = baseURL.host
        urlComponents.path = baseURL.path + "/activity-log"
        urlComponents.queryItems = [
            URLQueryItem(name: "year", value: "\(currentYear)"),
            URLQueryItem(name: "month", value: "\(currentMonth)")
        ]
        
        guard let url = urlComponents.url else {
            throw APIError.requestFailed(description: "URL inválida para activity-log")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        return try await performRequest(for: request, withAuth: true, expecting: ActivityLogResponse.self)
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
