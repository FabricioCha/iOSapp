//
//  RoutineDetailView.swift
//  ProyectIOs
//
//  Created by Trae AI on 2024.
//

import SwiftUI

struct RoutineDetailView: View {
    let routine: Routine
    @ObservedObject var viewModel: RoutinesViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showingDeleteAlert = false
    
    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.selectedRoutine == nil {
                VStack {
                    ProgressView("Cargando rutina...")
                        .padding()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Header de la rutina
                        routineHeaderView
                        
                        // Sección de hábitos
                        habitsSection
                    }
                    .padding()
                }
            }
        }
        .navigationTitle(viewModel.selectedRoutine?.nombre ?? routine.nombre)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button {
                        viewModel.prepareForEdit(routine)
                    } label: {
                        Label("Editar Rutina", systemImage: "pencil")
                    }
                    
                    Button {
                        viewModel.prepareForAddingHabits(routineId: routine.id)
                    } label: {
                        Label("Agregar Hábitos", systemImage: "plus")
                    }
                    
                    Divider()
                    
                    Button(role: .destructive) {
                        showingDeleteAlert = true
                    } label: {
                        Label("Eliminar Rutina", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .onAppear {
            viewModel.loadRoutineDetails(routineId: routine.id)
        }
        .sheet(isPresented: $viewModel.showEditRoutineSheet) {
            EditRoutineView(viewModel: viewModel)
        }
        .sheet(isPresented: $viewModel.showAddHabitSheet) {
            AddHabitsToRoutineView(viewModel: viewModel, routineId: routine.id)
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK") { }
        } message: {
            Text(viewModel.errorMessage ?? "Error desconocido")
        }
        .alert("Eliminar Rutina", isPresented: $showingDeleteAlert) {
            Button("Cancelar", role: .cancel) { }
            Button("Eliminar", role: .destructive) {
                Task {
                    await viewModel.deleteRoutineAndDismiss(routineId: routine.id)
                    dismiss()
                }
            }
        } message: {
            Text("¿Estás seguro de que quieres eliminar esta rutina? Esta acción no se puede deshacer.")
        }
    }
    
    private var routineHeaderView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "calendar.circle.fill")
                    .font(.title)
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading) {
                    Text(viewModel.selectedRoutine?.nombre ?? routine.nombre)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Creada el \(routine.formattedCreatedAt)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            if let descripcion = viewModel.selectedRoutine?.descripcion ?? routine.descripcion, !descripcion.isEmpty {
                Text(descripcion)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private var habitsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Hábitos")
                    .font(.title3)
                    .fontWeight(.semibold)
                
                Spacer()
                
                if let details = viewModel.selectedRoutine {
                    Text("\(details.habits.count) hábitos")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            if viewModel.isLoading {
                HStack {
                    Spacer()
                    ProgressView("Cargando hábitos...")
                    Spacer()
                }
                .padding()
            } else if let details = viewModel.selectedRoutine, !details.habits.isEmpty {
                LazyVStack(spacing: 12) {
                    ForEach(details.habits) { habit in
                        HabitInRoutineRowView(
                            habit: habit,
                            onRemove: {
                                viewModel.removeHabitFromRoutine(routineId: routine.id, habitId: habit.id)
                            }
                        )
                    }
                }
            } else {
                emptyHabitsView
            }
        }
    }
    
    private var emptyHabitsView: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.badge.questionmark")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            
            Text("No hay hábitos en esta rutina")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Agrega hábitos para comenzar a organizar tu rutina diaria")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button {
                viewModel.prepareForAddingHabits(routineId: routine.id)
            } label: {
                Label("Agregar Hábitos", systemImage: "plus")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct HabitInRoutineRowView: View {
    let habit: Habit
    let onRemove: () -> Void
    @State private var showingRemoveAlert = false
    
    var body: some View {
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
            
            Button {
                showingRemoveAlert = true
            } label: {
                Image(systemName: "minus.circle.fill")
                    .foregroundColor(.red)
                    .font(.title2)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        .alert("Remover Hábito", isPresented: $showingRemoveAlert) {
            Button("Cancelar", role: .cancel) { }
            Button("Remover", role: .destructive) {
                onRemove()
            }
        } message: {
            Text("¿Quieres remover este hábito de la rutina?")
        }
    }
}

#Preview {
    NavigationView {
        RoutineDetailView(
            routine: Routine(
                id: 1,
                usuarioId: 1,
                nombre: "Rutina Matutina",
                descripcion: "Mi rutina para empezar bien el día",
                fechaCreacion: "2024-01-15T08:00:00.000Z"
            ),
            viewModel: RoutinesViewModel()
        )
    }
}