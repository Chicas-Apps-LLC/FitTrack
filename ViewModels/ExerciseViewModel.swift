//
//  ExerciseViewModel.swift
//  FitTrack
//
//  Created by Joseph Chica on 12/16/24.
//

import Foundation

final class ExerciseViewModel: ObservableObject {
    @Published var exercises: [ExerciseWithSetsDto] = []
    
    private let dm = DatabaseManager.shared
    
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
    
    func createExerciseWithSetsFromExercise(exercise: ExerciseDto, sets: Int, reps: Int, weight: Double) -> ExerciseWithSetsDto {
        let setsArray = (1...sets).map { setNumber in
            SetsDto(setNumber: setNumber, reps: reps, weight: weight)
        }
        return ExerciseWithSetsDto(exercise: exercise, sets: setsArray)
    }
    
//    func saveExercisesWithSets(exercises: [ExerciseWithSetsDto], routineId: Int) -> Bool{
//        let success = dm.saveExercisesWithSetsToDb(exercisesWithSets: exercises, routineId: routineId)
//        if (success) {
//            log(.info, "Saved exercies to routine \(routineId)")
//            return true
//        }
//        else {
//            log(.error, "unable to save exercises, check logs for further information")
//        }
//            return false
//    }
    
    func getExerciseHistory(exerciseId: Int) -> [ExerciseHistoryDto] {
        return dm.getExerciseHistory(exerciseId: exerciseId)
    }
    
    func getExerciseDetailsByName(exerciseName: String) -> ExerciseDto{
        return dm.getExerciseDetailsByName(forName: exerciseName)
    }
}
