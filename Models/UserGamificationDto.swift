//
//  GamificationDto.swift
//  FitTrack
//
//  Created by Joseph Chica on 4/29/25.
//
import Foundation

struct UserGamificationDto: Identifiable {
    var id: Int
    var userId: Int
    var challengeId: Int
    var isCompleted: Bool
    var dateCompleted: Date?
}
