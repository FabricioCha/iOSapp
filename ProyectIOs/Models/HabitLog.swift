//
//  HabitLog.swift
//  ProyectIOs
//
//  Created by Fabricio Chavez on 20/06/25.
//

import Foundation

// Representa la respuesta del endpoint que devuelve el historial de un hábito.
struct HabitLogResponse: Codable {
    // Asumimos que la API devuelve una lista de fechas en formato String (YYYY-MM-DD).
    let completionDates: [String]
}
