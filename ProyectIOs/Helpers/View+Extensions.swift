//
//  View+Extensions.swift
//  ProyectIOs
//
//  Created by Fabricio Chavez on 12/06/25.
//
import SwiftUI

// Estas extensiones nos permiten añadir funcionalidades personalizadas
// a cualquier vista en SwiftUI, haciendo nuestro código más limpio y reutilizable.
extension View {
    
    /// Alinea la vista horizontalmente dentro de su contenedor padre.
    /// - Parameter alignment: El tipo de alineación (ej. .leading, .center, .trailing). Por defecto es .center.
    /// - Returns: Una vista que ocupa todo el ancho disponible con el contenido alineado.
    @ViewBuilder
    func hSpacing(_ alignment: Alignment = .center) -> some View {
        self
            .frame(maxWidth: .infinity, alignment: alignment)
    }
    
    /// Alinea la vista verticalmente dentro de su contenedor padre.
    /// - Parameter alignment: El tipo de alineación (ej. .top, .center, .bottom). Por defecto es .center.
    /// - Returns: Una vista que ocupa toda la altura disponible con el contenido alineado.
    @ViewBuilder
    func vSpacing(_ alignment: Alignment = .center) -> some View {
        self
            .frame(maxHeight: .infinity, alignment: alignment)
    }
    
    /// Deshabilita la vista y aplica un efecto de opacidad si la condición es verdadera.
    /// - Parameter condition: La condición booleana que determina si la vista debe estar deshabilitada.
    /// - Returns: Una vista modificada.
    @ViewBuilder
    func disableWithOpacity(_ condition: Bool) -> some View {
        self
            .disabled(condition)
            .opacity(condition ? 0.5 : 1)
    }
}
