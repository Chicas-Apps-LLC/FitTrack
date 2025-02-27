//
//  ExerciseHistoryDto.swift
//  FitTrack
//
//  Created by Joseph Chica on 2/26/25.
//
import Foundation

struct ExerciseHistoryDto: Identifiable {
    var id: Int
    var exerciseId: Int
    var routineId: Int
    var date: Date
    var sets: [SetsDto]
    var notes: String?
}
