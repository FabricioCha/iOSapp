//
//  UserManagementViewModel.swift
//  ProyectIOs
//
//  Created by Fabricio Chavez on 04/07/25.
//

import Foundation
import SwiftUI

@MainActor
class UserManagementViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var userBasicInfo: UserBasicInfo?
    @Published var userDetails: UserDetails?
    @Published var isLoading = false
    @Published var alertItem: AlertItem?
    @Published var successMessage: String?
    
    // MARK: - Form Properties for User Details
    @Published var editedName: String = ""
    @Published var editedLastName: String = ""
    @Published var editedEmail: String = ""
    @Published var newPassword: String = ""
    
    private let networkService: NetworkService = .shared
    
    // MARK: - Computed Properties
    
    /// Determina si el botón de guardar debe estar deshabilitado
    var isSaveChangesDisabled: Bool {
        guard let userDetails = userDetails else { return true }
        
        let nameChanged = editedName != userDetails.nombre
        let lastNameChanged = editedLastName != (userDetails.apellido ?? "")
        let emailChanged = editedEmail != userDetails.email
        let passwordChanged = !newPassword.isEmpty
        
        return !(nameChanged || lastNameChanged || emailChanged || passwordChanged)
    }
    
    // MARK: - Public Methods
    
    /// Obtiene información básica de un usuario
    func fetchUserBasicInfo(userId: Int) async {
        isLoading = true
        successMessage = nil
        
        do {
            userBasicInfo = try await networkService.fetchUserBasicInfo(userId: userId)
        } catch {
            alertItem = AlertItem.from(error: error)
        }
        
        isLoading = false
    }
    
    /// Obtiene detalles completos de un usuario (requiere permisos de administrador)
    func fetchUserDetails(userId: Int) async {
        isLoading = true
        successMessage = nil
        
        do {
            userDetails = try await networkService.fetchUserDetails(userId: userId)
            
            // Inicializar los campos de edición con los valores actuales
            if let details = userDetails {
                editedName = details.nombre
                editedLastName = details.apellido ?? ""
                editedEmail = details.email
                newPassword = ""
            }
        } catch {
            alertItem = AlertItem.from(error: error)
        }
        
        isLoading = false
    }
    
    /// Actualiza los detalles de un usuario (requiere permisos de administrador)
    func updateUserDetails(userId: Int) async {
        guard !isSaveChangesDisabled else { return }
        guard let userDetails = userDetails else { return }
        
        isLoading = true
        successMessage = nil
        
        do {
            // Preparar los datos para enviar. Si no se cambian, se envían como nulos.
            let nameToSend = editedName == userDetails.nombre ? nil : editedName
            let lastNameToSend = editedLastName == (userDetails.apellido ?? "") ? nil : editedLastName
            let emailToSend = editedEmail == userDetails.email ? nil : editedEmail
            let passwordToSend = newPassword.isEmpty ? nil : newPassword
            
            try await networkService.updateUserDetails(
                userId: userId,
                nombre: nameToSend,
                apellido: lastNameToSend,
                email: emailToSend,
                password: passwordToSend
            )
            
            successMessage = "Los detalles del usuario han sido actualizados exitosamente."
            
            // Actualizar el modelo local con los nuevos valores
            self.userDetails = UserDetails(
                id: userDetails.id,
                nombre: editedName,
                apellido: editedLastName.isEmpty ? nil : editedLastName,
                email: editedEmail
            )
            
            // Limpiar la contraseña después de una actualización exitosa
            newPassword = ""
            
        } catch {
            alertItem = AlertItem.from(error: error)
        }
        
        isLoading = false
    }
    
    /// Limpia todos los datos del ViewModel
    func clearData() {
        userBasicInfo = nil
        userDetails = nil
        editedName = ""
        editedLastName = ""
        editedEmail = ""
        newPassword = ""
        successMessage = nil
        alertItem = nil
    }
    
    /// Formatea la fecha de creación para mostrar
    func formatCreationDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        if let date = formatter.date(from: dateString) {
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            return formatter.string(from: date)
        }
        
        return dateString
    }
}