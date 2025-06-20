//
//  Habit.swift
//  ProyectIOs
//
//  Created by Fabricio Chavez on 16/06/25.
//

import Foundation

// Nuevo enum que coincide con los tipos de la API.
enum ApiHabitType: String, Codable, CaseIterable {
    case siNo = "SI_NO"
    case medibleNumerico = "MEDIBLE_NUMERICO"
    case malHabito = "MAL_HABITO"
    
    var displayName: String {
        switch self {
        case .siNo: return "Hábito de Sí/No"
        case .medibleNumerico: return "Hábito Numérico"
        case .malHabito: return "Dejar un Mal Hábito"
        }
    }
}

// Modelo de Hábito adaptado para la API.
struct Habit: Identifiable, Codable, Hashable {
    let id: String // El ID de la API
    let nombre: String
    let tipo: ApiHabitType
    var descripcion: String?
    var meta_objetivo: String? // Mapea desde 'goal' de tu modelo anterior.
    
    // El progreso se consultará por separado, ya no está en este modelo.

    enum CodingKeys: String, CodingKey {
        case id, nombre, tipo, descripcion
        case meta_objetivo = "metaObjetivo" // Asegúrate que el nombre coincida con la API.
    }
}

// Estructura para el cuerpo de la solicitud al registrar un progreso.
struct HabitLogRequest: Codable {
    let habito_id: String
    let fecha_registro: String // Formato YYYY-MM-DD
    var valor_booleano: Bool?
    var valor_numerico: Int?
}
