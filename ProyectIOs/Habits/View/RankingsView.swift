//
//  RankingsView.swift
//  ProyectIOs
//
//  Created by Trae AI on 2024.
//

import SwiftUI

struct RankingsView: View {
    @StateObject private var rankingsViewModel = RankingsViewModel()
    
    var body: some View {
        ZStack {
            // Fondo consistente con el resto de la app.
            Color.appBackground.ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Título de rankings
                Text("Rankings y Clasificaciones")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .hSpacing(.leading)
                
                // Scope selector
                Picker("Scope", selection: $rankingsViewModel.selectedScope) {
                    ForEach(RankingScope.allCases, id: \.self) { scope in
                        Text(scope.displayName).tag(scope)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                .onChange(of: rankingsViewModel.selectedScope) { newScope in
                    rankingsViewModel.changeScope(newScope)
                }
                
                // Rankings list
                if rankingsViewModel.isLoading {
                    ProgressView("Cargando rankings...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let errorMessage = rankingsViewModel.errorMessage {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundColor(.orange)
                        Text(errorMessage)
                            .multilineTextAlignment(.center)
                            .foregroundColor(Color.appTextSecondary)
                        Button("Reintentar") {
                            rankingsViewModel.refreshRankings()
                        }
                        .foregroundColor(Color.appPrimaryAction)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(Array(rankingsViewModel.rankings.enumerated()), id: \.element.id) { index, ranking in
                                RankingRowView(ranking: ranking, position: index + 1)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .refreshable {
                        rankingsViewModel.refreshRankings()
                    }
                }
            }
            .padding()
            .foregroundColor(Color.appTextPrimary)
        }
    }
}

#Preview {
    RankingsView()
}