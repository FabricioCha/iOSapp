//
//  EnhancedHomeView.swift
//  ProyectIOs
//
//  Created by Fabricio Chavez on Enhanced Home - Phase 2
//

import SwiftUI

struct EnhancedHomeView: View {
    
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var habitsViewModel: HabitsViewModel
    
    @StateObject private var dashboardViewModel = EnhancedDashboardViewModel()
    
    @State private var showingAddHabit = false
    @State private var selectedHabitType: HabitType = .good
    @State private var searchText = ""
    @State private var showingFilterOptions = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                
                if dashboardViewModel.isLoading && dashboardViewModel.habitsWithStats.isEmpty {
                    loadingView
                } else if !dashboardViewModel.isLoading && dashboardViewModel.habitsWithStats.isEmpty && dashboardViewModel.alertItem != nil {
                    errorStateView
                } else {
                    ScrollView {
                        LazyVStack(spacing: 20) {
                            
                            // MARK: - Welcome Header
                            welcomeHeaderSection
                            
                            // MARK: - Quick Stats Cards
                            quickStatsSection
                            
                            // MARK: - Today's Progress
                            todaysProgressSection
                            
                            // MARK: - Habits List
                            habitsListSection
                            
                            Spacer(minLength: 100)
                        }
                        .padding(.top)
                    }
                    .refreshable {
                        await loadAllData()
                    }
                }
            }
            .foregroundColor(Color.appTextPrimary)
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack {
                        Text(getGreeting())
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 12) {
                        Button {
                            showingFilterOptions = true
                        } label: {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                                .font(.title3)
                        }
                        
                        Button {
                            showingAddHabit = true
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(Color.appPrimaryAction)
                        }
                    }
                }
            }
            .onAppear {
                Task {
                    await loadAllData()
                }
            }
            .alert(item: Binding<AlertItem?>(
                get: { dashboardViewModel.alertItem },
                set: { dashboardViewModel.alertItem = $0 }
            )) { alertItem in
                Alert(title: alertItem.title, message: alertItem.message, dismissButton: alertItem.dismissButton)
            }
            .sheet(isPresented: $showingAddHabit) {
                OnboardingContainerView()
            }
            .sheet(isPresented: $showingFilterOptions) {
                FilterOptionsView(selectedType: $selectedHabitType)
            }
        }
        .searchable(text: $searchText, prompt: "Buscar hábitos...")
    }
    
    // MARK: - Welcome Header Section
    private var welcomeHeaderSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("¡Hola, \(authViewModel.currentUser?.name ?? "Usuario")!")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text(getCurrentDateString())
                        .font(.callout)
                        .foregroundColor(Color.appTextSecondary)
                }
                
                Spacer()
                
                // Avatar pequeño
                ZStack {
                    Circle()
                        .fill(LinearGradient(
                            colors: [Color.appPrimaryAction, Color.appPrimaryAction.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 50, height: 50)
                    
                    Text(getInitials())
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
            }
            
            // Motivational message
            if dashboardViewModel.currentStreak > 0 {
                HStack {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.orange)
                    Text("¡Llevas \(String(dashboardViewModel.currentStreak)) días de racha!")
                        .font(.callout)
                        .fontWeight(.medium)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.orange.opacity(0.1))
                .cornerRadius(20)
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - Quick Stats Section
    private var quickStatsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Resumen de Hoy")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    QuickStatCard(
                        title: "Racha Actual",
                        value: String(dashboardViewModel.currentStreak),
                        subtitle: "días",
                        iconName: "flame.fill",
                        color: .orange
                    )
                    
                    QuickStatCard(
                        title: "Hábitos Activos",
                        value: String(dashboardViewModel.totalHabits),
                        subtitle: "total",
                        iconName: "target",
                        color: .blue
                    )
                    
                    QuickStatCard(
                        title: "Buenos Hábitos",
                        value: String(dashboardViewModel.goodHabits),
                        subtitle: "positivos",
                        iconName: "checkmark.circle.fill",
                        color: .green
                    )
                    
                    QuickStatCard(
                        title: "Adicciones",
                        value: String(dashboardViewModel.addictions),
                        subtitle: "controlando",
                        iconName: "shield.fill",
                        color: .red
                    )
                }
                .padding(.horizontal)
            }
        }
    }
    
    // MARK: - Today's Progress Section
    private var todaysProgressSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Progreso de Hoy")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            .padding(.horizontal)
            
            // Circular Progress
            HStack {
                Spacer()
                
                ZStack {
                    // Background circle
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 12)
                        .frame(width: 120, height: 120)
                    
                    // Progress circle
                    Circle()
                        .trim(from: 0, to: progressPercentage)
                        .stroke(
                            LinearGradient(
                                colors: [Color.orange, Color.orange.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 12, lineCap: .round)
                        )
                        .frame(width: 120, height: 120)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 1.0), value: progressPercentage)
                    
                    // Center content
                    VStack(spacing: 4) {
                        Text("\(String(completedTodayCount))/\(String(dashboardViewModel.totalHabits))")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(Color.appTextPrimary)
                        
                        Text("\(Int(progressPercentage * 100))/100")
                            .font(.caption)
                            .foregroundColor(Color.appTextSecondary)
                    }
                }
                
                Spacer()
            }
            
            // Motivational message
            HStack {
                Spacer()
                Text(motivationalMessage)
                    .font(.callout)
                    .fontWeight(.medium)
                    .foregroundColor(Color.appPrimaryAction)
                    .multilineTextAlignment(.center)
                Spacer()
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Habits List Section
    private var habitsListSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Mis Hábitos")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
                
                if !dashboardViewModel.habitsWithStats.isEmpty {
                    Text("\(String(filteredHabits.count)) hábitos")
                        .font(.caption)
                        .foregroundColor(Color.appTextSecondary)
                }
            }
            .padding(.horizontal)
            
            if dashboardViewModel.habitsWithStats.isEmpty {
                emptyStateView
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(filteredHabits, id: \.id) { habit in
                        EnhancedHabitRowView(habit: habit) {
                            Task {
                                await loadAllData()
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    // MARK: - Loading View
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text("Cargando tus hábitos...")
                .font(.callout)
                .foregroundColor(Color.appTextSecondary)
        }
    }
    
    // MARK: - Empty State View
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "target")
                .font(.system(size: 60))
                .foregroundColor(Color.appPrimaryAction.opacity(0.6))
            
            VStack(spacing: 8) {
                Text("¡Comienza tu viaje!")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Crea tu primer hábito y comienza a construir la mejor versión de ti mismo.")
                    .font(.callout)
                    .foregroundColor(Color.appTextSecondary)
                    .multilineTextAlignment(.center)
            }
            
            Button(action: {
                showingAddHabit = true
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Crear Mi Primer Hábito")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .background(Color.appPrimaryAction)
                .cornerRadius(15)
            }
        }
        .padding()
        .background(Color.appCardBackground)
        .cornerRadius(20)
        .padding(.horizontal)
    }
    
    // MARK: - Error State View
    private var errorStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 60))
                .foregroundColor(.orange)
            
            VStack(spacing: 8) {
                Text("Error de Conexión")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("No se pudieron cargar los datos. Verifica tu conexión a internet.")
                    .font(.callout)
                    .foregroundColor(Color.appTextSecondary)
                    .multilineTextAlignment(.center)
            }
            
            Button(action: {
                Task {
                    await dashboardViewModel.retryLoadDashboardData()
                }
            }) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("Reintentar")
                }
                .font(.callout)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color.appPrimaryAction)
                .cornerRadius(25)
            }
        }
        .padding()
        .background(Color.appCardBackground)
        .cornerRadius(20)
        .padding(.horizontal)
    }
    
    // MARK: - Computed Properties
    
    private var filteredHabits: [HabitWithStats] {
        let filtered = dashboardViewModel.habitsWithStats.filter { habit in
            if !searchText.isEmpty {
                return habit.nombre.localizedCaseInsensitiveContains(searchText)
            }
            return true
        }
        
        // Apply type filter if needed
        switch selectedHabitType {
        case .good:
            return filtered.filter { $0.tipo == .siNo || $0.tipo == .medibleNumerico }
        case .bad:
            return filtered.filter { $0.tipo == .malHabito }
        case .all:
            return filtered
        }
    }
    
    private var completedTodayCount: Int {
        // This would need to be calculated based on today's logs
        // For now, returning a placeholder
        return dashboardViewModel.habitsWithStats.filter { $0.rachaActual > 0 }.count
    }
    
    private var progressPercentage: Double {
        guard dashboardViewModel.totalHabits > 0 else { return 0 }
        return Double(completedTodayCount) / Double(dashboardViewModel.totalHabits)
    }
    
    private var motivationalMessage: String {
        let percentage = progressPercentage * 100
        switch percentage {
        case 0..<25:
            return "¡Vamos, puedes hacerlo!"
        case 25..<50:
            return "¡Buen comienzo!"
        case 50..<75:
            return "¡Vas muy bien!"
        case 75..<100:
            return "¡Casi terminas!"
        default:
            return "¡Excelente trabajo!"
        }
    }
    
    // MARK: - Helper Methods
    
    private func loadAllData() async {
        await dashboardViewModel.loadDashboardData()
    }
    
    private func getGreeting() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:
            return "Buenos días"
        case 12..<18:
            return "Buenas tardes"
        default:
            return "Buenas noches"
        }
    }
    
    private func getCurrentDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, d MMMM"
        formatter.locale = Locale(identifier: "es_ES")
        return formatter.string(from: Date()).capitalized
    }
    
    private func getInitials() -> String {
        guard let name = authViewModel.currentUser?.name else { return "U" }
        let components = name.components(separatedBy: " ")
        let initials = components.compactMap { $0.first }.map { String($0) }
        return initials.prefix(2).joined().uppercased()
    }
}

