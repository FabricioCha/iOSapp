//
//  ManageRoutinesView.swift
//  ProyectIOs
//
//  Created by Fabricio Chavez on 05/01/25.
//

import SwiftUI

struct ManageRoutinesView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "calendar.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                
                Text("Gestionar Rutinas")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Aquí podrás crear y gestionar tus rutinas diarias")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Spacer()
                
                Text("Próximamente...")
                    .font(.title2)
                    .foregroundColor(.blue)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                
                Spacer()
            }
            .padding()
            .navigationTitle("Rutinas")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cerrar") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    ManageRoutinesView()
}