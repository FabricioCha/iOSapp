import Foundation
import SwiftUI

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
    
    var icon: String {
        switch self {
        case .siNo: return "checkmark.circle.fill"
        case .medibleNumerico: return "number.circle.fill"
        case .malHabito: return "xmark.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .siNo: return .green
        case .medibleNumerico: return .blue
        case .malHabito: return .red
        }
    }
}

struct Habit: Identifiable, Codable, Hashable {
    // CAMBIO: El ID ahora es Int para coincidir con la base de datos.
    let id: Int
    let nombre: String
    let tipo: ApiHabitType
    var descripcion: String?
    // CAMBIO: La meta ahora es Double? (número decimal) para coincidir con la API.
    var meta_objetivo: Double?

    enum CodingKeys: String, CodingKey {
        case id, nombre, tipo, descripcion
        // Asegúrate de que el nombre de la clave coincida con la API.
        case meta_objetivo = "metaObjetivo"
    }
    
    // Inicializador para cuando solo tenemos datos básicos (como en rutinas)
    init(id: Int, nombre: String, tipo: ApiHabitType, descripcion: String? = nil, meta_objetivo: Double? = nil) {
        self.id = id
        self.nombre = nombre
        self.tipo = tipo
        self.descripcion = descripcion
        self.meta_objetivo = meta_objetivo
    }
    
    // Inicializador desde Decoder que maneja propiedades opcionales
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        nombre = try container.decode(String.self, forKey: .nombre)
        tipo = try container.decode(ApiHabitType.self, forKey: .tipo)
        descripcion = try container.decodeIfPresent(String.self, forKey: .descripcion)
        meta_objetivo = try container.decodeIfPresent(Double.self, forKey: .meta_objetivo)
    }
}

struct HabitLogRequest: Codable {
    // CAMBIO: El ID del hábito ahora es Int.
    let habito_id: Int
    let fecha_registro: String // Formato YYYY-MM-DD
    var valor_booleano: Bool?
    // CAMBIO: El valor numérico ahora es Double?
    var valor_numerico: Double?
    var notas: String?
}
