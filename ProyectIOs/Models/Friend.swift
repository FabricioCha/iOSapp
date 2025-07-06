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