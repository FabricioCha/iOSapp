import Foundation
import Combine
import SwiftUI

class AuthViewModel: ObservableObject {
    
    private let networkService: NetworkService = .shared
    private let keychainService = KeychainService.shared
    private let gamificationService = GamificationService()
    
    @Published var currentUser: User?
    @Published var isLoggedIn: Bool = false
    @Published var email = ""
    @Published var password = ""
    @Published var fullName = ""
    @Published var alertItem: AlertItem?
    @Published var isLoading = false
    @Published var newlyAwardedBadges: [Badge] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        $currentUser
            .map { $0 != nil }
            .assign(to: \.isLoggedIn, on: self)
            .store(in: &cancellables)
        
        Task {
            await checkForPersistedSession()
        }
    }
    
    @MainActor
    func checkForPersistedSession() async {
        guard let token = keychainService.getToken() else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        networkService.setAuthToken(token)
        do {
            let user = try await networkService.fetchCurrentUser()
            var userWithBadges = user
            userWithBadges.unlockedBadgeIDs = loadBadges(for: user.id)
            self.currentUser = userWithBadges
        } catch {
            networkService.setAuthToken(nil)
        }
    }
    
    @MainActor
    func login() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let authResponse = try await networkService.login(email: self.email, password: self.password)
            networkService.setAuthToken(authResponse.token)
            
            var user = authResponse.user
            user.unlockedBadgeIDs = loadBadges(for: user.id)
            self.currentUser = user
            
            resetFields()
        } catch {
            self.alertItem = AlertItem.from(error: error)
        }
    }
    
    @MainActor
    func signup() async {
        isLoading = true
        defer { isLoading = false }
        do {
            _ = try await networkService.register(nombre: self.fullName, email: self.email, password: self.password)
            await login()
        } catch {
            self.alertItem = AlertItem.from(error: error)
        }
    }
    
    @MainActor
    func logout(habitsViewModel: HabitsViewModel) {
        networkService.setAuthToken(nil)
        self.currentUser = nil
//        habitsViewModel.clearHabits()
        resetFields()
    }
    
    private func resetFields() {
        email = ""
        password = ""
        fullName = ""
    }
    
    @MainActor
    func checkAwards() {
        Task {
            guard var user = self.currentUser else { return }
            
            do {
                let dashboardData = try await networkService.fetchDashboardData()
                let awardedBadges = gamificationService.checkAndAwardBadges(dashboardData: dashboardData, for: user)
                
                if !awardedBadges.isEmpty {
                    for badge in awardedBadges {
                        user.unlockedBadgeIDs = (user.unlockedBadgeIDs ?? []) + [badge.id]
                    }
                    saveBadges(for: user.id, badges: user.unlockedBadgeIDs ?? [])
                    
                    self.currentUser = user
                    self.newlyAwardedBadges = awardedBadges
                }
            } catch {
                print("No se pudieron comprobar los logros: \(error.localizedDescription)")
            }
        }
    }
    
    func clearNewlyAwardedBadges() {
        self.newlyAwardedBadges = []
    }
    
    private func saveBadges(for userId: String, badges: [String]) {
        UserDefaults.standard.set(badges, forKey: "unlockedBadges_\(userId)")
    }
    
    private func loadBadges(for userId: String) -> [String] {
        return UserDefaults.standard.array(forKey: "unlockedBadges_\(userId)") as? [String] ?? []
    }
}
