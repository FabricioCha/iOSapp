//
//  KeychainService.swift
//  ProyectIOs
//
//  Created by Fabricio Chavez on 20/06/25.
//

import Foundation
import Security

// Un servicio para interactuar de forma segura con el Keychain de iOS.
class KeychainService {
    
    static let shared = KeychainService()
    private let service = "com.tuempresa.ProyectIOs.authtoken" // Cambia esto por un identificador único.
    
    private init() {}

    func saveToken(_ token: String) {
        guard let data = token.data(using: .utf8) else { return }
        
        // El query para buscar un item existente.
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service
        ]
        
        // Los atributos a actualizar o añadir.
        let attributes: [String: Any] = [
            kSecValueData as String: data
        ]
        
        // Intenta actualizar un token existente.
        if SecItemUpdate(query as CFDictionary, attributes as CFDictionary) != errSecSuccess {
            // Si no existe, crea uno nuevo.
            var newQuery = query
            newQuery[kSecValueData as String] = data
            SecItemAdd(newQuery as CFDictionary, nil)
        }
    }

    func getToken() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnData as String: kCFBooleanTrue!
        ]
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        if status == errSecSuccess, let data = dataTypeRef as? Data {
            return String(data: data, encoding: .utf8)
        } else {
            return nil
        }
    }

    func deleteToken() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service
        ]
        
        SecItemDelete(query as CFDictionary)
    }
}
