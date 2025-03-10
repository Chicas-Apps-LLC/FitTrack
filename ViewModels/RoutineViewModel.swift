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
        guard dm.deleteRoutine(routine: routine) else {
            log(.error, "Error deleting \(routine.name)")
            return
        }

        log(.info, "\(routine.name) deleted successfully.")
        loadAllRoutines()
    }
    
    func getRoutineHistory(routineId: Int) -> [RoutineHistoryDto] {
        return dm.getRoutineHistory(routineId: routineId)
    }
    
    func getRoutineHistoryFromDb(routineId: Int) -> [RoutineHistoryDto] {
        return dm.getRoutineHistory(routineId: routineId)
    }
    
    func getRoutinesForDay(day: Int) -> [RoutineDto] {
        let routineIds = dm.getRoutinesForDay(day: day)
        
        var routines: [RoutineDto] = []
        
        for id in routineIds {
            if let routine = dm.getRoutineById(id: id) {
                routines.append(routine)
            }
        }
        return routines
    }
}
