//
//  Friend.swift
//  ProyectIOs
//
//  Created by Trae AI on 2024.
//

import Foundation

// MARK: - Friend Models
struct Friend: Codable, Identifiable {
    let id: Int
    let nombre: String
    let email: String
    let fechaCreacion: String
    let fechaInicioAmistad: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case nombre
        case email
        case fechaCreacion = "fecha_creacion"
        case fechaInicioAmistad = "fecha_inicio_amistad"
    }
}

struct FriendsResponse: Codable {
    let success: Bool
    let friends: [Friend]
    let total: Int
}

// MARK: - Friend Invitation Models
struct FriendInvitation: Codable, Identifiable {
    let id: Int
    let solicitanteId: Int
    let solicitadoId: Int
    let estado: String
    let fechaEnvio: String
    let solicitadoNombre: String?
    let solicitadoEmail: String?
    let solicitanteNombre: String?
    let solicitanteEmail: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case solicitanteId = "solicitante_id"
        case solicitadoId = "solicitado_id"
        case estado
        case fechaEnvio = "fecha_envio"
        case solicitadoNombre = "solicitado_nombre"
        case solicitadoEmail = "solicitado_email"
        case solicitanteNombre = "solicitante_nombre"
        case solicitanteEmail = "solicitante_email"
    }
}

struct InvitationsResponse: Codable {
    let success: Bool
    let receivedInvitations: [FriendInvitation]
    let sentInvitations: [FriendInvitation]
    let totalReceived: Int
    let totalSent: Int
    
    enum CodingKeys: String, CodingKey {
        case success
        case receivedInvitations = "received_invitations"
        case sentInvitations = "sent_invitations"
        case totalReceived = "total_received"
        case totalSent = "total_sent"
    }
}

// MARK: - Friend Activity Models
struct FriendActivity: Codable, Identifiable {
    let id: String
    let tipo: String
    let descripcion: String
    let fecha: String
    let detalles: [String: String]?
}

struct FriendActivityResponse: Codable {
    let success: Bool
    let activities: [FriendActivity]
    let total: Int
}

// MARK: - Friend Daily Activity Models (from backend)
struct DailyActivity: Codable {
    let completions: Int
    let hasRelapse: Bool
    
    enum CodingKeys: String, CodingKey {
        case completions
        case hasRelapse = "hasRelapse"
    }
}

struct FriendDailyActivityResponse: Codable {
    let success: Bool
    let activity: [String: DailyActivity]
    let friendId: Int
    let year: Int
    let month: Int
    
    enum CodingKeys: String, CodingKey {
        case success
        case activity
        case friendId
        case year
        case month
    }
}

// MARK: - User Stats Models
struct UserStatsHabit: Codable {
    let id: Int
    let nombre: String
    let tipo: String
    let rachaActual: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case nombre
        case tipo
        case rachaActual = "racha_actual"
    }
}

struct UserStats: Codable {
    let userId: Int
    let totalHabitsCompleted: Int
    let longestStreak: Int
    let currentStreak: Int
    let totalAchievements: Int
    let joinDate: String
    let goodHabitsCount: Int
    let addictionsCount: Int
    let bestGoodHabitStreak: Int
    let bestAddictionStreak: Int
    let habitsWithStats: [UserStatsHabit]
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case totalHabitsCompleted = "total_habits_completed"
        case longestStreak = "longest_streak"
        case currentStreak = "current_streak"
        case totalAchievements = "total_achievements"
        case joinDate = "join_date"
        case goodHabitsCount = "good_habits_count"
        case addictionsCount = "addictions_count"
        case bestGoodHabitStreak = "best_good_habit_streak"
        case bestAddictionStreak = "best_addiction_streak"
        case habitsWithStats = "habits_with_stats"
    }
    
    // Computed properties for backward compatibility
    var totalHabits: Int {
        return habitsWithStats.count
    }
    
    var completedToday: Int {
        // This would need to be calculated based on today's completions
        // For now, return 0 as placeholder
        return 0
    }
    
    var completionRate: Double {
        // Calculate completion rate based on available data
        guard totalHabitsCompleted > 0 else { return 0.0 }
        return Double(totalHabitsCompleted) / Double(totalHabits * 30) // Assuming 30 days average
    }
}

// MARK: - Friend Achievement Models
struct FriendAchievement: Codable, Identifiable {
    let id: Int
    let nombre: String
    let descripcion: String
    let icono: String?
    let fechaObtencion: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case nombre
        case descripcion
        case icono = "icono_url"
        case fechaObtencion = "fecha_obtencion"
    }
}

struct FriendAchievementsResponse: Codable {
    let success: Bool
    let achievements: [FriendAchievement]
    let total: Int
}

// MARK: - User Search Models
struct SearchUser: Codable, Identifiable {
    let id: Int
    let nombre: String
    let email: String?
    let fechaCreacion: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case nombre
        case email
        case fechaCreacion = "fecha_creacion"
    }
}

struct UserSearchResponse: Codable {
    let success: Bool
    let users: [SearchUser]
    let total: Int
}

// MARK: - Generic Response Models
struct FriendActionResponse: Codable {
    let success: Bool
    let message: String?
}

struct SendInvitationRequest: Codable {
    let solicitadoId: Int
    
    enum CodingKeys: String, CodingKey {
        case solicitadoId = "solicitado_id"
    }
}

struct RespondInvitationRequest: Codable {
    let action: String // "accept" o "reject"
}