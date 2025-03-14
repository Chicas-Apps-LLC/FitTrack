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
    @State private var weightString = ""
    @State private var daysWorkingOutString = ""
    @State private var goal = "Strength"
    @State private var showContent = false  // For animation effect
    
    // MARK: - Constants
    let fitnessGoals = ["Strength", "Weight Loss", "Cardio"]
    let minWeight = 50
    let maxWeight = 500
    let primaryColor = AppColors.primary

    // MARK: - Computed Properties
    private var weight: Int? { Int(weightString) }
    private var daysWorkingOut: Int? { Int(daysWorkingOutString) }

    private var isWeightValid: Bool {
        if let weight = weight {
            return weight >= minWeight && weight <= maxWeight
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
        NavigationStack {
            ZStack {
                // Gradient Background
                LinearGradient(
                    gradient: Gradient(colors: [AppColors.primary, AppColors.secondary]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 65) {
                        Spacer()
                        // Title
                        Text("Set Your Goals")
                            .font(.system(size: 38, weight: .bold, design: .rounded))
                            .foregroundColor(AppColors.light)
                            .opacity(showContent ? 1 : 0)
                            .animation(.easeIn(duration: 0.8), value: showContent)

                        Spacer()
                        // Form Container
                        VStack(spacing: 20) {
                            inputField(title: "Goal Weight (lbs)", text: $weightString, isValid: isWeightValid, validationMessage: "Weight must be between \(minWeight) and \(maxWeight) lbs.")
                            inputField(title: "Goal Days in Gym per Week", text: $daysWorkingOutString, isValid: isDaysWorkingOutValid, validationMessage: "Days must be between 1 and 7.")
                            goalPicker
                        }
                        .padding()
                        .background(AppColors.light.opacity(0.2))
                        .cornerRadius(15)
                        .shadow(radius: 5)
                        .padding(.horizontal)
                        .opacity(showContent ? 1 : 0)
                        .animation(.easeIn(duration: 1.0), value: showContent)

                        Spacer()
                        // Finish Button
                        NavigationLink(destination: MainView().environmentObject(userViewModel)) {
                            Text("Finish")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .frame(maxWidth: .infinity)
                                .padding(20)
                                .background(isFormValid ? primaryColor : AppColors.gray)
                                .foregroundColor(AppColors.light)
                                .cornerRadius(12)
                                .padding(.horizontal)
                        }
                        .disabled(!isFormValid)
                        .opacity(showContent ? 1 : 0)
                        .animation(.easeIn(duration: 1.2), value: showContent)
                    }
                    .padding(.top, 40)
                }
            }
            .onAppear {
                showContent = true
            }
        }
    }
    
    // MARK: - Subviews
    private var goalPicker: some View {
        VStack {
            Text("Select Goal")
                .font(.headline)
                .foregroundColor(.white)
            
            Picker("Fitness Goal", selection: $goal) {
                ForEach(fitnessGoals, id: \.self) {
                    Text($0)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.black)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .background(Color.white.opacity(0.2))
            .cornerRadius(12)
            .padding(.horizontal)
        }
    }

    private func inputField(title: String, text: Binding<String>, isValid: Bool, validationMessage: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            TextField(title, text: text)
                .keyboardType(.numberPad)
                .padding(15)
                .background(Color.white)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3)
                .padding(.horizontal)
                .onReceive(Just(text.wrappedValue)) { newValue in
                    let filtered = newValue.filter { "0123456789".contains($0) }
                    if filtered != newValue {
                        text.wrappedValue = filtered
                    }
                }

            if !isValid && !text.wrappedValue.isEmpty {
                Text(validationMessage)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.leading)
            }
        }
    }
}

// MARK: - Preview
struct GoalsView_Previews: PreviewProvider {
    static var previews: some View {
        GoalsView().environmentObject(UserViewModel())
    }
}
