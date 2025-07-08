//
//  SearchHabitsView.swift
//  ProyectIOs
//
//  Created by Fabricio Chavez on Search Habits View
//

import SwiftUI

struct SearchHabitsView: View {
    @Binding var searchText: String
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isSearchFocused: Bool
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(Color.appTextSecondary)
                    
                    TextField("Buscar hábitos...", text: $searchText)
                        .focused($isSearchFocused)
                        .textFieldStyle(PlainTextFieldStyle())
                    
                    if !searchText.isEmpty {
                        Button {
                            searchText = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(Color.appTextSecondary)
                        }
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal)
                
                // Search Instructions
                if searchText.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "magnifyingglass.circle")
                            .font(.system(size: 60))
                            .foregroundColor(Color.appPrimaryAction.opacity(0.6))
                        
                        Text("Buscar Hábitos")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Escribe el nombre del hábito que quieres encontrar")
                            .font(.callout)
                            .foregroundColor(Color.appTextSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                }
                
                Spacer()
            }
            .navigationTitle("Buscar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Buscar") {
                        dismiss()
                    }
                    .disabled(searchText.isEmpty)
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isSearchFocused = true
                }
            }
        }
    }
}

#Preview {
    SearchHabitsView(searchText: .constant(""))
}