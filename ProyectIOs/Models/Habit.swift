import Foundation

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
}

struct HabitLogRequest: Codable {
    // CAMBIO: El ID del hábito ahora es Int.
    let habito_id: Int
    let fecha_registro: String // Formato YYYY-MM-DD
    var valor_booleano: Bool?
    // CAMBIO: El valor numérico ahora es Double?
    var valor_numerico: Double?
    var es_recaida: Bool?
}
