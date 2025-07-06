//
//  Dashboard.swift
//  ProyectIOs
//
//  Created by Fabricio Chavez on 20/06/25.
//

import Foundation

// Representa la respuesta completa del endpoint /api/dashboard
struct DashboardData: Codable {
    let habitsConEstadisticas: [HabitWithStats]
    
    enum CodingKeys: String, CodingKey {
        case habitsConEstadisticas = "habits_con_estadisticas"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        habitsConEstadisticas = try container.decode([HabitWithStats].self, forKey: .habitsConEstadisticas)
    }
}

// Representa un hábito individual junto con sus estadísticas desde la API
struct HabitWithStats: Codable, Identifiable, Hashable {
    let id: Int
    let nombre: String
    let tipo: ApiHabitType
    let descripcion: String?
    let metaObjetivo: Double?
    let fechaCreacion: String
    
    // Estadísticas que vienen del servidor
    let rachaActual: Int
    
    // Campos opcionales para compatibilidad
    let mejorRacha: Int?
    let totalCompletados: Int?
    let completadoHoy: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id, nombre, tipo, descripcion
        case metaObjetivo = "meta_objetivo"
        case fechaCreacion = "fecha_creacion"
        case rachaActual = "racha_actual"
        case mejorRacha, totalCompletados, completadoHoy
    }
}

// Modelo para las estadísticas globales que podríamos recibir en el futuro.
struct GlobalStats: Codable {
    let rachaActualGlobal: Int
    let mejorRachaGlobal: Int
    let totalCompletadosGlobal: Int
    let tasaDeExitoGlobal: Double
}
