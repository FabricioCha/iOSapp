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
}

// --- STRUCT CORREGIDA ---
// Representa un hábito individual junto con sus estadísticas.
// Los campos que la API del dashboard no envía ahora son OPCIONALES.
struct HabitWithStats: Codable, Identifiable, Hashable {
    let id: Int
    let nombre: String
    let tipo: ApiHabitType
    var descripcion: String?
    var meta_objetivo: Double?
    
    // Estadísticas que vienen del servidor
    let rachaActual: Int
    
    // --- CAMBIO CLAVE: Hacer estas propiedades opcionales ---
    // Si la API no envía estos campos, no se romperá la decodificación.
    let mejorRacha: Int?
    let totalCompletados: Int?
    let completadoHoy: Bool?
    
    // El bloque CodingKeys se actualiza para incluir los nuevos miembros.
    enum CodingKeys: String, CodingKey {
        case id, nombre, tipo, descripcion
        case meta_objetivo = "metaObjetivo"
        case rachaActual, mejorRacha, totalCompletados, completadoHoy
    }
}

// Modelo para las estadísticas globales que podríamos recibir en el futuro.
struct GlobalStats: Codable {
    let rachaActualGlobal: Int
    let mejorRachaGlobal: Int
    let totalCompletadosGlobal: Int
    let tasaDeExitoGlobal: Double
}
