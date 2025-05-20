//
//  RoutineSelectorView.swift
//  FitTrack
//
//  Created by Joseph Chica on 12/16/24.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    @StateObject private var routineViewModel = RoutineViewModel()
    @State private var flippedStates: [Bool] = []
    @State private var scrollOffset: CGFloat = 0

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [AppColors.primary, AppColors.secondary]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 20) {
                    HStack {
                        NavigationLink(destination: CalendarView(routineViewModel: routineViewModel)) {
                            Image(systemName: "calendar")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .foregroundColor(AppColors.light)
                                .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
                        }
                        Spacer()
                        NavigationLink(
                            destination: UserProfileView(user: userViewModel.user ?? placeholderUser)
                        ) {
                            Image(systemName: "person.crop.circle")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .foregroundColor(AppColors.light)
                                .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
                        }
                        .padding()
                    }

                    Text("Select a Routine")
                        .font(.system(size: 28, weight: .bold))
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.light)
                        .padding(.top)

                    if routineViewModel.routines.isEmpty {
                        Text("No routines available")
                            .foregroundColor(AppColors.night)
                            .font(.headline)
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHStack(spacing: 20) {
                                ForEach(routineViewModel.routines, id: \.id) { routine in
                                    RoutineCardView(routine: routine, viewModel: routineViewModel)
                                        .frame(width: 200, height: 350)
                                        .background(Color.white)
                                        .cornerRadius(15)
                                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }

                    HStack(spacing: 10) {
                        // "Create Routine" Button
                        NavigationLink(destination: ExercisesListView()) {
                            Text("Create Routine")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 175, height: 59)
                                .background(AppColors.primary)
                                .cornerRadius(25)
                                .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
                        }
                        Button(action: {
                            routineViewModel.createAndSaveGeneratedRoutine(user: userViewModel.user!)
                        }) {
                            Text("Generate Routine")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 175, height: 59)
                                .background(AppColors.primary)
                                .cornerRadius(25)
                                .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
                        }
                    }
                }
                .padding(.horizontal)
                .onAppear {
                    routineViewModel.loadAllRoutines()
                    userViewModel.loadFirstUser() // Ensure user is loaded
                }
            }
        }
    }

    private var placeholderUser: UserDto {
        UserDto(userId: 0, name: "NO USER SELECTED", username: nil, email: nil, createdAt: nil, profilePictureUrl: nil, startingPicture: nil, progressPicture: nil, subscriptionId: nil)
    }
}


struct RoutineSelectorView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .environmentObject(mockUserViewModel)
            .environmentObject(mockRoutineViewModel)
    }
    
    static var mockUserViewModel: UserViewModel {
        let userViewModel = UserViewModel()
        let mockUser = UserDto(userId: 1, name: "John Doe", username: "johndoe", email: "johndoe@example.com", createdAt: "01/01/2025", profilePictureUrl: nil, startingPicture: nil, progressPicture: nil, subscriptionId: nil)
        userViewModel.user = mockUser
        return userViewModel
    }
    
    // Mock RoutineViewModel
    static var mockRoutineViewModel: RoutineViewModel {
        let routineViewModel = RoutineViewModel()
        routineViewModel.routines = [
            RoutineDto(id: 1, name: "Strength Routine", description: "Build muscle strength", isFavorite: false, exerciseWithSetsDto: []),
            RoutineDto(id: 2, name: "Weight Loss Routine", description: "Lose weight and tone up", isFavorite: false, exerciseWithSetsDto: []),
            RoutineDto(id: 3, name: "Cardio Routine", description: "Improve cardiovascular health", isFavorite: false, exerciseWithSetsDto: [])
        ]
        return routineViewModel
    }
}
