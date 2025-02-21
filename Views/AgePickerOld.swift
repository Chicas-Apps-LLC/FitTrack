//
//  AgePicker.swift
//  FitTrack
//
//  Created by Joseph Chica on 12/28/24.
//

import SwiftUI

struct AgePickerOld: View {
    @Binding var selectedAge: Int
    @Binding var showAgePicker: Bool

    var body: some View {
        ZStack {
            // Semi-transparent background to dim the view
            Color.black.opacity(0.0)
                .ignoresSafeArea()
                .onTapGesture {
                    showAgePicker = false // Closes the picker on tap
                }

            VStack {
                Picker("Age", selection: $selectedAge) {
                    ForEach(13...100, id: \.self) { age in
                        Text("\(age)").tag(age)
                    }
                }
                .labelsHidden()
                .frame(width: 200) // Adjusts picker width
                .background(Color.white)
                .cornerRadius(12)

                Button("Done") {
                    showAgePicker = false // Confirms selection and hides picker
                }
                .padding()
            }
        }
    }
}
