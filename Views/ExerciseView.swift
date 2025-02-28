//
//  ExerciseView.swift
//  FitTrack
//
//  Created by Joseph Chica on 10/7/24.
//

import SwiftUI

struct ExerciseView: View {
    var routine: RoutineDto
    
    @State private var currentIndex: Int = 0
    @State private var exercise: ExerciseDto
    @State private var sets: [(setNumber: Int, reps: Int, weight: Double, isDone: Bool)] = []

    @State private var exerciseHistory: [ExerciseHistoryDto] = []
    @State private var timerValue = 0
    @State private var isTimerActive = false
    @State private var timer: Timer? = nil
    @State private var isEditing = false

    init(routine: RoutineDto) {
        self.routine = routine
        let initialExerciseWithSets = routine.exerciseWithSetsDto?.first ?? ExerciseWithSetsDto(exercise: ExerciseDto(id: 0, name: "No Exercise", description: nil, level: nil, instructions: nil, equipmentNeeded: nil, overloading: nil, powerStrengthSupplement: nil, isolationCompoundAccessory: nil, pushPullLegs: nil, verticalHorizontalRotational: nil, stretch: nil, videoURL: nil), sets: [])
        _exercise = State(initialValue: initialExerciseWithSets.exercise)
        _sets = State(initialValue: initialExerciseWithSets.sets.map { ($0.setNumber, $0.reps, $0.weight, false) })
    }

