//
//  CurrentStatsDto.swift
//  FitTrack
//
//  Created by Joseph Chica on 1/11/25.
//
import Foundation

final class CurrentStatsDto: ObservableObject {
    @Published var age: Int?
    @Published var height: Double?
    @Published var currentWeight: Double?
    @Published var bodyFat: Double?
    @Published var fitnessLevel: String?
    @Published var gymMembership: Bool?

    // Initializer
    init(
        age: Int? = nil,
        height: Double? = nil,
        currentWeight: Double? = nil,
        bodyFat: Double? = nil,
        fitnessLevel: String? = nil,
        gymMembership: Bool? = nil
    ) {
        self.age = age
        self.height = height
        self.currentWeight = currentWeight
        self.bodyFat = bodyFat
        self.fitnessLevel = fitnessLevel
        self.gymMembership = gymMembership
    }
}
