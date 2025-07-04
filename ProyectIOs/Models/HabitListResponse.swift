//
//  HabitListResponse.swift
//  ProyectIOs
//
//  Created by Fabricio Chavez on 30/06/25.
//

import Foundation

// Esta estructura coincide con la respuesta del endpoint GET /api/habits,
// que devuelve un objeto con una clave "habits".
struct HabitListResponse: Codable {
    let habits: [Habit]
}
