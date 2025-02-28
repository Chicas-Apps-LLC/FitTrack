//
//  SetsDto.swift
//  FitTrack
//
//  Created by Joseph Chica on 2/6/25.
//
import Foundation

struct SetsDto: Identifiable {
    var id = UUID() // Unique identifier
    var setNumber: Int
    var reps: Int
    let weight: Double
}
