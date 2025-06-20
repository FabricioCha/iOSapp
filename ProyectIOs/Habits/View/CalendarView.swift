//
//  CalendarView.swift
//  ProyectIOs
//
//  Created by Fabricio Chavez on 15/06/25.
//
import SwiftUI

struct CalendarView: View {
    
    // El @State nos permite tener una fuente de verdad para la fecha seleccionada.
    // La inicializamos con la fecha y hora actual.
    @State private var selectedDate: Date = Date()
    
    var body: some View {
        HStack {
            // Iteramos sobre los 7 días de la semana actual.
            ForEach(fetchWeek(), id: \.self) { day in
                VStack(spacing: 10) {
                    // Mostramos el nombre del día (ej. "M")
                    Text(day.toString(format: "E").prefix(1))
                        .font(.callout)
                        .fontWeight(.medium)
                        .foregroundStyle(Color.appTextSecondary)
                    
                    // Mostramos el número del día (ej. "16")
                    Text(day.toString(format: "d"))
                        .font(.callout)
                        .fontWeight(.bold)
                        .foregroundStyle(isSameDay(date1: day, date2: selectedDate) ? .white : Color.appTextPrimary)
                        .frame(width: 35, height: 35)
                        // Resaltamos el día seleccionado
                        .background {
                            if isSameDay(date1: day, date2: selectedDate) {
                                Circle()
                                    .fill(Color.appPrimaryAction)
                            }
                        }
                }
                .hSpacing() // Usamos nuestra extensión para que cada día ocupe el mismo espacio.
                .onTapGesture {
                    // Permitimos al usuario seleccionar otro día
                    selectedDate = day
                }
            }
        }
        .padding(.vertical, 10)
    }
    
    // MARK: - Helper Functions
    
    /// Comprueba si dos fechas corresponden al mismo día (ignorando la hora).
    func isSameDay(date1: Date, date2: Date) -> Bool {
        return Calendar.current.isDate(date1, inSameDayAs: date2)
    }
    
    /// Devuelve un array de Fechas (`Date`) para la semana actual, de Lunes a Domingo.
    func fetchWeek() -> [Date] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date()) // Empezamos desde el inicio del día de hoy.
        
        // El calendario Gregoriano considera el Domingo como el primer día (1).
        // Necesitamos ajustar esto para que nuestra semana empiece en Lunes.
        let dayOfWeek = calendar.component(.weekday, from: today)
        // Si hoy es Domingo (1), retrocedemos 6 días. Si es Lunes (2), retrocedemos 0. Si es Martes (3), 1...
        let daysToSubtract = (dayOfWeek == 1) ? 6 : (dayOfWeek - 2)
        
        guard let startOfWeek = calendar.date(byAdding: .day, value: -daysToSubtract, to: today) else {
            return []
        }
        
        var week: [Date] = []
        for i in 0..<7 {
            if let day = calendar.date(byAdding: .day, value: i, to: startOfWeek) {
                week.append(day)
            }
        }
        return week
    }
}

// Creamos una pequeña extensión de Date para formatear fechas fácilmente.
extension Date {
    func toString(format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        // Opcional: Asegurarse de que el formato sea consistente independientemente del dispositivo del usuario.
        formatter.locale = Locale(identifier: "es_ES")
        return formatter.string(from: self)
    }
}


#Preview {
    CalendarView()
        .padding()
        .background(Color.appBackground)
}
