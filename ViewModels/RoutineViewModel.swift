//
//  RoutineViewModel.swift
//  FitTrack
//
//  Created by Joseph Chica on 12/16/24.
//

import Combine
import Foundation

final class RoutineViewModel: ObservableObject {
    @Published var routines: [RoutineDto] = []
    @Published var currentRoutine: RoutineDto?
    @Published var routineCreationSuccess: Bool = false
    @Published var isLoading = true
    
    private let dm = DatabaseManager.shared
    
    func createAndSaveGeneratedRoutine(user: UserDto) {
        let baseName = "Generated routine"
        var routineName = baseName
        var number = 1

        // Check for existing routines and increment the number until a unique name is found
        while dm.getRoutineByName(routineName) != nil {
           number += 1
           routineName = "\(baseName) \(number)"
        }
        
        let routine = dm.createGeneratedRoutine(name: routineName, user: user)
        let success = dm.saveRoutineWithExercisesToDb(routine)
        
        routineCreationSuccess = success
        
        if success {
            log(.info, "Routine created and saved successfully.")
            loadAllRoutines()
        } else {
            log(.error, "Failed to create or save routine.")
        }
    }
    
    func createAndSaveGeneratedRoutines(user: UserDto) {
        let routineNames = [
            "Generated Routine 1",
            "Generated Routine 2",
            "Generated Routine 3"
        ]
        
        let routines = [
            dm.createMainLiftOne(user: user),
            dm.createMainLiftTwo(user: user),
            dm.createMainLiftThree(user: user)
        ]
        
        for (index, routine) in routines.enumerated() {
            let routineName = routineNames[index]
            
            // Check if a routine with the same name already exists
            if let existingRoutine = dm.getRoutineByName(routineName) {
                log(.warning, "Routine with name '\(routineName)' already exists: \(existingRoutine)")
                continue
            }
            
            // Save routine
            let success = dm.saveRoutineWithExercisesToDb(routine)
            routineCreationSuccess = success
            
            if success {
                log(.info, "Routine '\(routineName)' created and saved successfully.")
            } else {
                log(.error, "Failed to create or save routine '\(routineName)'.")
            }
        }
        
        // Reload routines to reflect changes
        loadAllRoutines()
    }

    func loadAllRoutines() {
        DispatchQueue.global(qos: .background).async {
            let allRoutines = DatabaseManager.shared.fetchAllRoutines()
            let filteredRoutines = allRoutines.filter { !$0.name.isEmpty }
            log(.info, "Filtered routines count: \(filteredRoutines.count)")
            
            let routinesWithExercises = filteredRoutines.map { routine -> RoutineDto in
                var updatedRoutine = routine
                updatedRoutine.exerciseWithSetsDto = DatabaseManager.shared.getExercisesWithSetsFromRoutine(routineId: routine.id)
                return updatedRoutine
            }
            
            DispatchQueue.main.async {
                self.routines = routinesWithExercises
                self.isLoading = false
            }
        }
    }
    
    func deleteRoutine(routine: RoutineDto) {
        guard DatabaseManager.shared.deleteRoutine(routine: routine) else {
            log(.error, "Error deleting \(routine.name)")
            return
        }

        log(.info, "\(routine.name) deleted successfully.")
        loadAllRoutines()
    }
    
    func getRoutineHistory(routineId: Int) -> [RoutineHistoryDto] {
        DatabaseManager.shared.getRoutineHistory(routineId: routineId)
    }
    
    func createSetsRepsAndWeight(exercise: ExerciseDto, level: String, goal: String) -> ExerciseWithSetsDto {
        let repRanges: [String: [String: ClosedRange<Int>]] = [
            "Beginner": [
                "Strength": 4...6,
                "Weight Loss": 8...12,
                "Cardio": 12...20
            ],
            "Intermediate": [
                "Strength": 3...5,
                "Weight Loss": 6...10,
                "Cardio": 15...20
            ],
            "Advanced": [
                "Strength": 2...4,
                "Weight Loss": 6...10,
                "Cardio": 15...20
            ]
        ]
        
        let setRanges: [String: [String: ClosedRange<Int>]] = [
            "Beginner": [
                "Strength": 2...3,
                "Weight Loss": 1...3,
                "Cardio": 2...3
            ],
            "Intermediate": [
                "Strength": 3...4,
                "Weight Loss": 2...4,
                "Cardio": 3...4
            ],
            "Advanced": [
                "Strength": 4...5,
                "Weight Loss": 2...4,
                "Cardio": 3...5
            ]
        ]
        
        let weightPercents: [String: [String: ClosedRange<Double>]] = [
            "Beginner": [
                "Strength": 60.0...70.0,
                "Weight Loss": 50.0...60.0,
                "Cardio": 35.0...45.0
            ],
            "Intermediate": [
                "Strength": 70.0...80.0,
                "Weight Loss": 60.0...70.0,
                "Cardio": 45.0...55.0
            ],
            "Advanced": [
                "Strength": 80.0...95.0,
                "Weight Loss": 65.0...75.0,
                "Cardio": 55.0...65.0
            ]
        ]
        
        guard let repRange = repRanges[level]?[goal],
              let setRange = setRanges[level]?[goal],
              let weightRange = weightPercents[level]?[goal] else {
            fatalError("Invalid level or goal")
        }
        
        let numSets = Int.random(in: setRange)
        var sets: [SetsDto] = []
        
        for i in 1...numSets {
            let reps = Int.random(in: repRange)
            let weight = Double.random(in: weightRange)
            
            sets.append(SetsDto(setNumber: i, reps: reps, weight: weight))
        }
        
        return ExerciseWithSetsDto(exercise: exercise, sets: sets)
    }
}
