//
//  ExercisesDto.swift
//  FitTrack
//
//  Created by Joseph Chica on 11/23/24.
//

import Foundation

struct ExerciseDto: Identifiable {
    let id: Int
    let name: String
    let description: String?
    let level: String?
    let instructions: String?
    let equipmentNeeded: Bool?
    let overloading: Bool?
    let powerStrengthSupplement: String?
    let isolationCompoundAccessory: String?
    let pushPullLegs: String?
    let verticalHorizontalRotational: String?
    let stretch: Bool?
    let videoURL: String?
}

