//
//  CustomTF.swift
//  ProyectIOs
//
//  Created by Fabricio Chavez on 12/06/25.
//

import SwiftUI

// Un campo de texto personalizado y reutilizable que incluye un ícono,
// un placeholder y funcionalidad para campos de contraseña.
struct CustomTF: View {
    // MARK: - Properties
    var sfIcon: String
    var iconTint: Color = .gray
    var hint: String
    
    // Determina si el campo es para contraseñas.
    var isPassword: Bool = false
    
    // El @Binding conecta esta propiedad con una propiedad @State en la vista padre.
    // Cuando el texto aquí cambia, el estado en la vista padre también se actualiza.
    @Binding var value: String
    
    // Estado local para controlar la visibilidad de la contraseña.
    @State private var showPassword: Bool = false
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: sfIcon)
                .foregroundColor(iconTint)
                .frame(width: 30)
                // Usamos .top para alinear el ícono con la parte superior del texto.
                .padding(.top, 3)
            
            VStack(alignment: .leading, spacing: 8) {
                if isPassword {
                    // Si es un campo de contraseña, elegimos entre TextField y SecureField
                    // basándonos en el estado de showPassword.
                    Group {
                        if showPassword {
                            TextField(hint, text: $value)
                        } else {
                            SecureField(hint, text: $value)
                        }
                    }
                } else {
                    // Si no, es un campo de texto normal.
                    TextField(hint, text: $value)
                }
                
                // Línea divisoria para un diseño limpio.
                Divider()
            }
            // Superponemos el botón de mostrar/ocultar a la derecha del VStack.
            .overlay(alignment: .trailing) {
                if isPassword {
                    Button {
                        // Con un withAnimation, el cambio de ícono será suave.
                        withAnimation {
                            showPassword.toggle()
                        }
                    } label: {
                        Image(systemName: showPassword ? "eye.slash" : "eye")
                            .foregroundColor(.gray)
                            .padding(10)
                            .contentShape(Rectangle()) // Aumenta el área táctil del botón.
                    }
                }
            }
        }
    }
}
