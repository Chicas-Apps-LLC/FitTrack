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
    
    @State private var routineViewModel = RoutineViewModel()
    @State private var exerciseViewModel = ExerciseViewModel()
    @State private var routineName: String = ""
    @State private var routineDescription: String = ""
    @State private var errorMessage: String?
    
    var selectedDate: Date? = nil

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
                        if (selectedDate != nil) {
                            
                        }
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
        var exercises: [ExerciseWithSetsDto] = []
        for exerciseName in selectedExercises {
            let exercise = exerciseViewModel.getExerciseDetailsByName(exerciseName: exerciseName)
            let ews = exerciseViewModel.createExerciseWithSetsFromExercise(exercise: exercise, sets: 3, reps: 8, weight: 0)
            exercises.append(ews)
        }
        

        let routine = RoutineDto(
            id: 0,
            name: routineName,
            description: routineDescription,
            exerciseWithSetsDto: exercises
        )

        // Save the routine to the database
        let success = routineViewModel.saveRoutine(routine: routine)
        if success {
            log(.info, "Successfully saved routine to database")
            dismiss()
        } else {
            errorMessage = "Failed to save routine to the database."
        }

    }
}

#Preview {
    StatefulPreviewWrapper(["Squat", "Barbell Row", "Incline Dumbbell Press", "E-Z Bar Bicep Curls"]) { binding in
        CreateRoutineView(selectedExercises: binding)
    }
}

struct StatefulPreviewWrapper<Value, Content: View>: View {
    @State var value: Value
    var content: (Binding<Value>) -> Content

    init(_ initialValue: Value, @ViewBuilder content: @escaping (Binding<Value>) -> Content) {
        self._value = State(initialValue: initialValue)
        self.content = content
    }

    var body: some View {
        content($value)
    }
}
