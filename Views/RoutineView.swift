//
//  RoutineView.swift
//  FitTrack
//
//  Created by Joseph Chica on 9/26/24.
//

import SwiftUI

struct RoutineView: View {
    var routine: RoutineDto

    @ObservedObject var viewModel: RoutineViewModel
    @State private var pastSessions: [RoutineHistoryDto] = []
    @State private var isStarted = false
    @State private var elapsedTime = 0
    @State private var timer: Timer? = nil
    @State private var isProgressExpanded = false

    var body: some View {
        ZStack(alignment: .bottom){
            AppColors.light.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    // Routine Name
                    routineName
                    
                    // stopwatch
                    if isStarted{
                        stopwatchView
                    }
                    
                    // Exercises List
                    exercisesList
                    
                    Spacer()
                    
                    // Progress Section (Past Sessions)
                    progressHistorySection
                    
                    Spacer()
                }
                .padding()
                .navigationTitle("Workout Routine")
                .onAppear {
                    loadRoutineHistory()
                }
            }
            startFinishButton
                .padding(.bottom, 20)
                .shadow(radius: 5)
        }
    }

    // MARK: - Subviews

    private var routineName: some View {
        Text(routine.name)
            .font(.system(size: 28, weight: .bold, design: .rounded))
            .padding(.top, 20)
    }
    
    private var stopwatchView: some View {
        Text("Time: \(formattedTime(elapsedTime))")
            .font(.headline)
            .foregroundColor(.black)
            .frame(maxWidth: .infinity, alignment: .center)
    }

    private var exercisesList: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Exercises:")
                .font(.title2)
                .padding(.top, 10)
                .frame(maxWidth: .infinity, alignment: .center)

            if let exercisesWithSets = routine.exerciseWithSetsDto, !exercisesWithSets.isEmpty {
                ForEach(exercisesWithSets, id: \.exercise.id) { exerciseWithSets in
                    NavigationLink(destination: ExerciseView(routine: routine)) {
                        HStack {
                            Text(exerciseWithSets.exercise.name)
                                .font(.body)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .center)
                                .background(Color.white)
                                .cornerRadius(10)
                                .shadow(radius: 2)
                                .foregroundColor(.black)
                            Spacer()
                        }
                    }
                }
            } else {
                Text("No exercises available")
                    .foregroundColor(.gray)
                    .italic()
            }
        }
        .padding(.horizontal)
    }
    
    private var startFinishButton: some View {
        Button(action: toggleRoutine) {
            Text(isStarted ? "Finish" : "Start")
                .font(.system(size: 18, weight: .bold))
                .frame(maxWidth: .infinity)
                .padding(15)
                .background(AppColors.primary)
                .foregroundColor(.white)
                .cornerRadius(12)
                .padding(.horizontal)
        }
        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
    }
    
    private var progressHistorySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Button(action: {
                withAnimation {
                    isProgressExpanded.toggle()
                }
            }) {
                HStack {
                    Text("Routine Progress")
                        .font(.title2)
                        .frame(maxWidth: .infinity, alignment: .center)
                    Text(isProgressExpanded ? "▲" : "▼") // Toggle arrow icon
                        .font(.title2)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(radius: 2)
            }

            if isProgressExpanded { // Only show when expanded
                ExpandedProgressHistoryView(pastSessions: pastSessions)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 3)
        .padding(.horizontal)
    }

    // MARK: - Helpers
    private func loadRoutineHistory() {
        pastSessions = viewModel.getRoutineHistory(routineId: routine.id)
    }
    
    private func mockLoadRoutineHistory() {
        self.pastSessions = [
            RoutineHistoryDto(id: 1, routineId: routine.id, userId: 1, date: Date().addingTimeInterval(-86400),
                              duration: 5200, difficulty: 3, caloriesBurnt: 350, notes: "Felt strong today"),
            RoutineHistoryDto(id: 2, routineId: routine.id, userId: 1, date: Date().addingTimeInterval(-172800),
                              duration: 3400, difficulty: 4, caloriesBurnt: 400, notes: "Increased weights")
        ]
    }


    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    private func formattedTime(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let sec = seconds % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, sec)
    }

    
    private func toggleRoutine() {
        if isStarted {
            // Stop the stopwatch
            timer?.invalidate()
            timer = nil
        } else {
            // Start the stopwatch
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                elapsedTime += 1
            }
        }
        isStarted.toggle()
    }
}

struct ExpandedProgressHistoryView: View {
    var pastSessions: [RoutineHistoryDto]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if pastSessions.isEmpty {
                Text("No past sessions yet.")
                    .foregroundColor(.gray)
                    .italic()
                    .frame(maxWidth: .infinity, alignment: .center)
            } else {
                ForEach(pastSessions) { session in
                    VStack(alignment: .leading) {
                        Text("Workout on \(session.date?.formatted() ?? "No date")")
                            .font(.headline)
                        Text("Duration: \(formattedTime(Int(session.duration ?? 0)))")
                    }
                    
                }
            }
        }
        .padding(.top, 5)
    }

    private func formattedTime(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let sec = seconds % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, sec)
    }
}

