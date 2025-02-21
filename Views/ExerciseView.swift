//
//  ExerciseView.swift
//  FitTrack
//
//  Created by Joseph Chica on 10/7/24.
//

import SwiftUI

struct ExerciseView: View {
    var exercise: ExerciseDto
    
    @State private var sets = [
        (set: 1, reps: 12, weight: 0, isDone: false),
        (set: 2, reps: 10, weight: 0, isDone: false),
        (set: 3, reps: 8, weight: 0, isDone: false)
    ]
    @State private var timerValue = 0
    @State private var isTimerActive = false
    @State private var timer: Timer? = nil
    @State private var isEditing = false

    let primaryColor = Color(hex: "#19d4be")

    var body: some View {
        VStack {
            Spacer()
            NavigationLink(destination: ExerciseDetailsView(exercise: exercise)){
                Text(exercise.name)
                    .font(.title)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 2)
                    .foregroundColor(.black)
            }
            Spacer()
            
            // Table with sets/reps/weight
            VStack(alignment: .leading) {
                HStack(spacing: 16) {
                    Text("Set").bold().frame(maxWidth: .infinity, alignment: .center)
                    Text("Reps").bold().frame(maxWidth: .infinity, alignment: .center)
                    Text("Weight").bold().frame(maxWidth: .infinity, alignment: .center)
                    Text("Done").bold().frame(maxWidth: .infinity, alignment: .center)
                }
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                
                ForEach(sets.indices, id: \.self) { index in
                    HStack(spacing: 16) {
                        Text("\(sets[index].set)")
                            .frame(maxWidth: .infinity, alignment: .center)

                        if isEditing {
                            TextField("", value: $sets[index].reps, formatter: NumberFormatter())
                                .keyboardType(.numberPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(maxWidth: .infinity, alignment: .center)

                            TextField("", value: $sets[index].weight, formatter: NumberFormatter())
                                .keyboardType(.numberPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(maxWidth: .infinity, alignment: .center)
                        } else {
                            Text("\(sets[index].reps)")
                                .frame(maxWidth: .infinity, alignment: .center)
                            Text("\(sets[index].weight) lbs")
                                .frame(maxWidth: .infinity, alignment: .center)
                        }

                        Button(action: { toggleSetStatus(index: index) }) {
                            Image(systemName: sets[index].isDone ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(sets[index].isDone ? primaryColor : .gray)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .padding(.vertical, 8)
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(15)
            .shadow(radius: 5)
            
            Spacer()
            
            // Rest timer
            if isTimerActive {
                Text("Rest Timer: \(formattedTime)")
                    .font(.headline)
                    .foregroundColor(primaryColor)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 10)
            }
            
            Spacer()

            // Edit and Done buttons
            HStack {
                Button(action: { isEditing.toggle() }) {
                    Text(isEditing ? "Done" : "Edit")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(isEditing ? .green : .blue)
                        .cornerRadius(10)
                }
            }
        }
        .padding()
        .onDisappear {
            timer?.invalidate()
            isTimerActive = false
            timerValue = 0
        }
    }
    
    // Mark set as done and start timer
    private func markSetAsDone(index: Int) {
        withAnimation {
            sets[index].isDone = true
        }
        startTimer()
    }
    
    // Timer logic
    private func startTimer() {
        isTimerActive = true
        timerValue = 90 // 1 minute 30 seconds in seconds
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if timerValue > 0 {
                timerValue -= 1
            } else {
                timer?.invalidate()
                isTimerActive = false
            }
        }
    }
    
    // Format timer into mm:ss
    private var formattedTime: String {
        let minutes = timerValue / 60
        let seconds = timerValue % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func toggleSetStatus(index: Int) {
        sets[index].isDone.toggle()
        if sets[index].isDone {
            startTimer() // Start the timer only if the set is marked as done
        } else {
            timer?.invalidate() // Stop the timer if a set is unchecked
            isTimerActive = false
        }
    }
}

struct ExerciseView_Previews: PreviewProvider {
    static var previews: some View {
        ExerciseView(exercise: ExerciseDto(
            id: 1,
            name: "Barbell Squat",
            description: "A compound exercise that targets the lower body muscles, including quadriceps, hamstrings, and glutes.",
            level: "Intermediate",
            instructions: """
                1. Set the barbell at shoulder height.
                2. Step under the bar and place it across your shoulders.
                3. Grip the bar, lift it off the rack, and step back.
                4. Squat down until your thighs are parallel to the floor.
                5. Push back up to the starting position.
            """,
            equipmentNeeded: true,
            overloading: nil,
            powerStrengthSupplement: nil,
            isolationCompoundAccessory: nil,
            pushPullLegs: "Legs",
            verticalHorizontalRotational: nil,
            stretch: nil,
            videoURL: nil
        ))
    }
}
