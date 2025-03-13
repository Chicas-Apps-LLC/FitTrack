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
        VStack(alignment: .leading, spacing: 20) {
            // Routine Name
            Text("\(routineName) Session")
                .font(.title2)
                .bold()
                .padding(.bottom, 5)
            
            // Details Section
            VStack(alignment: .leading, spacing: 12) {
                infoRow(icon: "calendar", text: session.date?.formatted() ?? "No date")
                infoRow(icon: "clock", text: formattedTime(Int(session.duration ?? 0)))
                infoRow(icon: "flame", text: "\(session.caloriesBurnt ?? 0) kcal")
                infoRow(icon: "star.fill", text: difficultyText(session.difficulty ?? 0))
            }
            .padding(.vertical, 8)
            
            // Notes Section
            if let notes = session.notes, !notes.isEmpty {
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
    
    // Helper method to format time
    private func formattedTime(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let sec = seconds % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, sec)
    }
    
    // Helper method for difficulty stars
    private func difficultyText(_ difficulty: Int) -> String {
        String(repeating: "★", count: difficulty) + String(repeating: "☆", count: max(0, 5 - difficulty))
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
    RoutineHistoryView(session: RoutineHistoryDto(id: 1, routineId: 1, userId: 1, date: Date(),
      duration: 6969, difficulty: 4, caloriesBurnt: 490, notes: "Good session"), routineName: "Mock Routine")
}

