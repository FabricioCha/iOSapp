import SwiftUI
import CoreMotion

struct ContentView: View {
    
    @StateObject private var authViewModel = AuthViewModel()
    // El HabitsViewModel ahora se crea aquí para que esté disponible globalmente.
    @StateObject private var habitsViewModel = HabitsViewModel()
    
    @Namespace private var ns
    
    @State private var showSignup = false
    
    var body: some View {
        ZStack {
            Group {
                if authViewModel.isLoggedIn, let currentUser = authViewModel.currentUser {
                    MainTabView(user: currentUser)	
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
            // Inyectamos ambos ViewModels para que estén disponibles en toda la app.
            .environmentObject(authViewModel)
            .environmentObject(habitsViewModel)
            
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