    var body: some View {
        VStack {
            Spacer()
            HStack {
                Button(action: previousExercise) {
                    Image(systemName: "chevron.left")
                        .font(.title)
                        .padding()
                        .background(AppColors.light.opacity(0.7))
                        .clipShape(Circle())
                        .shadow(radius: 2)
                }
                .disabled(currentIndex == 0)
                
                NavigationLink(destination: ExerciseDetailsView(exercise: exercise)) {
                    Text(exercise.name)
                        .font(.title)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 2)
                        .foregroundColor(.black)
                }

                Button(action: nextExercise) {
                    Image(systemName: "chevron.right")
                        .font(.title)
                        .padding()
                        .background(AppColors.light.opacity(0.7))
                        .clipShape(Circle())
                        .shadow(radius: 2)
                }
                .disabled(currentIndex == (routine.exerciseWithSetsDto?.count ?? 1) - 1)
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
                        Text("\(sets[index].setNumber)")
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
                            Text("\(formattedWeight(sets[index].weight)) lbs")
                                .frame(maxWidth: .infinity, alignment: .center)
                        }

                        Button(action: { toggleSetStatus(index: index) }) {
                            Image(systemName: sets[index].isDone ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(sets[index].isDone ? AppColors.primary : AppColors.gray)
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

            // Rest timer
            if isTimerActive {
                Text("Rest Timer: \(formattedTime)")
                    .font(.headline)
                    .foregroundColor(AppColors.primary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 10)
            }
            
            Spacer()
            
            ProgressSection(exerciseHistory: exerciseHistory)
                .onAppear {
                    mockLoadExerciseHistory()
                }

            Spacer()

            // Edit button
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

    // MARK: - Load Exercise History
    private func loadExerciseHistory() {
        
    }
    private func mockLoadExerciseHistory() {
        // Simulating data fetch (replace with real database call)
        let sampleHistory = [
            ExerciseHistoryDto(
                id: 1,
                exerciseId: exercise.id,
                routineId: routine.id,
                date: Date().addingTimeInterval(-86400),
                sets: [
                    SetsDto(setNumber: 1, reps: 10, weight: 50),
                    SetsDto(setNumber: 2, reps: 8, weight: 52.5)
                ]
            ),
            ExerciseHistoryDto(
                id: 2,
                exerciseId: exercise.id,
                routineId: routine.id,
                date: Date().addingTimeInterval(-172800),
                sets: [
                    SetsDto(setNumber: 1, reps: 9, weight: 55),
                    SetsDto(setNumber: 2, reps: 7, weight: 57.5)
                ]
            )
        ]
        exerciseHistory = sampleHistory.filter { $0.exerciseId == exercise.id }
    }

    // MARK: - Helpers
    private func formattedWeight(_ weight: Double) -> String {
        return weight.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", weight) : String(format: "%.1f", weight)
    }
    
    // MARK: - Navigation
    private func previousExercise() {
        guard currentIndex > 0, let exercises = routine.exerciseWithSetsDto else { return }
        currentIndex -= 1
        updateExercise(index: currentIndex, exercises: exercises)
    }

    private func nextExercise() {
        guard let exercises = routine.exerciseWithSetsDto, currentIndex < exercises.count - 1 else { return }
        currentIndex += 1
        updateExercise(index: currentIndex, exercises: exercises)
    }

    private func updateExercise(index: Int, exercises: [ExerciseWithSetsDto]) {
        let newExerciseWithSets = exercises[index]
        exercise = newExerciseWithSets.exercise
        sets = newExerciseWithSets.sets.map { ($0.setNumber, $0.reps, $0.weight, false) }
    }

    // MARK: - Timer Logic
    private func startTimer() {
        isTimerActive = true
        timerValue = 90
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

    private var formattedTime: String {
        let minutes = timerValue / 60
        let seconds = timerValue % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func formattedDate(_ date: Date) -> String {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter.string(from: date)
        }

    private func toggleSetStatus(index: Int) {
        sets[index].isDone.toggle()
        if sets[index].isDone {
            startTimer()
        } else {
            timer?.invalidate()
            isTimerActive = false
        }
    }
}

struct ProgressSection: View {
    var exerciseHistory: [ExerciseHistoryDto]

    var body: some View {
        VStack(alignment: .leading) {
            Text("Exercise Progress")
                .font(.title2)
                .bold()
                .padding(.bottom, 5)

            Group {  // Helps Swift break down type-checking
                if exerciseHistory.isEmpty {
                    Text("No history available.")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    ForEach(exerciseHistory, id: \.id) { history in
                        VStack(alignment: .leading) {
                            secondForEach(history: history) // Correct usage
                            Divider()
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 5)
    }

    private func secondForEach(history: ExerciseHistoryDto) -> some View {
        VStack(alignment: .leading) {
            Text("Date: \(formattedDate(history.date))")
                .font(.headline)

            ForEach(history.sets) { set in
                HStack {
                    Text("Set: \(set.setNumber)")
                    Spacer()
                    Text("Reps: \(set.reps)")
                    Spacer()
                    Text("Weight: \(formattedWeight(set.weight)) lbs")
                }
                .font(.subheadline)
                .padding(.vertical, 2)
            }
        }
    }

    private func formattedWeight(_ weight: Double) -> String {
        weight.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", weight) : String(format: "%.1f", weight)
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}


struct ExerciseView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleExercises = [
            ExerciseWithSetsDto(
                exercise: ExerciseDto(
                    id: 1,
                    name: "Bench Press",
                    description: "A classic chest exercise",
                    level: "Intermediate",
                    instructions: "Lie on a bench and press the barbell up.",
                    equipmentNeeded: true,
                    overloading: true,
                    powerStrengthSupplement: "Yes",
                    isolationCompoundAccessory: "Compound",
                    pushPullLegs: "Push",
                    verticalHorizontalRotational: "Horizontal",
                    stretch: false,
                    videoURL: nil
                ),
                sets: [
                    SetsDto(setNumber: 1, reps: 12, weight: 135),
                    SetsDto(setNumber: 2, reps: 10, weight: 145),
                    SetsDto(setNumber: 3, reps: 8, weight: 155)
                ]
            ),
            ExerciseWithSetsDto(
                exercise: ExerciseDto(
                    id: 2,
                    name: "Squat",
                    description: "A fundamental leg exercise",
                    level: "Advanced",
                    instructions: "Squat down and stand up with weight.",
                    equipmentNeeded: true,
                    overloading: true,
                    powerStrengthSupplement: "Yes",
                    isolationCompoundAccessory: "Compound",
                    pushPullLegs: "Legs",
                    verticalHorizontalRotational: "Vertical",
                    stretch: false,
                    videoURL: nil
                ),
                sets: [
                    SetsDto(setNumber: 1, reps: 10, weight: 185),
                    SetsDto(setNumber: 2, reps: 8, weight: 205),
                    SetsDto(setNumber: 3, reps: 6, weight: 225)
                ]
            )
        ]

        let sampleRoutine = RoutineDto(
            id: 1,
            name: "Full Body Strength",
            description: "A routine focusing on overall strength.",
            exerciseWithSetsDto: sampleExercises
        )

        return ExerciseView(routine: sampleRoutine)
    }
}
