//
//  EditRoutineView.swift
//  ProyectIOs
//
//  Created by Trae AI on 2024.
//

import SwiftUI

struct EditRoutineView: View {
    @ObservedObject var viewModel: RoutinesViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var routineToEdit: Routine?
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Información de la Rutina")) {
                    TextField("Nombre de la rutina", text: $viewModel.routineName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("Descripción (opcional)", text: $viewModel.routineDescription, axis: .vertical)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Editar Rutina")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Guardar") {
                    if let routine = routineToEdit {
                        Task {
                            await viewModel.updateRoutine(routine)
                        }
                    }
                }
                    .disabled(viewModel.routineName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isLoading)
                }
            }
        }
        .disabled(viewModel.isLoading)
        .onAppear {
            // Encontrar la rutina que se está editando
            routineToEdit = viewModel.routines.first { routine in
                routine.nombre == viewModel.routineName
            }
        }
        .onChange(of: viewModel.showEditRoutineSheet) { showing in
            if !showing {
                dismiss()
            }
        }
    }
}

#Preview {
    EditRoutineView(viewModel: RoutinesViewModel())
}