//
//  Dashboard.swift
//  ProyectIOs
//
//  Created by Fabricio Chavez on 20/06/25.
//

import Foundation

// Representa la respuesta completa del endpoint /api/dashboard
struct DashboardData: Codable {
    // La API probablemente devuelva un objeto con un campo que contiene los hábitos y estadísticas.
    // Ajusta "habitsConEstadisticas" al nombre real del campo en tu JSON.
    let habitsConEstadisticas: [HabitWithStats]
}

// Representa un hábito individual junto con sus estadísticas calculadas por el servidor.
struct HabitWithStats: Codable, Identifiable, Hashable {
    let id: String
    let nombre: String
    let tipo: ApiHabitType
    var descripcion: String?
    var meta_objetivo: String?
    
    // Estadísticas calculadas que vienen del servidor
    let rachaActual: Int
    let mejorRacha: Int
    let totalCompletados: Int
    let completadoHoy: Bool
    
    enum CodingKeys: String, CodingKey {
        case id, nombre, tipo, descripcion
        case meta_objetivo = "metaObjetivo"
        case rachaActual, mejorRacha, totalCompletados, completadoHoy
    }
}

// Modelo para las estadísticas globales que podríamos recibir.
struct GlobalStats: Codable {
    let rachaActualGlobal: Int
    let mejorRachaGlobal: Int
    let totalCompletadosGlobal: Int
    let tasaDeExitoGlobal: Double
}
