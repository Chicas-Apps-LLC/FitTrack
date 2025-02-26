//
//  RoutineView.swift
//  FitTrack
//
//  Created by Joseph Chica on 9/26/24.
//

import SwiftUI

struct RoutineView: View {
    var routine: RoutineDto

    @State private var isStarted = false
    @State private var elapsedTime = 0
    @State private var timer: Timer? = nil

    let primaryColor = Color(hex: "#19d4be")
    let backgroundColor = Color(hex: "#F5F5F5")

    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()

            VStack(spacing: 20) {
                // Routine Name
                routineName

                // Stopwatch
                stopwatchView

                // Exercises List
                exercisesList

                Spacer()
                
                // Start/Finish Button
                startFinishButton
            }
            .padding()
            .navigationTitle("Workout Routine")
        }
    }

    // MARK: - Subviews

    private var routineName: some View {
        Text(routine.name)
            .font(.system(size: 28, weight: .bold, design: .rounded))
            .padding(.top, 20)
    }

    private var stopwatchView: some View {
        Text("Time: \(formattedTime)")
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
                ForEach(exercisesWithSets, id: \ .exercise.id) { exerciseWithSets in
                    NavigationLink(destination: ExerciseView(routine: routine)) {
                        HStack {
                            Text(exerciseWithSets.exercise.name)
                                .font(.body)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .center) // Stretch button width
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
                .background(primaryColor)
                .foregroundColor(.white)
                .cornerRadius(12)
                .padding(.horizontal)
        }
        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
    }

    // MARK: - Helpers

    private var formattedTime: String {
        let minutes = elapsedTime / 60
        let seconds = elapsedTime % 60
        let hours = elapsedTime / 3600
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
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

struct RoutineProgressView: View {
    var body: some View {
        Text("Progress with this routine:")
    }
}

#Preview {
    RoutineView(routine: RoutineDto(
        id: 1,
        name: "Full Body Routine",
        description: "A mix of upper and lower body exercises.",
        exerciseWithSetsDto: [
            ExerciseWithSetsDto(
                exercise: ExerciseDto(
                    id: 101,
                    name: "Squat",
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
                    name: "Bench Press",
                    description: "A chest-focused strength exercise.",
                    level: "Intermediate",
                    instructions: "Lie on a bench, lower the barbell to chest, and push it back up.",
                    equipmentNeeded: true,
                    overloading: true,
                    powerStrengthSupplement: "Strength",
                    isolationCompoundAccessory: "Compound",
                    pushPullLegs: "Push",
                    verticalHorizontalRotational: "Horizontal",
                    stretch: false,
                    videoURL: nil
                ),
                sets: [
                    SetsDto(setNumber: 1, reps: 10, weight: 40),
                    SetsDto(setNumber: 2, reps: 8, weight: 45),
                    SetsDto(setNumber: 3, reps: 6, weight: 50)
                ]
            )
        ]
    ))
}


