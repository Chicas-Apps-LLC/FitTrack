//
//  CurrentStatsView.swift
//  FitTrack
//
//  Created by Joseph Chica on 9/26/24.
//
import SwiftUI

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
    @State private var showContent = false // For animations
    @State private var continueButtonPressed = false

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
        NavigationStack {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [AppColors.primary, AppColors.secondary]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 30) {
                        // Title
                        Text("Your Current Stats")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(AppColors.light)
                        
                        // Form Fields
                        VStack(spacing: 20) {
                            agePicker
                            heightSlider
                            inputField(title: "Weight (lbs)", text: $weightString, keyboardType: .numberPad)
                            inputField(title: "Body Fat % (Optional)", text: $bodyFatString, keyboardType: .decimalPad)
                            fitnessLevelPicker
                            gymMembershipToggle
                        }
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(15)
                        .shadow(radius: 5)
                        .padding(.horizontal)
                        
                        // Spacer removed here to avoid pushing the button too far down
                        
                        // Continue Button
                        NavigationLink(destination: GoalsView().environmentObject(userViewModel)) {
                            Text("Continue")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .frame(maxWidth: .infinity)
                                .padding(20)
                                .background(isFormValid ? AppColors.primary : AppColors.gray)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                                .shadow(radius: 5)
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 20) // Prevents the button from being too low
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
                    .padding(.top, 60)
                }

            }
        }
    }
    
    // MARK: - Custom Views
    
    private var agePicker: some View {
        HStack {
            Text("Age:")
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .foregroundColor(AppColors.light)
            Spacer()
            Picker("Age", selection: $selectedAge) {
                ForEach(13...100, id: \.self) {
                    Text("\($0)").tag($0)
                }
            }
            .pickerStyle(.menu)
            .accentColor(AppColors.secondary)
            .background(AppColors.light.opacity(0.5))
        }
        .padding(.horizontal)
    }
    
    private var heightSlider: some View {
        VStack {
            Text("Height: \(heightFeet) ft \(heightInches) in")
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .foregroundColor(AppColors.light)
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
            .accentColor(AppColors.primary)
        }
        .padding()
    }

    private func inputField(title: String, text: Binding<String>, keyboardType: UIKeyboardType) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(AppColors.light)
            TextField(title, text: text)
                .keyboardType(keyboardType)
                .padding()
                .background(Color.white.opacity(0.8))
                .cornerRadius(12)
                .shadow(radius: 5)
                .padding(.horizontal)
        }
    }
    
    private var fitnessLevelPicker: some View {
        VStack(alignment: .leading) {
            Text("Fitness Level")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(AppColors.light)
            Picker("Fitness Level", selection: $level) {
                ForEach(fitnessLevels, id: \.self) { level in
                    Text(level)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
        }
    }
    
    private var gymMembershipToggle: some View {
        Toggle("Gym Membership", isOn: $member)
            .padding()
            .font(.system(size: 16, weight: .bold, design: .rounded))
            .foregroundColor(AppColors.light)
    }
}

// Preview
struct CurrentStatsView_Previews: PreviewProvider {
    static var previews: some View {
        CurrentStatsView()
            .environmentObject(UserViewModel())
    }
}
