//
//  CurrentStatsView.swift
//  FitTrack
//
//  Created by Joseph Chica on 9/26/24.
//

import SwiftUI
import Combine

struct CurrentStatsView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    
    // MARK: - State Variables
    @State private var weightString = ""
    @State private var bodyFatString = ""
    @State private var gender = "Male"
    @State private var level = "Beginner"
    @State private var member = false
    @State private var selectedAge = 18
    @State private var heightFeet = 5
    @State private var heightInches = 5

    // MARK: - Constants
    let minHeightFeet = 4
    let maxHeightFeet = 7
    let genders = ["Male", "Female", "Prefer not to answer"]
    let fitnessLevels = ["Beginner", "Intermediate", "Advanced"]

    // MARK: - Computed Properties
    private var weight: Int? {
        Int(weightString)
    }
    
    private var bodyFatPer: Int? {
        Int(bodyFatString)
    }

    private var heightInInches: Int {
        (heightFeet * 12) + heightInches
    }

    private var isFormValid: Bool {
        if let weight = weight, weight >= 50 && weight <= 500 {
            if let bodyFat = bodyFatPer, bodyFat >= 5 && bodyFat <= 60 {
                return true
            } else if bodyFatPer == nil { // Optional field is not filled
                return true
            }
        }
        return false
    }

    var body: some View {
        VStack {
            Text("Please fill out this information:")
                .font(.title)

            // Age Picker
            HStack {
                Text("Age: \(selectedAge)")
                Spacer()
                Picker("Age", selection: $selectedAge) {
                    ForEach(13...100, id: \.self) {
                        Text("\($0)").tag($0)
                    }
                }
                .pickerStyle(.wheel)
            }
            .padding()

            // Height Slider
            VStack {
                Text("Height: \(heightFeet) ft \(heightInches) in")
                Slider(value: Binding(
                    get: {
                        Double(heightFeet * 12 + heightInches)
                    },
                    set: { newValue in
                        let totalInches = Int(newValue)
                        heightFeet = totalInches / 12
                        heightInches = totalInches % 12
                    }
                ), in: Double(minHeightFeet * 12)...Double(maxHeightFeet * 12), step: 1)
            }
            .padding()

            // Weight Input Field
            TextField("Weight (lbs)", text: $weightString)
                .keyboardType(.numberPad)
                .onChange(of: weightString) { newValue in
                    // Filter out non-numeric characters
                    let filtered = newValue.filter { "0123456789".contains($0) }
                    if filtered != newValue {
                        weightString = filtered
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)

            // Body Fat Percentage Input Field
            TextField("Body Fat Percentage (Optional)", text: $bodyFatString)
                .keyboardType(.decimalPad)
                .onChange(of: bodyFatString) { newValue in
                    let filtered = newValue.filter { "0123456789.".contains($0) }
                    if filtered != newValue || newValue.components(separatedBy: ".").count > 2 {
                        bodyFatString = filtered
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)

            // Fitness Level Picker
            Picker("Fitness Level", selection: $level) {
                ForEach(fitnessLevels, id: \.self) { level in
                    Text(level)
                }
            }
            .pickerStyle(.segmented)
            .padding()

            // Gym Membership Toggle
            Toggle("Gym Membership", isOn: $member)
                .padding()

            NavigationLink(destination: GoalsView().environmentObject(userViewModel)) {
                Text("Continue")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(isFormValid ? AppColors.primary : AppColors.gray)
                    .cornerRadius(10)
            }
            .disabled(!isFormValid)
            .simultaneousGesture(
                TapGesture().onEnded {
                    if isFormValid {
                        let success = userViewModel.saveUserStats(
                            age: selectedAge,
                            height: heightInInches,
                            weight: weight ?? 0,
                            bodyFat: Double(bodyFatString),
                            fitnessLevel: level,
                            gymMembership: member
                        )
                        
                        if !success {
                            log(.error, "Error: Could not save user stats.")
                        }
                    }
                }
                )
           
        }
        .padding()
    }

    // MARK: - Actions
    private func saveAndContinue() {
        log(.info, "Saving info")
        guard let weight = weight else { return }
        
        // Update the user's properties
        if let user = userViewModel.user {
            user.currentStats.age = selectedAge
            user.currentStats.height = Double(heightInInches)
            user.currentStats.currentWeight = Double(weight)
            user.currentStats.bodyFat = Double(bodyFatString) ?? nil
            user.currentStats.fitnessLevel = level
            user.currentStats.gymMembership = member
            
            // Save changes to the database
            if userViewModel.saveChanges(for: user) {
                log(.info, "User information saved successfully.")
            } else {
                log(.error, "Failed to save user information.")
            }
        }
    }
}

// Preview provider to visualize the CurrentStatsView in Xcode
struct CurrentStatsView_Previews: PreviewProvider {
    static var previews: some View {
        CurrentStatsView()
            .environmentObject(UserViewModel())
    }
}
