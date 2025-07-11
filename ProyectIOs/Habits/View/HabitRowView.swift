//
//  TaskRowView.swift
//  ProyectIOs
//
//  Created by Fabricio Chavez on 15/06/25.
//
import SwiftUI

struct HabitRowView: View {
    
    @EnvironmentObject var habitsViewModel: HabitsViewModel
    let habit: Habit
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: iconForType(habit.tipo))
                .font(.title)
                .frame(width: 40)
                .foregroundColor(Color.appPrimaryAction)

            VStack(alignment: .leading, spacing: 4) {
                Text(habit.nombre)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                // Mostramos la meta si existe, formateándola como un número.
                if let meta = habit.meta_objetivo {
                    Text("Meta: \(meta, specifier: "%.1f")") // Formatea el número
                        .font(.callout)
                        .foregroundStyle(Color.appTextSecondary)
                }
            }
            
            Spacer()
            
            // --- CORRECCIÓN ---
            // La clave del diccionario ahora debe ser un String del ID numérico.
            if habitsViewModel.completionStatus[String(habit.id), default: false] {
                Image(systemName: "checkmark.circle.fill")
                    .font(.largeTitle)
                    .foregroundStyle(Color.appSuccess)
                    .transition(.scale)
            }
        }
        .padding()
        .background(Color.appCardBackground)
        .cornerRadius(15)
        .animation(.spring(), value: habitsViewModel.completionStatus[String(habit.id)])
    }
    
    private func iconForType(_ type: ApiHabitType) -> String {
        switch type {
        case .siNo:
            return "checkmark.seal.fill"
        case .medibleNumerico:
            return "number.circle.fill"
        case .malHabito:
            return "xmark.shield.fill"
        }
    }
}

// Preview para ver cómo se ve la fila en diferentes estados.
#Preview {
    // Creamos dos hábitos de muestra para la preview.
//    let sampleHabitCompleted = Habit(
//        id: UUID(),
//        userId: UUID(),
//        title: "Leer un Libro",
//        habitType: .newGoodHabit,
//        area: .personalGrowth,
//        difficulty: .easy,
//        goal: "Leer 1 capítulo",
//        creationDate: Date(),
//        completionDates: [Date()] // Se completó hoy.
//    )
//    
//    let sampleHabitPending = Habit(
//        id: UUID(),
//        userId: UUID(),
//        title: "Hacer Ejercicio",
//        habitType: .newGoodHabit,
//        area: .health,
//        difficulty: .moderate,
//        goal: "30 minutos de cardio",
//        creationDate: Date()
//        // No tiene fechas de completado.
//    )
//    
//    return VStack(spacing: 15) {
//        HabitRowView(habit: sampleHabitCompleted)
//        HabitRowView(habit: sampleHabitPending)
//    }
//    .padding()
//    .background(Color.appBackground)
}
