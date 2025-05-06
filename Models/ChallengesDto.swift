//
//  ChallengesDto.swift
//  FitTrack
//
//  Created by Joseph Chica on 5/5/25.
//

import Foundation

struct ChallengesDto: Identifiable {
    var id: Int
    var name: String
    var description: String
    var type: String
    var points: Int
    var level: Int
}
