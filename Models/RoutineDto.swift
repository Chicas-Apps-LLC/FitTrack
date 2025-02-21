//
//  RoutineDto.swift
//  FitTrack
//
//  Created by Joseph Chica on 12/3/24.
//
import Foundation

struct RoutineDto: Identifiable {
    var id: Int
    var name: String
    var description: String?
    var exerciseWithSetsDto: [ExerciseWithSetsDto]?
}
