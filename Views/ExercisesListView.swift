//
//  ExercisesListView.swift
//  FitTrack
//
//  Created by Joseph Chica on 11/23/24.
//

import SwiftUI

struct ExercisesListView: View {
    @State private var exercises: [String] = []         // All exercises
    @State private var searchQuery: String = ""         // Search query
    @State private var filteredExercises: [String] = []  // Filtered exercises based on search
    @State private var selectedExercises: [String] = [] // Selected exercises for the new routine
    @State private var showCreateRoutineView = false
    var selectedDate: Date? = nil

    var body: some View {
        NavigationView {
            ZStack {
                // Main Content
                VStack(spacing: 0) {
                    // Search bar
                    TextField("Search exercises...", text: $searchQuery)
                        .padding(10)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .padding(.horizontal)
                        .onChange(of: searchQuery) { _ in
                            filterExercises()
                        }

                    // Exercise list
                    ScrollView {
                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(getGroupedExercises(), id: \.key) { section in
                                // Section header
                                Text(section.key)
                                    .font(.largeTitle)
                                    .bold()
                                    .padding(.vertical, 5)

                                // Exercises in the section
                                ForEach(section.value, id: \.self) { exerciseName in
                                    Button(action: {
                                        toggleSelection(exerciseName)
                                    }) {
                                        HStack {
                                            Circle()
                                                .fill(selectedExercises.contains(exerciseName) ? AppColors.primary : AppColors.gray)
                                                .frame(width: 20, height: 20)
                                            Text(exerciseName)
                                                .font(.body)
                                        }
                                    }
                                    .padding(.leading, 20)
                                }
                            }
                        }
                        .padding(.top)
                    }
                }

                // Floating "Create Routine" Button
                if !selectedExercises.isEmpty {
                    VStack {
                        Spacer()
                        Button(action: {
                            showCreateRoutineView = true
                        }) {
                            Text("Create Routine")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .cornerRadius(25)
                                .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
                        }
                        .padding(.horizontal, 50)
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationTitle("Exercises")
            .toolbar {
                // Exit Button
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: MainView()) {
                        Text("Exit")
                            .foregroundColor(AppColors.night)
                    }
                }
            }
            .sheet(isPresented: $showCreateRoutineView) {
                if !showCreateRoutineView {
                    CreateRoutineView(selectedExercises: $selectedExercises)
                }
                
            }
            .onAppear {
                loadExercises()
                filterExercises()
            }
        }
    }

    private func toggleSelection(_ exerciseName: String) {
        if selectedExercises.contains(exerciseName) {
            selectedExercises.removeAll(where: { $0 == exerciseName })
        } else {
            selectedExercises.append(exerciseName)
        }
    }

    private func makeDestination(for exerciseName: String) -> some View {
        print("Navigating to details for exercise: \(exerciseName)")
        do {
            let exercise = try getExerciseDto(forName: exerciseName)
            return AnyView(ExerciseDetailsView(exercise: exercise))
        } catch {
            print("Failed to fetch exercise: \(error.localizedDescription)")
            return AnyView(Text("Failed to load exercise: \(error.localizedDescription)"))
        }
    }

    private func loadExercises() {
        let routineManager = DatabaseManager()
        exercises = routineManager.getAllExercisesNames().filter { !$0.isEmpty } // Filter out empty names
    }

    private func filterExercises() {
        // Filter exercises based on the search query
        if searchQuery.isEmpty {
            filteredExercises = exercises
        } else {
            filteredExercises = exercises.filter { $0.localizedCaseInsensitiveContains(searchQuery) }
        }
    }

    private func getGroupedExercises() -> [(key: String, value: [String])] {
        // Group filtered exercises by their first letter (excluding empty strings)
        let grouped = Dictionary(grouping: filteredExercises.filter { !$0.isEmpty }.sorted()) { String($0.prefix(1)) }
        return grouped.sorted { $0.key < $1.key }
    }

    private func getExerciseDto(forName name: String) throws -> ExerciseDto {
        let routineManager = DatabaseManager()
        do {
            return try routineManager.getExerciseDetailsByName(forName: name)
        } catch {
            print("Error fetching exercise for \(name): \(error.localizedDescription)")
            return ExerciseDto(
                id: -1,
                name: "Default Exercise",
                description: "No description available",
                level: nil,
                instructions: nil,
                equipmentNeeded: nil,
                overloading: nil,
                powerStrengthSupplement: nil,
                isolationCompoundAccessory: nil,
                pushPullLegs: nil,
                verticalHorizontalRotational: nil,
                stretch: nil,
                videoURL: nil
            )
        }
    }
}



#Preview {
    ExercisesListView()
}
