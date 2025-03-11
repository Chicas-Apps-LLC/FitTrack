//
//  RoutineHistoryView.swift
//  FitTrack
//
//  Created by Joseph Chica on 3/10/25.
//

import SwiftUI

struct RoutineHistoryView: View {
    var session: RoutineHistoryDto
    var routineName: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 75) {
            Text("\(routineName) \nSession")
                .font(.largeTitle)
                .bold()

            Text("Date: \(session.date?.formatted() ?? "No date")")
                .font(.headline)

            Text("Duration: \(formattedTime(Int(session.duration ?? 0)))")
            
            Text("Difficulty: \(session.difficulty ?? 0)")
            
            Text("Calories Burnt: \(session.caloriesBurnt ?? 0)")
            
            if let notes = session.notes, !notes.isEmpty {
                Text("Notes: \(notes)")
                    .italic()
            }
        }
        .padding()
        .background(AppColors.gray)
        .cornerRadius(12)
        .shadow(radius: 3)
    }
    private func formattedTime(_ seconds: Int) -> String {
           let hours = seconds / 3600
           let minutes = (seconds % 3600) / 60
           let sec = seconds % 60
           return String(format: "%02d:%02d:%02d", hours, minutes, sec)
       
    }
}

#Preview {
    RoutineHistoryView(session: RoutineHistoryDto(id: 1, routineId: 1, userId: 1, date: Date(),
      duration: 6969, difficulty: 7, caloriesBurnt: 490, notes: "Good session"), routineName: "Mock Routine")
}
