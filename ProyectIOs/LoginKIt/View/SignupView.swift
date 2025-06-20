//
//  SignupView.swift
//  ProyectIOs
//
//  Created by Fabricio Chavez on 13/06/25.
//

import SwiftUI

struct SignupView: View {
    
    @EnvironmentObject var authViewModel: AuthViewModel
    @Binding var showSignup: Bool
    
    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 20) {
                
                Button {
                    showSignup = false
                } label: {
                    Image(systemName: "arrow.left")
                        .font(.title2)
                        .foregroundColor(Color.appTextSecondary)
                }
                .padding(.top)

                Text("Crear Cuenta")
                    .font(.largeTitle)
                    .fontWeight(.heavy)
                
                Text("Es rápido y fácil, ¡únete a nosotros!")
                    .font(.callout)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.appTextSecondary)
                    .padding(.top, -5)
                
                VStack(spacing: 25) {
                    CustomTF(sfIcon: "person", hint: "Nombre Completo", value: $authViewModel.fullName)
                    
                    CustomTF(sfIcon: "at", hint: "Correo Electrónico", value: $authViewModel.email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                    
                    CustomTF(sfIcon: "lock", hint: "Contraseña", isPassword: true, value: $authViewModel.password)
                    
                    GradientButton(
                        title: "Registrarse",
                        icon: "arrow.right",
                        action: authViewModel.signup
                    )
                    .hSpacing(.trailing)
                    .disabled(authViewModel.email.isEmpty || authViewModel.password.isEmpty || authViewModel.fullName.isEmpty)
                }
                .padding(.top, 20)
                
                Spacer()
                
                HStack(spacing: 6) {
                    Text("¿Ya tienes una cuenta?")
                        .foregroundStyle(Color.appTextSecondary)
                    
                    Button("Inicia Sesión") {
                        showSignup = false
                    }
                    .fontWeight(.bold)
                    .tint(Color.appPrimaryAction)
                }
                .font(.callout)
                .hSpacing()
            }
            .padding(.vertical, 15)
            .padding(.horizontal, 25)
        }
        .foregroundColor(Color.appTextPrimary)
        .alert(item: $authViewModel.alertItem) { alertItem in
            Alert(title: alertItem.title, message: alertItem.message, dismissButton: alertItem.dismissButton)
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var showSignup = true
        
        var body: some View {
            SignupView(showSignup: $showSignup)
                .environmentObject(AuthViewModel())
        }
    }
    
    return PreviewWrapper()
}
