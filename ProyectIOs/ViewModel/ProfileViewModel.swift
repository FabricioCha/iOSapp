//
//  ProfileViewModel.swift
//  ProyectIOs
//
//  Created by Fabricio Chavez on 04/07/25.
//

import Foundation
import SwiftUI

@MainActor
class ProfileViewModel: ObservableObject {
    
    @Published var userProfile: UserProfile?
    @Published var isLoading = false
    @Published var alertItem: AlertItem?
    @Published var successMessage: String?
    
    @Published var updatedName: String = ""
    @Published var currentPassword = ""
    @Published var newPassword = ""
    @Published var confirmNewPassword = ""

    private let networkService: NetworkService = .shared
    
    // --- NUEVA PROPIEDAD COMPUTADA ---
    /// Determina si el botón de guardar debe estar deshabilitado.
    var isSaveChangesDisabled: Bool {
        // El nombre no ha cambiado (o está vacío) Y no se está intentando cambiar la contraseña.
        let isNameUnchanged = updatedName == userProfile?.nombre || updatedName.trimmingCharacters(in: .whitespaces).isEmpty
        let isPasswordSectionEmpty = currentPassword.isEmpty && newPassword.isEmpty && confirmNewPassword.isEmpty
        
        return isNameUnchanged && isPasswordSectionEmpty
    }
    
    func fetchProfile() async {
        isLoading = true
        do {
            userProfile = try await networkService.fetchUserProfile()
            if let name = userProfile?.nombre {
                self.updatedName = name
            }
        } catch {
            alertItem = AlertItem.from(error: error)
        }
        isLoading = false
    }
    
    func updateProfile() async {
        // --- NUEVO: Guarda de seguridad para no enviar peticiones vacías ---
        guard !isSaveChangesDisabled else { return }
        
        // Validación en el cliente para una mejor experiencia de usuario
        if !newPassword.isEmpty && newPassword != confirmNewPassword {
            alertItem = AlertItem(title: Text("Error de Validación"), message: Text("La nueva contraseña y su confirmación no coinciden."), dismissButton: .default(Text("OK")))
            return
        }
        
        isLoading = true
        successMessage = nil
        
        do {
            // Se preparan los datos para enviar. Si no se cambian, se envían como nulos.
            let nameToSend = updatedName == userProfile?.nombre ? nil : updatedName
            let currentPasswordToSend = currentPassword.isEmpty ? nil : currentPassword
            let newPasswordToSend = newPassword.isEmpty ? nil : newPassword
            let confirmPasswordToSend = confirmNewPassword.isEmpty ? nil : confirmNewPassword
            
            try await networkService.updateUserProfile(
                name: nameToSend,
                currentPassword: currentPasswordToSend,
                newPassword: newPasswordToSend,
                confirmNewPassword: confirmPasswordToSend
            )
            
            successMessage = "Perfil actualizado exitosamente."
            // Limpia los campos de contraseña después de un éxito
            currentPassword = ""
            newPassword = ""
            confirmNewPassword = ""
            
            await fetchProfile()
            
        } catch {
            alertItem = AlertItem.from(error: error)
        }
        isLoading = false
    }
}
