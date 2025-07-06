//
//  Ranking.swift
//  ProyectIOs
//
//  Created by Trae AI on 2024.
//

import Foundation

// MARK: - Ranking Models

struct RankingEntry: Identifiable, Codable {
    let id: Int
    let nombre: String
    let fotoPerfil: String?
    let paisCodigo: String?
    let valor: Int
    
    enum CodingKeys: String, CodingKey {
        case id = "usuario_id"
        case nombre
        case fotoPerfil = "foto_perfil_url"
        case paisCodigo = "pais_codigo"
        case valor
    }
}

struct RankingsResponse: Codable {
    let rankings: [RankingEntry]
}

// MARK: - Ranking Scope

enum RankingScope: String, CaseIterable {
    case global = "global"
    case country = "country"
    
    var displayName: String {
        switch self {
        case .global:
            return "Global"
        case .country:
            return "País"
        }
    }
}