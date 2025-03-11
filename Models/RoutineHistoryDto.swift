//
//  RoutineSessionDto.swift
//  FitTrack
//
//  Created by Joseph Chica on 2/22/25.
//

import Foundation

import Foundation

struct RoutineHistoryDto: Identifiable {
    var id: Int?
    var routineId: Int?
    var userId: Int?
    var date: Date?
    var duration: Double?
    var difficulty: Int?
    var caloriesBurnt: Int?
    var notes: String?

    var wrappedId: Int {
        id ?? UUID().hashValue // Fallback for when id is nil
    }
}