// MARK: - Supporting Types

enum HabitType: String, CaseIterable {
    case all = "Todos"
    case good = "Buenos Hábitos"
    case bad = "Adicciones"
}

// MARK: - Supporting Views

struct EnhancedHabitRowView: View {
    let habit: HabitWithStats
    let onUpdate: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // Habit icon/indicator
            ZStack {
                Circle()
                    .fill(habitColor.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: habitIcon)
                    .font(.title3)
                    .foregroundColor(habitColor)
            }
            
            // Habit info
            VStack(alignment: .leading, spacing: 4) {
                Text(habit.nombre)
                    .font(.callout)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                
                HStack {
                    Image(systemName: "flame.fill")
                        .font(.caption)
                        .foregroundColor(.orange)
                    
                    Text("\(String(habit.rachaActual)) días")
                        .font(.caption)
                        .foregroundColor(Color.appTextSecondary)
                    
                    Spacer()
                    
                    Text(habit.tipo == .malHabito ? "Adicción" : "Hábito")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(habitColor.opacity(0.2))
                        .foregroundColor(habitColor)
                        .cornerRadius(8)
                }
            }
            
            Spacer()
            
            // Action button
            Button {
                // Handle habit action
                onUpdate()
            } label: {
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(Color.appTextSecondary)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(16)
    }
    
