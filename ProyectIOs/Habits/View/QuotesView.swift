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

// La vista que muestra una frase motivacional al usuario.
struct QuotesView: View {
    @StateObject private var viewModel = QuotesViewModel()
    
    var body: some View {
        ZStack {
            // Fondo consistente con el resto de la app.
            Color.appBackground.ignoresSafeArea()
            
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
    }
}

#Preview {
    QuotesView()
}
