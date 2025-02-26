//
//  RoutineSessionDto.swift
//  FitTrack
//
//  Created by Joseph Chica on 2/22/25.
//

import Foundation

final class RoutineSessionDto: ObservableObject {
    @Published var id: Int?
    @Published var routineId: Int?
    @Published var userId: Int?
    @Published var date: Date?
    @Published var duration: Double?
    @Published var difficulty: Int?
    @Published var caloritesBurnt: Int?
    @Published var notes: String?

    // Explicit initializer to allow instantiation with optional values
    init(id: Int? = nil, routineId: Int? = nil, userId: Int? = nil, date: Date? = nil,
         duration: Double? = nil, difficulty: Int? = nil, caloritesBurnt: Int? = nil, notes: String? = nil) {
        self.id = id
        self.routineId = routineId
        self.userId = userId
        self.date = date
        self.duration = duration
        self.difficulty = difficulty
        self.caloritesBurnt = caloritesBurnt
        self.notes = notes
    }
}
