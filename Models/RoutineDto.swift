//
//  RoutineDto.swift
//  FitTrack
//
//  Created by Joseph Chica on 12/3/24.
//
import Foundation

final class RoutineDto: Identifiable, ObservableObject {
    var id: Int
    var name: String
    var description: String?
    @Published var isFavorite: Bool
    var exerciseWithSetsDto: [ExerciseWithSetsDto]?
    
    init(id: Int, name: String, description: String? = nil, isFavorite: Bool, exerciseWithSetsDto: [ExerciseWithSetsDto]? = nil) {
        self.id = id
        self.name = name
        self.description = description
        self.isFavorite = isFavorite
        self.exerciseWithSetsDto = exerciseWithSetsDto
    }
}
