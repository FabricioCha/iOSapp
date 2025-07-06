//
//  RankingsViewModel.swift
//  ProyectIOs
//
//  Created by Trae AI on 2024.
//

import Foundation
import SwiftUI

@MainActor
class RankingsViewModel: ObservableObject {
    @Published var rankings: [RankingEntry] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var selectedScope: RankingScope = .global
    @Published var userCountryCode: String?
    
    private let rankingsService = RankingsService()
    
    init() {
        Task {
            await loadRankings()
        }
    }
    
    func loadRankings() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await rankingsService.getRankings(
                scope: selectedScope,
                countryCode: selectedScope == .country ? userCountryCode : nil,
                limit: 50
            )
            rankings = response.rankings
        } catch {
            errorMessage = handleError(error)
        }
        
        isLoading = false
    }
    
    func changeScope(_ newScope: RankingScope) {
        selectedScope = newScope
        Task {
            await loadRankings()
        }
    }
    
    func refreshRankings() {
        Task {
            await loadRankings()
        }
    }
    
    private func handleError(_ error: Error) -> String {
        if let apiError = error as? APIError {
            switch apiError {
            case .requestFailed(let description):
                return description
            case .serverError(_, let description):
                return description
            case .decodingError(let description):
                return "Error al procesar datos: \(description)"
            case .encodingError:
                return "Error al enviar datos"
            case .invalidURL:
                return "URL inválida"
            case .invalidResponse:
                return "Respuesta inválida del servidor"
            case .unknownError:
                return "Error desconocido"
            }
        }
        return "Error desconocido: \(error.localizedDescription)"
    }
}