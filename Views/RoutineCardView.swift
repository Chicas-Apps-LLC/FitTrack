//
//  RoutineCardView.swift
//  FitTrack
//
//  Created by Joseph Chica on 12/26/24.
//

import SwiftUI

struct RoutineCardView: View {
    @ObservedObject var routine: RoutineDto
    @ObservedObject var viewModel: RoutineViewModel
    var isEditing: Bool

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

            Button(action: {
                viewModel.toggleFavorite(routine: routine)
            }) {
                Image(systemName: routine.isFavorite ? "star.fill" : "star")
                    .foregroundColor(AppColors.secondary)
                    .font(.title)
                    .padding(1)
            }
            .offset(x: -10, y: 10)
            
            if isEditing {
                Button(action: {
                    viewModel.deleteRoutine(routine: routine)
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                        .padding(10)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(radius: 3)
                }
                .offset(x: -10, y: 60)
            }
        }
    }
}

struct RoutineCardView_Previews: PreviewProvider {
    static var previews: some View {
        let exercises = [
            ExerciseWithSetsDto(exercise: ExerciseDto(id: 1, name: "Squat", description: "Barbell Squats"), sets: []),
            ExerciseWithSetsDto(exercise: ExerciseDto(id: 2, name: "Bench Press", description: "Flat Bench Press"), sets: []),
            ExerciseWithSetsDto(exercise: ExerciseDto(id: 3, name: "Deadlift", description: "Conventional Deadlift"), sets: []),
            ExerciseWithSetsDto(exercise: ExerciseDto(id: 4, name: "Pull Ups", description: "Bodyweight Pull Ups"), sets: [])
        ]
        
        let mockRoutine = RoutineDto(
            id: 101,
            name: "Full Body Strength",
            description: "A complete strength workout",
            isFavorite: true,
            exerciseWithSetsDto: exercises
        )
        
        let mockViewModel = RoutineViewModel()

        return NavigationView {
            RoutineCardView(routine: mockRoutine, viewModel: mockViewModel, isEditing: true)
                .padding()
                .previewLayout(.sizeThatFits)
        }
    }
}
