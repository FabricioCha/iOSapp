//
//  FriendsViewModel.swift
//  ProyectIOs
//
//  Created by Trae AI on 2024.
//

import Foundation
import SwiftUI

@MainActor
class FriendsViewModel: ObservableObject {
    @Published var friends: [Friend] = []
    @Published var receivedInvitations: [FriendInvitation] = []
    @Published var sentInvitations: [FriendInvitation] = []
    @Published var searchResults: [SearchUser] = []
    @Published var friendActivity: [FriendActivity] = []
    @Published var friendAchievements: [FriendAchievement] = []
    @Published var friendStats: UserStats?
    
    @Published var isLoading = false
    @Published var isSearching = false
    @Published var errorMessage: String?
    @Published var successMessage: String?
    @Published var searchQuery = ""
    
    private let friendsService = FriendsService()
    
    // MARK: - Friends Management
    
    func loadFriends() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await friendsService.getFriends()
            friends = response.friends
        } catch {
            errorMessage = handleError(error)
        }
        
        isLoading = false
    }
    
    func deleteFriend(_ friend: Friend) async {
        do {
            let response = try await friendsService.deleteFriend(friendId: friend.id)
            if response.success {
                friends.removeAll { $0.id == friend.id }
                successMessage = "Amistad eliminada exitosamente"
            } else {
                errorMessage = response.message ?? "Error al eliminar amistad"
            }
        } catch {
            errorMessage = handleError(error)
        }
    }
    
    // MARK: - Friend Activity & Achievements
    
    func loadFriendActivity(friendId: Int) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await friendsService.getFriendActivity(friendId: friendId)
            friendActivity = response.activities
        } catch {
            errorMessage = handleError(error)
        }
        
        isLoading = false
    }
    
    func loadFriendAchievements(friendId: Int) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await friendsService.getFriendAchievements(friendId: friendId)
            friendAchievements = response.achievements
        } catch {
            errorMessage = handleError(error)
        }
        
        isLoading = false
    }
    
    func loadFriendStats(friendId: Int) async {
        errorMessage = nil
        
        do {
            let stats = try await friendsService.getFriendStats(friendId: friendId)
            friendStats = stats
        } catch {
            errorMessage = handleError(error)
        }
    }
    
    // MARK: - Invitations Management
    
    func loadInvitations() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await friendsService.getInvitations()
            receivedInvitations = response.receivedInvitations
            sentInvitations = response.sentInvitations
        } catch {
            errorMessage = handleError(error)
        }
        
        isLoading = false
    }
    
    func sendFriendInvitation(to user: SearchUser) async {
        do {
            let response = try await friendsService.sendFriendInvitation(to: user.id)
            if response.success {
                successMessage = "Solicitud de amistad enviada a \(user.nombre)"
                // Recargar invitaciones para mostrar la nueva solicitud enviada
                await loadInvitations()
            } else {
                errorMessage = response.message ?? "Error al enviar solicitud"
            }
        } catch {
            errorMessage = handleError(error)
        }
    }
    
    func acceptInvitation(_ invitation: FriendInvitation) async {
        do {
            let response = try await friendsService.respondToInvitation(
                invitationId: invitation.id,
                action: "accept"
            )
            if response.success {
                successMessage = "Solicitud de amistad aceptada"
                // Remover de invitaciones recibidas
                receivedInvitations.removeAll { $0.id == invitation.id }
                // Recargar lista de amigos
                await loadFriends()
            } else {
                errorMessage = response.message ?? "Error al aceptar solicitud"
            }
        } catch {
            errorMessage = handleError(error)
        }
    }
    
    func rejectInvitation(_ invitation: FriendInvitation) async {
        do {
            let response = try await friendsService.respondToInvitation(
                invitationId: invitation.id,
                action: "reject"
            )
            if response.success {
                successMessage = "Solicitud de amistad rechazada"
                // Remover de invitaciones recibidas
                receivedInvitations.removeAll { $0.id == invitation.id }
            } else {
                errorMessage = response.message ?? "Error al rechazar solicitud"
            }
        } catch {
            errorMessage = handleError(error)
        }
    }
    
    // MARK: - User Search
    
    func searchUsers() async {
        guard !searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            searchResults = []
            return
        }
        
        isSearching = true
        errorMessage = nil
        
        do {
            let response = try await friendsService.searchUsers(query: searchQuery)
            searchResults = response.users
        } catch {
            errorMessage = handleError(error)
            searchResults = []
        }
        
        isSearching = false
    }
    
    func clearSearch() {
        searchQuery = ""
        searchResults = []
    }
    
    // MARK: - Utility Methods
    
    func clearMessages() {
        errorMessage = nil
        successMessage = nil
    }
    
    private func handleError(_ error: Error) -> String {
        if let apiError = error as? APIError {
            switch apiError {
            case .invalidURL:
                return "URL inválida"
            case .invalidResponse:
                return "Respuesta inválida del servidor"
            case .decodingError(let description):
                return "Error al procesar datos: \(description)"
            case .encodingError:
                return "Error al enviar datos"
            case .serverError(let code, let description):
                switch code {
                case 401:
                    return "No autorizado. Por favor, inicia sesión nuevamente"
                case 404:
                    return "Recurso no encontrado"
                case 409:
                    return "Ya existe una solicitud pendiente o son amigos"
                case 500:
                    return "Error interno del servidor"
                default:
                    return "Error del servidor (\(code)): \(description)"
                }
            case .requestFailed(let description):
                return "Error de solicitud: \(description)"
            case .unknownError:
                return "Error desconocido"
            }
        }
        
        return error.localizedDescription
    }
    
    // MARK: - Helper Methods
    
    func isUserAlreadyFriend(_ user: SearchUser) -> Bool {
        return friends.contains { $0.id == user.id }
    }
    
    func hasInvitationSentTo(_ user: SearchUser) -> Bool {
        return sentInvitations.contains { $0.solicitadoId == user.id && $0.estado == "pendiente" }
    }
    
    func hasInvitationReceivedFrom(_ user: SearchUser) -> Bool {
        return receivedInvitations.contains { $0.solicitanteId == user.id && $0.estado == "pendiente" }
    }
    
    func getFriendById(_ id: Int) -> Friend? {
        return friends.first { $0.id == id }
    }
}