//
//  UserViewModel.swift
//  FitTrack
//
//  Created by Joseph Chica on 1/2/25.
//
import Combine
import Foundation
import Logging

final class UserViewModel: ObservableObject {
    @Published var user: UserDto? = nil
    @Published var name: String = ""
    @Published var saveError: String? = nil
    @Published var userNameFilled = false
    @Published var userStatsFilled = false
    @Published var userGoalsFilled = false
    @Published var validationErrors: [String] = []
    @Published var userSetupFinished = false
    
    func isSetupComplete() -> String {
        if self.user?.name == nil {
            return "StartingView"
        }
        else if self.user?.currentStats.currentWeight == nil {
            return "CurrentStatsView"
        }
        else if self.user?.goals.goalWeight == nil {
            return "GoalsView"
        }
        else {
            return "MainView"
        }
    }
    
    
    func loadFirstUser() {
        log(.info, "Attempting to fetch the first user from the database.")
        if let firstUser = DatabaseManager.shared.getFirstUser() {
            self.user = firstUser
            self.name = firstUser.name
            log(.info, "First user loaded: \(firstUser.name)")
        } else {
            log(.warning, "No users found in the database.")
            self.user = nil
            self.name = ""
        }
    }

    func loadUserByName() {
        log(.info, "Fetching user by name: \(name)")
        self.user = DatabaseManager.shared.getUserByName(name: name)
        if let user = user {
            log(.info, "Found user: \(user.name)")
        } else {
            log(.error, "No user found with name: \(name)")
        }
    }
    
    func saveUserName() -> Bool {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            saveError = "Name cannot be empty or just whitespace."
            return false
        }

