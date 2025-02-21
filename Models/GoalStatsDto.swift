//
//  GoalStatsDto.swift
//  FitTrack
//
//  Created by Joseph Chica on 1/11/25.
//

import Foundation

final class GoalsDto: ObservableObject {
    @Published var goalWeight: Double?
    @Published var goalGymDays: Int?
    @Published var goalExercise: String?
    @Published var goalBodyFat: Double?

    // Initializer
    init(
        goalWeight: Double? = nil,
        goalGymDays: Int? = nil,
        goalExercise: String? = nil,
        goalBodyFat: Double? = nil
    ) {
        self.goalWeight = goalWeight
        self.goalGymDays = goalGymDays
        self.goalExercise = goalExercise
        self.goalBodyFat = goalBodyFat
    }
}	
