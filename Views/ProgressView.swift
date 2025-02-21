//
//  ProgressView.swift
//  FitTrack
//
//  Created by Joseph Chica on 1/13/25.
//

import SwiftUI
import Charts

import SwiftUI
import Charts // Add this if you are using the Charts framework for graphing

struct ProgressView: View {
    @EnvironmentObject var userViewModel: UserViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Title
                    Text("Your Progress so far:")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.horizontal)

                    // Charts Section
                    Text("Progress Over Time")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.horizontal)

                    // Photo Section
                    Text("Progress Photos")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.horizontal)

                    VStack {
                        // Upload Button
                        Button(action: {
                            // Handle photo upload
                        }) {
                            Text("Upload New Photo")
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(AppColors.primary)
                                .cornerRadius(8)
                        }
                        .padding(.horizontal)
                    }

                    Spacer()
                }
            }
            .navigationTitle("Progress")
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [AppColors.light.opacity(0.5), AppColors.secondary.opacity(0.2)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
        }
    }
}

#Preview {
    ProgressView()
        .environmentObject(UserViewModel())
}
