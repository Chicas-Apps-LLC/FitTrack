//
//  ContentView.swift
//  FitTrack
//
//  Created by Joseph Chica on 9/26/24.
//

import SwiftUI
import Logging

struct StartingView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    @FocusState private var isNameFieldFocused: Bool
    @State private var showContent = false
    @State private var showError = false
    @State private var continueButtonPressed = false

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [AppColors.primary, AppColors.secondary]),
                   startPoint: .topLeading,
                   endPoint: .bottomTrailing
               )
                    .ignoresSafeArea()

                VStack(spacing: 40) {
                    // App Title and Image
                    VStack(spacing: 10) {
                        Text("FitTrack")
                            .font(.system(size: 42, weight: .bold, design: .rounded))
                            .foregroundColor(AppColors.light)
                            .opacity(showContent ? 1 : 0) // Fade-in animation
                            .animation(.easeIn(duration: 1), value: showContent)

                        Text("by Chicas Apps")
                            .font(.system(size: 20, weight: .medium, design: .rounded))
                            .foregroundColor(AppColors.light)
                            .opacity(showContent ? 1 : 0) // Fade-in animation
                            .animation(.easeIn(duration: 1.2), value: showContent)
                    }

                    // Name Input Section
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Let’s start with your name")
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                .foregroundColor(.black)
                                .padding(.leading)
                                .padding(.trailing)

                            Spacer()

                            NavigationLink(value: FitTrackDestination.routineCreator) {
                                Text("Skip")
                                    .font(.system(size: 15, design: .rounded))
                                    .foregroundColor(AppColors.night)
                                    .padding(.trailing)
                            }
                        }

                        TextField("Enter your name", text: $userViewModel.name)
                            .focused($isNameFieldFocused)
                            .padding(15)
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(AppColors.primary.opacity(0.5), lineWidth: 1)
                            )
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3)
                            .padding(.horizontal)
                            .disableAutocorrection(true)
                            .textInputAutocapitalization(.words)
                            .scaleEffect(showContent ? 1 : 0.9) // Scale-in animation
                            .opacity(showContent ? 1 : 0) // Fade-in animation
                            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: showContent)
                            .onAppear {
                                isNameFieldFocused = true
                                showContent = true // Trigger animations
                            }
                    }

                    Spacer()

                    // Error Message
                    if userViewModel.name.isEmpty && showError {
                        Text("Name is required to continue.")
                            .font(.caption)
                            .foregroundColor(AppColors.pink)
                            .transition(.move(edge: .bottom)) // Slide-in animation
                            .animation(.easeInOut, value: showError)
                    }

                    // Continue Button
                    NavigationLink(value: FitTrackDestination.currentStats) {
                        Text("Continue")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .frame(maxWidth: .infinity)
                            .padding(20)
                            .background(userViewModel.name.isEmpty ? AppColors.gray : AppColors.primary)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3)
                            .scaleEffect(continueButtonPressed ? 0.95 : 1)
                            .animation(.easeOut(duration: 0.2), value: continueButtonPressed)
                    }
                    .padding(.horizontal)
                    .disabled(userViewModel.name.isEmpty)
                    .simultaneousGesture(
                        TapGesture().onEnded {
                            if !userViewModel.name.isEmpty {
                                let success = userViewModel.saveUserName()
                                if !success {
                                    log(.error, userViewModel.saveError ?? "Unknown error")
                                }
                            } else {
                                withAnimation {
                                    showError = true
                                }
                            }

                            // Button press animation
                            continueButtonPressed = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                continueButtonPressed = false
                            }
                        }
                    )
                }
                .padding(.top, 60)
            }
            .navigationDestination(for: FitTrackDestination.self) { destination in
                switch destination {
                case .currentStats:
                    CurrentStatsView()
                        .environmentObject(userViewModel)
                case .routineCreator:
                    ExercisesListView()
                }
            }
        }
    }
}


enum FitTrackDestination: String, Hashable {
    case currentStats // Destination for the Current Stats view
    case routineCreator // Destination for the Routine Creator view
}


// Preview provider to display StartingView in Xcode's canvas
struct StartingView_Previews: PreviewProvider {
    static var previews: some View {
        StartingView()
            .environmentObject(UserViewModel()) // Provide the required environment object
    }
}
