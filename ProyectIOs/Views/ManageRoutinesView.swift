//
//  ManageRoutinesView.swift
//  ProyectIOs
//
//  Created by Fabricio Chavez on 05/01/25.
//

import SwiftUI

struct ManageRoutinesView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = RoutinesViewModel()
    @State private var showingDeleteAlert = false
    @State private var routineToDelete: Routine?
    
    var body: some View {
        // 1. Reemplazamos NavigationView por NavigationStack
        NavigationStack {
            ZStack {
                if viewModel.isLoading {
                    ProgressView("Cargando rutinas...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.routines.isEmpty {
                    emptyStateView
                } else {
                    routinesListView
                }
            }
            .navigationTitle("Rutinas")
            .navigationBarTitleDisplayMode(.inline)
            // 3. Añadimos el destino de la navegación para el tipo Routine
            .navigationDestination(for: Routine.self) { routine in
                RoutineDetailView(routine: routine, viewModel: viewModel)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cerrar") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.prepareForCreating()
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .refreshable {
                viewModel.loadRoutines()
            }
        }
        .sheet(isPresented: $viewModel.showCreateRoutineSheet) {
            CreateRoutineView(viewModel: viewModel)
        }
        .sheet(isPresented: $viewModel.showEditRoutineSheet) {
            EditRoutineView(viewModel: viewModel)
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK") { }
        } message: {
            Text(viewModel.errorMessage ?? "Error desconocido")
        }
        .alert("Eliminar Rutina", isPresented: $showingDeleteAlert) {
            Button("Cancelar", role: .cancel) { }
            Button("Eliminar", role: .destructive) {
                if let routine = routineToDelete {
                    viewModel.deleteRoutine(routineId: routine.id)
                }
            }
        } message: {
            Text("¿Estás seguro de que quieres eliminar esta rutina? Esta acción no se puede deshacer.")
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "calendar.circle")
                .font(.system(size: 80))
                .foregroundColor(.gray)
            
            Text("No tienes rutinas")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Crea tu primera rutina para organizar tus hábitos diarios")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button {
                viewModel.prepareForCreating()
            } label: {
                Label("Crear Rutina", systemImage: "plus")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding()
    }
    
    private var routinesListView: some View {
        List {
            ForEach(viewModel.routines) { routine in
                // 2. Cambiamos el NavigationLink para que navegue con un "valor"
                NavigationLink(value: routine) {
                    RoutineRowView(routine: routine)
                }
            }
            .onDelete(perform: deleteRoutines)
        }
        .listStyle(PlainListStyle())
    }
    
    private func deleteRoutines(offsets: IndexSet) {
        for index in offsets {
            routineToDelete = viewModel.routines[index]
            showingDeleteAlert = true
        }
    }
}

struct RoutineRowView: View {
    let routine: Routine
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(routine.nombre)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text(routine.formattedCreatedAt)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if let descripcion = routine.descripcion, !descripcion.isEmpty {
                Text(descripcion)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            HStack {
                Label("Rutina", systemImage: "checkmark.circle")
                    .font(.caption)
                    .foregroundColor(.blue)
                
                Spacer()
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ManageRoutinesView()
}
