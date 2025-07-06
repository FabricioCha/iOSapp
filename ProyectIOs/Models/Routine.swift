//
//  Routine.swift
//  ProyectIOs
//
//  Created by Trae AI on 2024.
//

import Foundation

// MARK: - Routine Models

struct Routine: Identifiable, Codable, Hashable {
    let id: Int
    let usuarioId: Int
    let nombre: String
    let descripcion: String?
    let fechaCreacion: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case usuarioId = "usuario_id"
        case nombre
        case descripcion
        case fechaCreacion = "fecha_creacion"
    }
}

struct RoutineDetails: Identifiable, Codable {
    let id: Int
    let nombre: String
    let descripcion: String?
    let habits: [Habit]
}

// MARK: - API Request/Response Models

struct CreateRoutineRequest: Codable {
    let nombre: String
    let descripcion: String?
}

struct CreateRoutineResponse: Codable {
    let message: String
    let routine: Routine
}

struct RoutinesResponse: Codable {
    let routines: [Routine]
}

struct UpdateRoutineRequest: Codable {
    let nombre: String?
    let descripcion: String?
}

struct AddHabitToRoutineRequest: Codable {
    let habitId: Int
    
    enum CodingKeys: String, CodingKey {
        case habitId
    }
}

struct RemoveHabitFromRoutineRequest: Codable {
    let habitId: Int
    
    enum CodingKeys: String, CodingKey {
        case habitId
    }
}



// MARK: - Extensions

extension Routine {
    var formattedCreatedAt: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        if let date = formatter.date(from: fechaCreacion) {
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            return formatter.string(from: date)
        }
        return fechaCreacion
    }
    
    // Computed properties for compatibility
    var name: String { nombre }
    var description: String? { descripcion }
    var createdAt: String { fechaCreacion }
}

extension RoutineDetails {
    var habitCount: Int {
        return habits.count
    }
    
    var formattedHabitCount: String {
        return "\(habitCount) hábito\(habitCount == 1 ? "" : "s")"
    }
    
    // Computed properties for compatibility
    var name: String { nombre }
    var description: String? { descripcion }
    
    var habitTypes: [ApiHabitType] {
        return Array(Set(habits.map { $0.tipo }))
    }
    
    var formattedHabitTypes: String {
        let typeNames = habitTypes.map { $0.displayName }
        if typeNames.count <= 2 {
            return typeNames.joined(separator: ", ")
        } else {
            return "\(typeNames.prefix(2).joined(separator: ", ")) y \(typeNames.count - 2) más"
        }
    }
}