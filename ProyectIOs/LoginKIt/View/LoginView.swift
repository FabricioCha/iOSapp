//
//  LoginView.swift
//  ProyectIOs
//
//  Created by Fabricio Chavez on 12/06/25.
//

import SwiftUI

struct LoginView: View {
    
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var habitsViewModel: HabitsViewModel
    @Binding var showSignup: Bool
    
    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 20) {
                Spacer()
                
                Text("Iniciar Sesión")
                    .font(.largeTitle)
                    .fontWeight(.heavy)
                
                Text("Bienvenido de nuevo, te hemos echado de menos.")
                    .font(.callout)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.appTextSecondary)
                    .padding(.top, -5)
                
                VStack(spacing: 25) {
                    CustomTF(sfIcon: "at", hint: "Correo Electrónico", value: $authViewModel.email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                    
                    CustomTF(sfIcon: "lock", hint: "Contraseña", isPassword: true, value: $authViewModel.password)
                    
                    GradientButton(
                        title: "Iniciar Sesión",
                        icon: "arrow.right",
                        action: {
                            Task {
                                await authViewModel.login()
                                await habitsViewModel.loadHabits() // Si necesitas cargar hábitos tras login
                            }
                        }
                    )
                    .hSpacing(.trailing)
                    .disabled(authViewModel.email.isEmpty || authViewModel.password.isEmpty)
                }
                .padding(.top, 20)
                
                Spacer()
                
                HStack(spacing: 6) {
                    Text("¿No tienes una cuenta?")
                        .foregroundStyle(Color.appTextSecondary)
                    
                    Button("Regístrate aquí") {
                        showSignup = true
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
        @State private var showSignup = false
        
        var body: some View {
            LoginView(showSignup: $showSignup)
                .environmentObject(AuthViewModel())
                .environmentObject(HabitsViewModel())
        }
    }
    
    return PreviewWrapper()
}
