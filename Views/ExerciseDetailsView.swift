//
//  ExerciseDetailsView.swift
//  FitTrack
//
//  Created by Joseph Chica on 10/7/24.
//

import SwiftUI

struct ExerciseDetailsView: View {
    let exercise: ExerciseDto

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(exercise.name)
                .font(.title)
                .bold()
                .padding(.bottom)

            if let videoURL = exercise.videoURL, let url = URL(string: videoURL) {
                Text("Video description of exercise:")
                    .font(.headline)
                Link("Watch Video", destination: url)
                    .foregroundColor(.blue)
            } else {
                Text("No video available")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            if let instructions = exercise.instructions {
                Text("Steps to perform:")
                    .font(.headline)
                    .padding(.top)
                Text(instructions)
                    .padding(.leading)
            } else {
                Text("No instructions available")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }


            if let description = exercise.description {
                Text("Description:")
                    .font(.headline)
                    .padding(.top)
                Text(description)
                    .padding(.leading)
            } else {
                Text("No description available")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            Spacer()
        }
        .padding()
    }
}


struct ExerciseDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        ExerciseDetailsView(exercise: ExerciseDto(
            id: 1,
            name: "Mock Exercise",
            description: "A great exercise to strengthen your core.",
            level: "Intermediate",
            instructions: "1. Do this\n2. Do that\n3. Finish strong!",
            equipmentNeeded: nil,
            overloading: nil,
            powerStrengthSupplement: nil,
            isolationCompoundAccessory: nil,
            pushPullLegs: nil,
            verticalHorizontalRotational: nil,
            stretch: nil,
            videoURL: nil
        ))
    }
}
