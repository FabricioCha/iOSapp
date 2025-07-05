//
//  UserSearchView.swift
//  ProyectIOs
//
//  Created by Fabricio Chavez on 04/07/25.
//

import SwiftUI

struct UserSearchView: View {
    @State private var searchText = ""
    @State private var selectedUserId: Int?
    @State private var showingUserInfo = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Campo de búsqueda
                VStack(alignment: .leading, spacing: 8) {
                    Text("ID de Usuario")
                        .font(.headline)
                        .foregroundColor(.appTextPrimary)
                    
                    TextField("Ingresa el ID del usuario (ej: 123)", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numberPad)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.appCardBackground)
                        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                )
                
                // Botón de búsqueda
                Button(action: searchUser) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                        Text("Buscar Usuario")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.appAccent)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .disabled(searchText.trimmingCharacters(in: .whitespaces).isEmpty)
                
                // Información de ayuda
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundColor(.blue)
                        Text("Información")
                            .font(.headline)
                            .foregroundColor(.appTextPrimary)
                    }
                    
                    Text("Ingresa el ID numérico del usuario para ver su información básica. Solo podrás ver usuarios con los que tienes una amistad establecida.")
                        .font(.body)
                        .foregroundColor(.appTextSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.blue.opacity(0.1))
                )
                
                Spacer()
            }
            .padding()
            .background(Color.appBackground.ignoresSafeArea())
            .navigationTitle("Buscar Usuario")
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $showingUserInfo) {
            if let userId = selectedUserId {
                UserInfoView(userId: userId)
            }
        }
    }
    
    private func searchUser() {
        guard let userId = Int(searchText.trimmingCharacters(in: .whitespaces)) else {
            return
        }
        
        selectedUserId = userId
        showingUserInfo = true
    }
}

#Preview {
    UserSearchView()
}