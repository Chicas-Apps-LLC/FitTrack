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
    @State private var goal = ""
    @State private var showContent = false  // For animation effect
    @StateObject private var routineViewModel = RoutineViewModel()
    @State private var selectedGoal: FitnessGoal?
    
    // MARK: - Constants
    let minWeight = 50
    let maxWeight = 500
    let primaryColor = AppColors.primary

    // MARK: - Computed Properties
    private var weight: Int? { Int(weightString) }
    private var daysWorkingOut: Int? { Int(daysWorkingOutString) }

    let fitnessGoals = FitnessGoal.allCases
    
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
    
    private var isGoalValid: Bool {
        !goal.isEmpty
    }

    private var isFormValid: Bool {
        isWeightValid && isDaysWorkingOutValid && isGoalValid
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
                    VStack(spacing: 45) {
                        Spacer()
                        // Title
                        Text("Set Your Goals")
                            .font(.system(size: 38, weight: .bold, design: .rounded))
                            .foregroundColor(AppColors.light)
                            .opacity(showContent ? 1 : 0)
                            .animation(.easeIn(duration: 0.8), value: showContent)

                        // Form Container
                        VStack() {
                            inputField(title: "Goal Weight (lbs)", text: $weightString, isValid: isWeightValid, validationMessage: "Weight must be between \(minWeight) and \(maxWeight) lbs.")
                            inputField(title: "Goal Days in Gym per Week", text: $daysWorkingOutString, isValid: isDaysWorkingOutValid, validationMessage: "Days must be between 1 and 7.")
                            goalGridPicker
                            
                        }
                        .padding()
                        .background(AppColors.light.opacity(0.2))
                        .cornerRadius(15)
                        .shadow(radius: 5)
                        .padding(.horizontal)
                        .opacity(showContent ? 1 : 0)
                        .animation(.easeIn(duration: 1.0), value: showContent)

                        if let selectedGoal {
                            Text(selectedGoal.description)
                                .font(.subheadline)
                                .foregroundColor(.white)
                                .padding(.horizontal)
                        }
                        
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
                        .simultaneousGesture(
                            TapGesture().onEnded {
                                if isFormValid {
                                    if !userViewModel.saveUserGoals(goalWeight: weight ?? 0, gymDays: daysWorkingOut ?? 0, goalExercise: goal) {
                                        log(.error, "Failed to save user goals.")
                                    }
                                    routineViewModel.createRoutinesBasedOnGoal(user: userViewModel.user ?? UserDto(userId: 999, name: "JoeShmoe"))
                                }
                            }
                        )
                        .opacity(showContent ? 1 : 0)
                        .animation(.easeIn(duration: 1.2), value: showContent)
                    }
                }
            }
            .onAppear {
                showContent = true
            }
        }
    }
    
    private var goalGridPicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Select Goal")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal)
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .center)
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 15) {
                ForEach(fitnessGoals) { goal in
                    Button(action: {
                        selectedGoal = selectedGoal == goal ? nil : goal
                    }) {
                        Text(goal.rawValue)
                            .fontWeight(.medium)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(selectedGoal == goal ? AppColors.primary : AppColors.gray.opacity(0.3))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
            }
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

enum FitnessGoal: String, CaseIterable, Identifiable {
    case strength = "Strength"
    case weightLoss = "Weight Loss"
    case cardio = "Cardio"
    case bodybuilding = "Body building"
    case flexibility = "Flexibility"
    case endurance = "Endurance"
    case football = "Football"
    case basketball = "Basketball"
    case soccer = "Soccer"
    case track = "Track"

    var id: String { rawValue }

    var description: String {
        switch self {
        case .strength:
            return "Increase muscle power and overall body strength."
        case .weightLoss:
            return "Burn fat and achieve a leaner physique."
        case .cardio:
            return "Boost cardiovascular health and endurance."
        case .bodybuilding:
            return "Build significant muscle mass and improve physique."
        case .flexibility:
            return "Improve joint mobility, reduce injury risk, and enhance range of motion."
        case .endurance:
            return "Build long-term stamina for extended physical activity."
        case .football:
            return "Enhance explosive power, agility, and team-based coordination."
        case .basketball:
            return "Improve vertical jump, speed, and court agility."
        case .soccer:
            return "Increase footwork, endurance, and lower-body strength."
        case .track:
            return "Optimize sprinting or distance performance with explosive training."
        }
    }
}

// MARK: - Preview
struct GoalsView_Previews: PreviewProvider {
    static var previews: some View {
        GoalsView().environmentObject(UserViewModel())
    }
}
