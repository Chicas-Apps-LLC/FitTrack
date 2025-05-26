//
//  RoutineSelectorView.swift
//  FitTrack
//
//  Created by Joseph Chica on 12/16/24.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    @StateObject private var internalRoutineVM = RoutineViewModel()
    @State private var flippedStates: [Bool] = []
    @State private var scrollOffset: CGFloat = 0
    @State private var isEditing: Bool = false

    
    private var externalRoutineVM: RoutineViewModel?
    
    private var routineViewModel: RoutineViewModel {
        externalRoutineVM ?? internalRoutineVM
    }
    
    init(routineViewModel: RoutineViewModel? = nil) {
        self.externalRoutineVM = routineViewModel
    }
    
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

                    VStack(alignment: .leading) {
                        Text("Select a Routine")
                            .font(.system(size: 28, weight: .bold))
                            .fontWeight(.bold)
                            .foregroundColor(AppColors.light)
                            .frame(maxWidth: .infinity, alignment: .center) // center the title

                        HStack {
                            Spacer()
                            Button(action: {
                                isEditing.toggle()
                                // Optionally trigger edit mode behavior here
                            }) {
                                Text(isEditing ? "Done" : "Edit")
                                    .font(.system(size: 16, weight: .bold))
                                    .padding(.horizontal, 40)
                                    .padding(.vertical, 10)
                                    .background(AppColors.secondary)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                    .shadow(color: AppColors.night.opacity(0.2), radius: 4, x: 0, y: 2)
                            }
                        }
                    }
                    .padding(.top)

                    
                    if routineViewModel.routines.isEmpty {
                        Text("No routines available")
                            .foregroundColor(AppColors.night)
                            .font(.headline)
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHStack(spacing: 20) {
                                ForEach(Array(routineViewModel.routines.enumerated()), id: \.element.id) { index, _ in
                                    let routine = routineViewModel.routines[index]
                                    RoutineCardView(routine: routine, viewModel: routineViewModel, isEditing: isEditing)
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
                    userViewModel.loadFirstUser()
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
        MainView(routineViewModel: mockRoutineViewModel)
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
        let exercises = ExerciseWithSetsDto(
            exercise: ExerciseDto(
                id: 1,
                name: "Barbell Squat",
                description: "A compound lower-body exercise that targets the quads, hamstrings, and glutes.",
                level: "Intermediate",
                instructions: "Keep your back straight and squat to parallel.",
                equipmentNeeded: true,
                overloading: true,
                powerStrengthSupplement: "Strength",
                isolationCompoundAccessory: "Compound",
                pushPullLegs: "Legs",
                verticalHorizontalRotational: "Vertical",
                stretch: false,
                videoURL: "https://example.com/barbell-squat"
            ),
            sets: [
                SetsDto(setNumber: 1, reps: 8, weight: 100.0),
                SetsDto(setNumber: 2, reps: 8, weight: 105.0),
                SetsDto(setNumber: 3, reps: 6, weight: 110.0)
            ]
        )
        routineViewModel.routines = [
            RoutineDto(id: 1, name: "Strength Routine", description: "Build muscle strength", isFavorite: false, exerciseWithSetsDto: [exercises]),
            RoutineDto(id: 2, name: "Weight Loss Routine", description: "Lose weight and tone up", isFavorite: false, exerciseWithSetsDto: [exercises]),
            RoutineDto(id: 3, name: "Cardio Routine", description: "Improve cardiovascular health", isFavorite: false, exerciseWithSetsDto: [exercises])
        ]
        return routineViewModel
    }
}
