//
//  RoutineScrollView.swift
//  FitTrack
//
//  Created by Joseph Chica on 12/16/24.
//

//older one
import SwiftUI

struct RoutineScrollView: View {
    let routines: [String]
    @Binding var flippedStates: [Bool]
    let exercises: [ExerciseDto]
    let showExercises: (String) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 20) {
                ForEach(routines.indices, id: \.self) { index in
                    ZStack {
                        if flippedStates[index] {
                            VStack {
                                Text("Exercises")
                                    .font(.headline)
                                ForEach(exercises.prefix(3), id: \.id) { exercise in
                                    Text(exercise.name)
                                        .font(.subheadline)
                                }
                            }
                        } else {
                            Text(routines[index])
                                .font(.title3)
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(width: 200, height: 300)
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 3)
                    .onTapGesture {
                        handleCardTap(for: index)
                    }
                }
            }
        }
    }
    
    private func handleCardTap(for index: Int) {
        withAnimation(.spring()) {
            flippedStates = flippedStates.enumerated().map { idx, _ in idx == index }
            showExercises(routines[index])
        }
    }
}

