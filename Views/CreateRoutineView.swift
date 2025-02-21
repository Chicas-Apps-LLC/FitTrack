//
//  CreateRoutineView.swift
//  FitTrack
//
//  Created by Joseph Chica on 12/24/24.
//

import SwiftUI

struct CreateRoutineView: View {
    @Binding var selectedExercises: [String]
    @Environment(\.dismiss) var dismiss

    @State private var routineName: String = ""
    @State private var routineDescription: String = ""
    @State private var errorMessage: String?

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Routine Name")) {
                    TextField("Enter routine name", text: $routineName)
                    TextField("Enter routine description", text: $routineDescription)
                }

                Section(header: Text("Selected Exercises")) {
                    List {
                        ForEach(selectedExercises, id: \.self) { exercise in
                            Text(exercise)
                        }
                    }
                }

                if let errorMessage = errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }
                }

                Section {
                    Button("Create Routine") {
                        createRoutine()
                    }
                }
            }
            .navigationTitle("Create Routine")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func createRoutine() {
        guard !routineName.isEmpty else {
            errorMessage = "Routine name cannot be empty."
            return
        }

        // Fetch exercise details
        var exercises: [ExerciseDto] = []
        do {
            for exerciseName in selectedExercises {
                let exercise = try DatabaseManager.shared.getExerciseDetailsByName(forName: exerciseName)
                exercises.append(exercise)
            }

            // Create a RoutineDto
            let routine = RoutineDto(
                id: 0, // ID will be auto-incremented
                name: routineName,
                description: routineDescription,
                exerciseWithSetsDto: nil
            )

            // Save the routine to the database
            let success = DatabaseManager.shared.saveRoutineWithExercisesToDb(routine)
            if success {
                print("Fetching all routines...")
                //DatabaseManager.shared.fetchAllRoutines()
                dismiss() // Close the view
            } else {
                errorMessage = "Failed to save routine to the database."
            }
        } catch {
            errorMessage = "Error fetching exercise details: \(error.localizedDescription)"
        }
    }
}


//#Preview {
//    CreateRoutineView()
//}