    private var habitColor: Color {
        switch habit.tipo {
        case .siNo, .medibleNumerico:
            return .green
        case .malHabito:
            return .red
        }
    }
    
    private var habitIcon: String {
        switch habit.tipo {
        case .siNo:
            return "checkmark.circle.fill"
        case .medibleNumerico:
            return "number.circle.fill"
        case .malHabito:
            return "xmark.circle.fill"
        }
    }
}

struct FilterOptionsView: View {
    @Binding var selectedType: HabitType
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Filtrar Hábitos")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top)
                
                VStack(spacing: 12) {
                    ForEach(HabitType.allCases, id: \.self) { type in
                        Button {
                            selectedType = type
                            dismiss()
                        } label: {
                            HStack {
                                Text(type.rawValue)
                                    .font(.callout)
                                    .fontWeight(.medium)
                                    .foregroundColor(Color.appTextPrimary)
                                
                                Spacer()
                                
                                if selectedType == type {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(Color.appPrimaryAction)
                                }
                            }
                            .padding()
                            .background(Color.gray.opacity(0.05))
                            .cornerRadius(12)
                        }
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationTitle("")
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

// MARK: - Preview

//#Preview {
//    struct PreviewWrapper: View {
//        private static let authViewModel: AuthViewModel = {
//            let vm = AuthViewModel()
//            vm.currentUser = User(
//                id: 1,
//                name: "Usuario de Prueba",
//                email: "preview@test.com"
//            )
//            return vm
//        }()
//        
//        var body: some View {
//            EnhancedHomeView()
//                .environmentObject(Self.authViewModel)
//                .environmentObject(HabitsViewModel())
//        }
//    }
//    
//    return PreviewWrapper()
//}
