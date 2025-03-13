//
//  ExerciseHistoryView.swift
//  FitTrack
//
//  Created by Joseph Chica on 3/12/25.
//

import SwiftUI

struct ExerciseHistoryView: View {
    var exerciseSession: ExerciseHistoryDto
    var exerciseName: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Exercise Title
            Text("\(exerciseName) Session")
                .font(.title2)
                .bold()
                .padding(.bottom, 5)
            
            // Exercise Details
            VStack(alignment: .leading, spacing: 12) {
                infoRow(icon: "calendar", text: exerciseSession.date.formatted())
                infoRow(icon: "list.number", text: "Total Sets: \(exerciseSession.sets.count)")
            }
            .padding(.vertical, 8)
            
            // Sets Data
            VStack(alignment: .leading, spacing: 8) {
                Text("Sets Breakdown:")
                    .font(.headline)
                ForEach(exerciseSession.sets) { set in
                    HStack {
                        Text("Set \(set.setNumber): \(set.reps) reps at \(set.weight, specifier: "%.1f") kg")
                            .font(.body)
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal, 10)
                }
            }
            .padding(.top, 8)
            
            // Notes Section
            if let notes = exerciseSession.notes, !notes.isEmpty {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Notes:")
                        .font(.headline)
                    Text(notes)
                        .italic()
                        .foregroundColor(.gray)
                }
                .padding(.top, 8)
            }
        }
        .padding()
        .background(AppColors.light.opacity(0.2))
        .cornerRadius(12)
        .shadow(radius: 3)
        .padding()
    }
    
    // Helper View for Info Row
    private func infoRow(icon: String, text: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(AppColors.primary)
            Text(text)
        }
        .font(.body)
    }
}

#Preview {
    ExerciseHistoryView(
        exerciseSession: ExerciseHistoryDto(
            id: 1,
            exerciseId: 101,
            routineId: 1,
            routineHistoryId: 1,
            date: Date(),
            sets: [
                SetsDto(setNumber: 1, reps: 10, weight: 20.0),
                SetsDto(setNumber: 2, reps: 8, weight: 22.5),
                SetsDto(setNumber: 3, reps: 6, weight: 25.0)
            ],
            notes: "Felt strong today!"
        ),
        exerciseName: "Bench Press"
    )
}