        if DatabaseManager.shared.createUser(withName: trimmedName) {
            log(.info, "User '\(trimmedName)' saved to DB")
            saveError = nil

            name = trimmedName
            userNameFilled = true
            return true
        } else {
            log(.error, "Failed to save user '\(trimmedName)'")
            saveError = "Failed to save user."
            return false
        }
    }
    
    private let displayNameMapping: [String: String] = [
        "name": "Name",
        "username": "Username",
        "email": "Email",
        "age": "Age",
        "height": "Height",
        "current_weight": "Current Weight",
        "body_fat": "Body Fat",
        "fitness_level": "Fitness Level",
        "gym_membership": "Gym Membership",
        "goal_weight": "Goal Weight",
        "goal_gym_days": "Goal Gym Days",
        "goal_exercise": "Goal Exercise",
        "goal_body_fat": "Goal Body Fat"
    ]

    private func updateField(userId: Int, fieldName: String, newValue: String) -> Bool {
        let trimmedValue = newValue.trimmingCharacters(in: .whitespacesAndNewlines)

        // Ensure the value is not empty after trimming
        guard !trimmedValue.isEmpty else {
            saveError = "\(displayNameMapping[fieldName, default: fieldName.capitalized]) cannot be empty or just whitespace."
            return false
        }

        // Field-specific validation
        switch fieldName {
        case "name":
            guard validateName(trimmedValue) else {
                saveError = "Invalid name format. Please enter a valid name."
                return false
            }
        case "email":
            guard validateEmail(trimmedValue) else {
                saveError = "Invalid email address. Please enter a valid email."
                return false
            }
        case "age":
            if let age = Int(trimmedValue), !validateAge(age) {
                saveError = "Invalid age. Please enter a value between 13 and 99."
                return false
            }
        case "current_weight", "goal_weight":
            if let weight = Double(trimmedValue), !validateWeight(weight) {
                saveError = "Invalid weight. Please enter a value between 50 and 500."
                return false
            }
        case "body_fat", "goal_body_fat":
            if let bodyFat = Double(trimmedValue), !validateBodyFat(bodyFat) {
                saveError = "Invalid body fat percentage. Please enter a value between 5 and 50."
                return false
            }
        case "goal_gym_days":
            if let gymDays = Int(trimmedValue), !validateGymDays(gymDays) {
                saveError = "Invalid number of gym days. Please enter a value between 1 and 7."
                return false
            }
        default:
            break
        }

        // Update the field in the database
        if DatabaseManager.shared.updateUserField(userId: userId, fieldName: fieldName, value: trimmedValue) {
            log(.info, "\(displayNameMapping[fieldName, default: fieldName.capitalized]) updated to \(trimmedValue) for user ID \(userId).")
            saveError = nil
            return true
        } else {
            log(.error, "Failed to update \(displayNameMapping[fieldName, default: fieldName.capitalized]) for user ID \(userId).")
            saveError = "Failed to update \(displayNameMapping[fieldName, default: fieldName.capitalized])."
            return false
        }
    }


    func saveChanges(for user: UserDto) -> Bool {
        let userId = user.userId
        var success = true
        
        let fieldsToUpdate: [(fieldName: String, value: String?)] = [
            ("name", user.name),
            ("username", user.username),
            ("email", user.email),
            ("age", user.currentStats.age.map { "\($0)" }),
            ("height", user.currentStats.height.map { "\($0)" }),
            ("current_weight", user.currentStats.currentWeight.map { "\($0)" }),
            ("body_fat", user.currentStats.bodyFat.map { "\($0)" }),
            ("fitness_level", user.currentStats.fitnessLevel),
            ("gym_membership", user.currentStats.gymMembership.map { $0 ? "1" : "0" }),
            ("goal_weight", user.goals.goalWeight.map { "\($0)" }),
            ("goal_gym_days", user.goals.goalGymDays.map { "\($0)" }),
            ("goal_exercise", user.goals.goalExercise),
            ("goal_body_fat", user.goals.goalBodyFat.map { "\($0)" })
        ]

        for (fieldName, value) in fieldsToUpdate {
            if let value = value {
                success = updateField(userId: userId, fieldName: fieldName, newValue: value) && success
            }
        }

        if success {
            log(.info, "All changes saved for user ID \(userId).")
        } else {
            log(.error, "Failed to save some changes for user ID \(userId).")
        }
        return success
    }
    
    func updateImage(for userId: Int, field: String, url: String) {
        let success = DatabaseManager.shared.updateUserField(userId: userId, fieldName: field, value: url)
        if success {
            log(.info, "\(field.capitalized) updated successfully with URL: \(url) for user ID \(userId).")
        } else {
            log(.error, "Failed to update \(field) for user ID \(userId).")
        }
    }
    func saveUserStats(age: Int, height: Int, weight: Int, bodyFat: Double?, fitnessLevel: String, gymMembership: Bool) -> Bool {
        loadFirstUser()
        log(.info, "Saving user stats for user...")
        guard let user = self.user else {
            saveError = "No user loaded to save stats"
            log(.error, "No user loaded to save stats")
            return false
        }
        user.currentStats.age = age
        user.currentStats.currentWeight = Double(weight)
        user.currentStats.height = Double(height)
        user.currentStats.bodyFat = bodyFat ?? nil
        user.currentStats.fitnessLevel = fitnessLevel
        user.currentStats.gymMembership = gymMembership
        
        log(.info, "user name: \(user.name)")
        log(.info, "user id: \(user.userId)")
        let success = saveChanges(for: user)
        
        if success {
            userStatsFilled = true
            log(.info, "saved user stats for \(user.name)")
        }
        else {
            log(.error, "Failed to save user stats")
        }
        return success
    }
    
    func saveUserGoals(goalWeight: Int, gymDays: Int, goalExercise: String) -> Bool {
        loadFirstUser()
        guard let user = self.user else {
            saveError = "No user loaded to save goals."
            return false
        }
        user.goals.goalWeight = Double(goalWeight)
        user.goals.goalGymDays = gymDays
        user.goals.goalExercise = goalExercise

        let success = saveChanges(for: user)

        if success {
            userGoalsFilled = true
            log(.info, "Goals saved successfully for user ID \(user.userId).")
        } else {
            log(.error, "Failed to save goals for user ID \(user.userId).")
        }

        userSetupFinished = true
        
        return success
    }
    
    private func validateName(_ name: String) -> Bool {
        let nameRegex = "^[A-Za-z]+(?:[ '-][A-Za-z]+)*$"
        return NSPredicate(format: "SELF MATCHES %@", nameRegex).evaluate(with: name)
    }

    private func validateEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }

    private func validateWeight(_ weight: Double) -> Bool {
        return weight >= 50 && weight <= 500
    }
    
    private func validateAge(_ age: Int) -> Bool {
        return age >= 13 && age <= 99
    }
    
    private func validateBodyFat(_ bodyFat: Double) -> Bool {
        return bodyFat >= 5 && bodyFat <= 50
    }

    private func validateGymDays(_ gymDays: Int) -> Bool {
        return gymDays >= 1 && gymDays <= 7
    }
}
