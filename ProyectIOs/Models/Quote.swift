//
//  Quote.swift
//  ProyectIOs
//
//  Created by Fabricio Chavez on 16/06/25.
//

import Foundation

// Define la estructura de una frase motivacional.
struct Quote: Identifiable, Codable {
    let id: UUID
    let text: String
    let author: String
}