#Preview {
    RoutineView(routine: RoutineDto(
        id: 1,
        name: "Leg Routine",
        description: "A mix of upper and lower body exercises.",
        exerciseWithSetsDto: [
            ExerciseWithSetsDto(
                exercise: ExerciseDto(
                    id: 101,
                    name: "Leg curls",
                    description: "A lower body strength exercise.",
                    level: "Intermediate",
                    instructions: "Stand with feet shoulder-width apart, lower hips down and back, then return to standing.",
                    equipmentNeeded: true,
                    overloading: true,
                    powerStrengthSupplement: "Strength",
                    isolationCompoundAccessory: "Compound",
                    pushPullLegs: "Legs",
                    verticalHorizontalRotational: "Vertical",
                    stretch: false,
                    videoURL: nil
                ),
                sets: [
                    SetsDto(setNumber: 1, reps: 10, weight: 50),
                    SetsDto(setNumber: 2, reps: 8, weight: 55),
                    SetsDto(setNumber: 3, reps: 6, weight: 60)
                ]
            ),
            ExerciseWithSetsDto(
                exercise: ExerciseDto(
                    id: 102,
                    name: "Squats",
                    description: "A lower body strength exercise.",
                    level: "Intermediate",
                    instructions: "Stand with feet shoulder-width apart, lower hips down and back, then return to standing.",
                    equipmentNeeded: true,
                    overloading: true,
                    powerStrengthSupplement: "Strength",
                    isolationCompoundAccessory: "Compound",
                    pushPullLegs: "Legs",
                    verticalHorizontalRotational: "Vertical",
                    stretch: false,
                    videoURL: nil
                ),
                sets: [
                    SetsDto(setNumber: 1, reps: 10, weight: 50),
                    SetsDto(setNumber: 2, reps: 8, weight: 55),
                    SetsDto(setNumber: 3, reps: 6, weight: 60)
                ]
            ),
            ExerciseWithSetsDto(
                exercise: ExerciseDto(
                    id: 103,
                    name: "Bulgarian split squats",
                    description: "A lower body strength exercise.",
                    level: "Intermediate",
                    instructions: "Stand with feet shoulder-width apart, lower hips down and back, then return to standing.",
                    equipmentNeeded: true,
                    overloading: true,
                    powerStrengthSupplement: "Strength",
                    isolationCompoundAccessory: "Compound",
                    pushPullLegs: "Legs",
                    verticalHorizontalRotational: "Vertical",
                    stretch: false,
                    videoURL: nil
                ),
                sets: [
                    SetsDto(setNumber: 1, reps: 10, weight: 50),
                    SetsDto(setNumber: 2, reps: 8, weight: 55),
                    SetsDto(setNumber: 3, reps: 6, weight: 60)
                ]
            ),
            ExerciseWithSetsDto(
                exercise: ExerciseDto(
                    id: 104,
                    name: "Romanian Deadlifts",
                    description: "A lower body strength exercise.",
                    level: "Intermediate",
                    instructions: "Stand with feet shoulder-width apart, lower hips down and back, then return to standing.",
                    equipmentNeeded: true,
                    overloading: true,
                    powerStrengthSupplement: "Strength",
                    isolationCompoundAccessory: "Compound",
                    pushPullLegs: "Legs",
                    verticalHorizontalRotational: "Vertical",
                    stretch: false,
                    videoURL: nil
                ),
                sets: [
                    SetsDto(setNumber: 1, reps: 10, weight: 50),
                    SetsDto(setNumber: 2, reps: 8, weight: 55),
                    SetsDto(setNumber: 3, reps: 6, weight: 60)
                ]
            ),
            ExerciseWithSetsDto(
                exercise: ExerciseDto(
                    id: 105,
                    name: "Leg Extensions",
                    description: "A lower body strength exercise.",
                    level: "Intermediate",
                    instructions: "Stand with feet shoulder-width apart, lower hips down and back, then return to standing.",
                    equipmentNeeded: true,
                    overloading: true,
                    powerStrengthSupplement: "Strength",
                    isolationCompoundAccessory: "Compound",
                    pushPullLegs: "Legs",
                    verticalHorizontalRotational: "Vertical",
                    stretch: false,
                    videoURL: nil
                ),
                sets: [
                    SetsDto(setNumber: 1, reps: 10, weight: 50),
                    SetsDto(setNumber: 2, reps: 8, weight: 55),
                    SetsDto(setNumber: 3, reps: 6, weight: 60)
                ]
            )
        ]
    ), viewModel: RoutineViewModel())
}


