//
//  QuotesView.swift
//  ProyectIOs
//
//  Created by Fabricio Chavez on 16/06/25.
//

import SwiftUI

// ViewModel para la lógica de la pantalla de frases.
class QuotesViewModel: ObservableObject {
    @Published var currentQuote: Quote?
    @Published var selectedTab: QuotesTab = .quotes
    private var allQuotes: [Quote] = []

    init() {
        loadQuotesFromBundle()
        fetchNewQuote()
    }
    
    func fetchNewQuote() {
        self.currentQuote = allQuotes.randomElement()
    }
    
    private func loadQuotesFromBundle() {
        do {
            // Asegura que el archivo quotes.json exista en el bundle.
            guard let fileUrl = Bundle.main.url(forResource: "quotes", withExtension: "json") else {
                throw APIError.requestFailed(description: "quotes.json no encontrado")
            }
            let data = try Data(contentsOf: fileUrl)
            // Decodifica el JSON a un array de objetos Quote.
            self.allQuotes = try JSONDecoder().decode([Quote].self, from: data)
        } catch {
            print("Error fatal al cargar quotes.json: \(error)")
            // Si falla la carga, provee una frase por defecto.
            self.allQuotes = [Quote(id: UUID(), text: "El mayor error es no haber intentado.", author: "Sistema")]
        }
    }
}

enum QuotesTab: String, CaseIterable {
    case quotes = "Frases"
    case rankings = "Rankings"
    
    var icon: String {
        switch self {
        case .quotes:
            return "quote.opening"
        case .rankings:
            return "trophy.fill"
        }
    }
}

// La vista que muestra una frase motivacional al usuario.
struct QuotesView: View {
    @StateObject private var viewModel = QuotesViewModel()
    @StateObject private var rankingsViewModel = RankingsViewModel()
    
    var body: some View {
        ZStack {
            // Fondo consistente con el resto de la app.
            Color.appBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Custom Tab Bar
                HStack {
                    ForEach(QuotesTab.allCases, id: \.self) { tab in
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                viewModel.selectedTab = tab
                            }
                        }) {
                            VStack(spacing: 8) {
                                Image(systemName: tab.icon)
                                    .font(.title2)
                                Text(tab.rawValue)
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                            .foregroundColor(viewModel.selectedTab == tab ? Color.appPrimaryAction : Color.appTextSecondary)
                            .frame(maxWidth: .infinity)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 16)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal)
                .padding(.top, 20)
                
                // Content based on selected tab
                TabView(selection: $viewModel.selectedTab) {
                    quotesContent
                        .tag(QuotesTab.quotes)
                    
                    rankingsContent
                        .tag(QuotesTab.rankings)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
        }
    }
    
    // MARK: - Quotes Content
    private var quotesContent: some View {
        VStack(spacing: 40) {
            // Título de la pantalla
            Text("Frase del Momento")
                .font(.largeTitle)
                .fontWeight(.bold)
                .hSpacing(.leading)
            
            // Tarjeta que contiene la frase.
            if let quote = viewModel.currentQuote {
                VStack(alignment: .center, spacing: 20) {
                    Image(systemName: "quote.opening")
                        .font(.largeTitle)
                        .foregroundColor(Color.appPrimaryAction)
                    
                    Text(quote.text)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .italic()
                    
                    Text("— \(quote.author)")
                        .font(.headline)
                        .foregroundStyle(Color.appTextSecondary)
                }
                .padding(30)
                .background(Color.gray.opacity(0.15))
                .cornerRadius(20)
                .transition(.opacity.combined(with: .scale))
            } else {
                // Mensaje por si no se pudieron cargar las frases.
                Text("No se encontraron frases.")
                    .foregroundColor(Color.appTextSecondary)
            }
            
            Spacer()
            
            // Botón para obtener una nueva frase.
            GradientButton(
                title: "Nueva Frase",
                icon: "arrow.clockwise.circle",
                action: {
                    // Aplica una animación suave al cambiar de frase.
                    withAnimation {
                        viewModel.fetchNewQuote()
                    }
                }
            )
            .padding(.bottom, 40)
        }
        .padding()
        .foregroundColor(Color.appTextPrimary)
    }
    
    // MARK: - Rankings Content
    private var rankingsContent: some View {
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

#Preview {
    QuotesView()
}
