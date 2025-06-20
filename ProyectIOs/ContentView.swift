import SwiftUI

struct ContentView: View {
    
    // El AuthViewModel ahora se inicializa directamente, sin dependencias.
    @StateObject private var authViewModel = AuthViewModel()
    
    @State private var showSignup = false
    
    var body: some View {
        // Un ZStack para poder mostrar un indicador de carga global sobre todo lo demás.
        ZStack {
            Group {
                if authViewModel.isLoggedIn, let currentUser = authViewModel.currentUser {
                    // La inicialización de MainTabView también deberá cambiar en la siguiente fase.
                    // Por ahora, lo dejamos así para que compile.
                    MainTabView(
                        user: currentUser
                        // dataService ya no existe, lo eliminaremos más adelante
                        // authViewModel se pasará por el entorno
                    )
                } else {
                    NavigationStack {
                        LoginView(showSignup: $showSignup)
                            .navigationBarHidden(true)
                            .navigationDestination(isPresented: $showSignup) {
                                SignupView(showSignup: $showSignup)
                                    .navigationBarHidden(true)
                            }
                    }
                }
            }
            .environmentObject(authViewModel) // Inyectamos el AuthViewModel en el entorno.
            
            // Si está cargando, muestra una vista de progreso.
            if authViewModel.isLoading {
                Color.black.opacity(0.4).ignoresSafeArea()
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(2)
            }
        }
    }
}


#Preview {
    ContentView()
}
