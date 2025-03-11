//
//  GoalsView.swift
//  FitTrack
//
//  Created by Joseph Chica on 9/26/24.
//

import SwiftUI
import Combine

struct GoalsView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    
    // MARK: - State Variables
    @State private var weightString = "" // Input for goal weight as a string
    @State private var daysWorkingOutString = "" // Input for the number of workout days per week as a string
    @State private var goal = "Strength" // Selected fitness goal from the picker
    @StateObject private var viewModel = RoutineViewModel() 

    // MARK: - Constants
    let fitnessGoal = ["Strength", "Weight Loss", "Cardio",] // Array of fitness goal options
    let primaryColor = Color(hex: "#19d4be") // Custom color for the finish button

    // MARK: - Computed Properties for Validation
    private var weight: Int? {
        Int(weightString)
    }

    private var daysWorkingOut: Int? {
        Int(daysWorkingOutString)
    }

    private var isWeightValid: Bool {
        if let weight = weight {
            return weight > 50 && weight < 500
        }
        return false
    }

    private var isDaysWorkingOutValid: Bool {
        if let days = daysWorkingOut {
            return days >= 1 && days <= 7
        }
        return false
    }

    private var isFormValid: Bool {
        isWeightValid && isDaysWorkingOutValid
    }

    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                // Title text
                Text("Please fill out this information:")
                    .font(.headline)
                    .padding(.bottom, 10)

                // MARK: - Goal Weight Input
                VStack(alignment: .leading, spacing: 5) {
                    TextField("Goal Weight (lbs)", text: $weightString)
                        .keyboardType(.numberPad)
                        .padding(15)
                        .background(Color.white)
                        .cornerRadius(12)
                        .onReceive(Just(weightString)) { newValue in
                            // Filter out non-numeric characters
                            let filtered = newValue.filter { "0123456789".contains($0) }
                            if filtered != newValue {
                                self.weightString = filtered
                            }
                        }
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3)
                        .padding(.horizontal)

                    // Validation message for weight
                    if !isWeightValid && !weightString.isEmpty {
                        Text("Weight must be between 50 and 500 lbs.")
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding(.leading)
                    }
                }

                // MARK: - Goal Days Working Out Input
                VStack(alignment: .leading, spacing: 5) {
                    TextField("Goal Days in Gym per Week", text: $daysWorkingOutString)
                        .keyboardType(.numberPad)
                        .onReceive(Just(daysWorkingOutString)) { newValue in
                            // Filter out non-numeric characters
                            let filtered = newValue.filter { "0123456789".contains($0) }
                            if filtered != newValue {
                                self.daysWorkingOutString = filtered
                            }
                        }
                        .padding(15)
                        .background(Color.white)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3)
                        .padding(.horizontal)

                    // Validation message for days working out
                    if !isDaysWorkingOutValid && !daysWorkingOutString.isEmpty {
                        Text("Days must be between 1 and 7.")
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding(.leading)
                    }
                }

                // MARK: - Fitness Goal Picker
                HStack {
                    Text("Goal")
                        .font(.headline)
                    Picker("Fitness Goal", selection: $goal) {
                        ForEach(fitnessGoal, id: \.self) {
                            Text($0)
                                .font(.system(size: 18, weight: .medium))
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                .padding(.horizontal)

                NavigationLink(destination: RoutineSelectorView().environmentObject(viewModel)) {
                    Text("Finish")
                        .font(.system(size: 18, weight: .bold))
                        .frame(maxWidth: .infinity)
                        .padding(20)
                        .background(isFormValid ? primaryColor : Color.gray.opacity(0.5))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .padding(.horizontal)
                }
                .disabled(!isFormValid) // Disable button if form is invalid
                .simultaneousGesture(
                    TapGesture().onEnded {
                        if isFormValid {
                            // Save the user's goals using the UserViewModel
                            if !userViewModel.saveUserGoals(goalWeight: weight ?? 0, gymDays: daysWorkingOut ?? 0, goalExercise: goal) {
                                log(.error, "Failed to save user goals.")
                            }
                            // Trigger routine generation
                            viewModel.createRoutinesBasedOnGoal(user: userViewModel.user ?? UserDto(userId: 999, name: "JoeShmoe"))
                        }
                    }
                )
                .animation(.easeInOut, value: isFormValid)
            }
            .padding(.top, 40)
        }
    }
}

// MARK: - Preview
struct GoalsView_Previews: PreviewProvider {
    static var previews: some View {
        GoalsView()
    }
}
