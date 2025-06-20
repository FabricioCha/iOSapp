//
//  Badge.swift
//  ProyectIOs
//
//  Created by Fabricio Chavez on 17/06/25.
//

import Foundation

// Define la estructura de una insignia o logro desbloqueable.
struct Badge: Identifiable, Codable, Hashable {
    let id: String // Usamos String para que coincida con los IDs en unlockedBadgeIDs del User.
    let name: String
    let description: String
    let iconName: String
}
