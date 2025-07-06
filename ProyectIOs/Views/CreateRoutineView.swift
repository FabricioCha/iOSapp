//
//  CreateRoutineView.swift
//  ProyectIOs
//
//  Created by Trae AI on 2024.
//

import SwiftUI

struct CreateRoutineView: View {
    @ObservedObject var viewModel: RoutinesViewModel
    @Environment(\.dismiss) private var dismiss
    
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
                
                Section(footer: Text("Podrás agregar hábitos a tu rutina después de crearla.")) {
                    // Placeholder para información adicional
                }
            }
            .navigationTitle("Nueva Rutina")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Crear") {
                        Task {
                            await viewModel.createRoutine()
                        }
                    }
                    .disabled(viewModel.routineName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isLoading)
                }
            }
        }
        .disabled(viewModel.isLoading)
        .onChange(of: viewModel.showCreateRoutineSheet) { showing in
            if !showing {
                dismiss()
            }
        }
    }
}

#Preview {
    CreateRoutineView(viewModel: RoutinesViewModel())
}