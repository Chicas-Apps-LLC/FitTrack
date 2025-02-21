//
//  UserDto.swift
//  FitTrack
//
//  Created by Joseph Chica on 1/1/25.
//

import Foundation

final class UserDto: ObservableObject {
    @Published var userId: Int
    @Published var name: String
    @Published var username: String?
    @Published var email: String?
    @Published var createdAt: String?
    @Published var profilePictureUrl: String?
    @Published var startingPicture: String?
    @Published var progressPicture: String?
    @Published var subscriptionId: Int?
    
    @Published var currentStats: CurrentStatsDto
    @Published var goals: GoalsDto
    
    // Initializer
    init(
        userId: Int,
        name: String,
        username: String? = nil,
        email: String? = nil,
        createdAt: String? = nil,
        profilePictureUrl: String? = nil,
        startingPicture: String? = nil,
        progressPicture: String? = nil,
        subscriptionId: Int? = nil,
        currentStats: CurrentStatsDto = CurrentStatsDto(),
        goals: GoalsDto = GoalsDto()
    ) {
        self.userId = userId
        self.name = name
        self.username = username
        self.email = email
        self.createdAt = createdAt
        self.profilePictureUrl = profilePictureUrl
        self.startingPicture = startingPicture
        self.progressPicture = progressPicture
        self.subscriptionId = subscriptionId
        self.currentStats = currentStats
        self.goals = goals
    }
}
