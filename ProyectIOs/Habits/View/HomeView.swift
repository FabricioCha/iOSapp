//
//  HomeView.swift
//  ProyectIOs
//
//  Created by Fabricio Chavez on 15/06/25.
//
import SwiftUI

struct HomeView: View {
    
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var habitsViewModel: HabitsViewModel
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color.appBackground.ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
                if let user = authViewModel.currentUser {
                    headerView(userName: user.name)
                        .padding(.horizontal)
                }
                
                CalendarView()
                    .padding(.horizontal)
                
                ScrollView {
                    VStack(spacing: 15) {
                        if habitsViewModel.isLoading && habitsViewModel.habits.isEmpty {
                            ProgressView()
                                .padding(.top, 50)
                        } else if habitsViewModel.habits.isEmpty {
                            Text("¡Añade tu primer hábito para empezar!")
                                .font(.headline)
                                .foregroundColor(Color.appTextSecondary)
                                .padding(.top, 50)
                        } else {
                            ForEach(habitsViewModel.habits) { habit in
                                HabitRowView(habit: habit)
                                    .onTapGesture {
                                        habitsViewModel.toggleCompletion(for: habit, authViewModel: authViewModel)
                                    }
                                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                        Button(role: .destructive) {
                                            habitsViewModel.deleteHabit(habit)
                                        } label: {
                                            Label("Eliminar", systemImage: "trash.fill")
                                        }
                                    }
                                    .transition(.asymmetric(insertion: .scale, removal: .opacity))
                            }
                        }
                    }
                    .padding()
                }
                .animation(.default, value: habitsViewModel.habits)
                .refreshable {
                    await habitsViewModel.loadHabits()
                }
            }
            .foregroundColor(Color.appTextPrimary)
        }
        // --- ELIMINADO ---
        // Se elimina la llamada en .onAppear para evitar la condición de carrera.
        // .onAppear {
        //     Task {
        //         await habitsViewModel.loadHabits()
        //     }
        // }
        .alert(item: $habitsViewModel.alertItem) { alertItem in
            Alert(title: alertItem.title, message: alertItem.message, dismissButton: alertItem.dismissButton)
        }
    }
    
    private func headerView(userName: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("Hola de nuevo,")
                .font(.callout)
                .foregroundStyle(Color.appTextSecondary)
            Text(userName)
                .font(.largeTitle)
                .fontWeight(.bold)
        }
        .padding(.vertical)
    }
}

#Preview {
//    struct PreviewWrapper: View {
//        private static let authViewModel: AuthViewModel = {
//            let vm = AuthViewModel()
//            vm.currentUser = User(id: "1", name: "Usuario de Preview", email: "preview@test.com")
//            return vm
//        }()
//        
//        private static let habitsViewModel: HabitsViewModel = {
//            let vm = HabitsViewModel()
//            vm.habits = [
//                Habit(id: "1", nombre: "Leer un Libro", tipo: .siNo, meta_objetivo: "15 minutos al día"),
//                Habit(id: "2", nombre: "Hacer Ejercicio", tipo: .siNo, meta_objetivo: "30 minutos de cardio")
//            ]
//            vm.completionStatus["1"] = true
//            return vm
//        }()
//
//        var body: some View {
//            HomeView()
//                .environmentObject(Self.authViewModel)
//                .environmentObject(Self.habitsViewModel)
//        }
//    }
//    
//    return PreviewWrapper()
}
