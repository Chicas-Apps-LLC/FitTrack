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
}
