//
//  CardView.swift
//  FitTrack
//
//  Created by Joseph Chica on 12/16/24.
//

//older one
import SwiftUI

struct CardView: View {
    let routine: String
    var isFlipped: Bool
    let exercises: [ExerciseDto]
    
    let primaryColor = Color(hex: "#19d4be")
    
    var body: some View {
        ZStack {
            // Front side: Routine name
            VStack {
                Text(routine)
                    .font(.headline)
                    .foregroundColor(.black)
                    .padding()
            }
            .frame(width: 300, height: UIScreen.main.bounds.height * 0.4) // 40% of screen height
            .background(Color.white)
            .cornerRadius(15)
            .shadow(radius: 5)

            // Back side: Exercises list
            if isFlipped {
                VStack(spacing: 10) {
                    Text("Exercises for \(routine)")
                        .font(.headline)
                        .foregroundColor(.blue)
                        //.padding()
                    
                    // Display up to 3 exercises and a "more" line if needed
                    ForEach(exercises.prefix(3)) { exercise in
                        Text(exercise.name)
                            .padding(5)
                            .background(Color.white)
                            .cornerRadius(8)
                            .shadow(radius: 1)
                    }
                    
                    if exercises.count > 3 {
                        Text("and \(exercises.count - 3) more ...")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    // "Start Routine" Button
                    Button(action: {
                        // Add functionality for starting the routine
                        print("Start routine: \(routine)")
                    }) {
//                        NavigationLink(destination: RoutineView(routineName: "Routine1", exercises: ["Push-ups", "Pull-ups", "Squats"])) {
//                            Text("Start Routine")
//                                .font(.system(size: 18, weight: .bold)) // Bold text
//                                .frame(maxWidth: .infinity) // Stretch button horizontally
//                                .padding(20) // Padding around the button
//                                .background(primaryColor) // Background color
//                                .foregroundColor(.white) // Text color
//                                .cornerRadius(12) // Rounded corners
//                                .padding(.horizontal) // Horizontal padding
//                        }
                        
                    }
                }
                .frame(width: 300, height: UIScreen.main.bounds.height * 0.4)
                .background(Color.white)
                .cornerRadius(15)
                .shadow(radius: 5)
                .rotation3DEffect(
                    Angle(degrees: 180),
                    axis: (x: 0, y: 1, z: 0)
                )
            }
        }
    }
}
