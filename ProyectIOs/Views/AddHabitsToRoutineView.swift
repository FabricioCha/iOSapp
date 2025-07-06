//
//  AddHabitsToRoutineView.swift
//  ProyectIOs
//
//  Created by Trae AI on 2024.
//

import SwiftUI

struct AddHabitsToRoutineView: View {
    @ObservedObject var viewModel: RoutinesViewModel
    let routineId: Int
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.availableHabitsForRoutine.isEmpty {
                    emptyStateView
                } else {
                    habitsList
                }
            }
            .navigationTitle("Agregar Hábitos")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Agregar") {
                        viewModel.addSelectedHabitsToRoutine(routineId: routineId)
                    }
                    .disabled(viewModel.selectedHabits.isEmpty || viewModel.isLoading)
                }
            }
        }
        .disabled(viewModel.isLoading)
        .onChange(of: viewModel.showAddHabitSheet) { showing in
            if !showing {
                DispatchQueue.main.async {
                    dismiss()
                }
            }
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK") {
                viewModel.showError = false
            }
        } message: {
            Text(viewModel.errorMessage ?? "Error desconocido")
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.badge.questionmark")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No hay hábitos disponibles")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Todos tus hábitos ya están en esta rutina o no tienes hábitos creados")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("Cerrar") {
                dismiss()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding()
    }
    
    private var habitsList: some View {
        List {
            Section(header: Text("Selecciona los hábitos que quieres agregar")) {
                ForEach(viewModel.availableHabitsForRoutine) { habit in
                    HabitSelectionRowView(
                        habit: habit,
                        isSelected: viewModel.selectedHabits.contains(habit.id)
                    ) {
                        toggleHabitSelection(habit.id)
                    }
                }
            }
            
            if !viewModel.selectedHabits.isEmpty {
                Section {
                    HStack {
                        Text("\(viewModel.selectedHabits.count) hábito(s) seleccionado(s)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Button("Limpiar selección") {
                            viewModel.selectedHabits.removeAll()
                        }
                        .font(.caption)
                        .foregroundColor(.blue)
                    }
                }
            }
        }
        .listStyle(PlainListStyle())
    }
    
    private func toggleHabitSelection(_ habitId: Int) {
        if viewModel.selectedHabits.contains(habitId) {
            viewModel.selectedHabits.remove(habitId)
        } else {
            viewModel.selectedHabits.insert(habitId)
        }
    }
}

struct HabitSelectionRowView: View {
    let habit: Habit
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(habit.nombre)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    if let descripcion = habit.descripcion, !descripcion.isEmpty {
                        Text(descripcion)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                    
                    HStack {
                        Label(habit.tipo.displayName, systemImage: habit.tipo.icon)
                            .font(.caption)
                            .foregroundColor(habit.tipo.color)
                        
                        Spacer()
                    }
                }
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .blue : .gray)
                    .font(.title2)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    AddHabitsToRoutineView(
        viewModel: RoutinesViewModel(),
        routineId: 1
    )
}