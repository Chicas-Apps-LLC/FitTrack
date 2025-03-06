//
//  RoutineCardView.swift
//  FitTrack
//
//  Created by Joseph Chica on 12/26/24.
//

import SwiftUI

struct RoutineCardView: View {
    var routine: RoutineDto
    @ObservedObject var viewModel: RoutineViewModel

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(routine.name)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.night)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                    Spacer()
                }
                .padding(.trailing, 40)

                ForEach(routine.exerciseWithSetsDto?.prefix(3) ?? [], id: \ .exercise.id) { exerciseWithSets in
                    Text(exerciseWithSets.exercise.name)
                        .font(.subheadline)
                        .foregroundColor(AppColors.night.opacity(0.9))
                }

                if let exercises = routine.exerciseWithSetsDto, exercises.count > 3 {
                    Text("and \(exercises.count - 3) more")
                        .font(.footnote)
                        .foregroundColor(AppColors.night)
                }

                Spacer()

                NavigationLink(destination: RoutineView(routine: routine, viewModel: viewModel)) {
                    Text("Start \(routine.name)")
                        .fontWeight(.semibold)
                        .foregroundColor(AppColors.light)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(AppColors.primary)
                        .cornerRadius(8)
                }
            }
            .padding()
            .background(
                ZStack {
                    // Gradient Background
                    LinearGradient(
                        gradient: Gradient(colors: [AppColors.primary.opacity(0.1), AppColors.secondary.opacity(0.5)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(AppColors.primary, lineWidth: 2)
                }
            )
            .cornerRadius(15)
            .shadow(color: .gray.opacity(0.1), radius: 5, x: 0, y: 2)

            // Red X button
            Button(action: {
                viewModel.deleteRoutine(routine: routine)
            }) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(AppColors.red)
                    .font(.title)
                    .padding(10)
            }
            .offset(x: -10, y: 10) // Ensures consistent positioning
        }
    }
}
