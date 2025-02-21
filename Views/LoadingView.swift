//
//  LoadingView.swift
//  FitTrack
//
//  Created by Joseph Chica on 1/1/25.
//

import SwiftUI

struct LoadingView: View {
    @EnvironmentObject var viewModel: RoutineViewModel
    @State private var progress = 0.0
    @State private var isNavigationActive = false
    let duration = 5.0
    
    var body: some View {
        Text("Loading")
    }
    
    private func startProgressBarAnimation() {
        withAnimation(.linear(duration: duration)) {
            progress = 1.0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            if viewModel.routines.isEmpty {
                print("Data not ready. Check createAndSaveGeneralRoutine().")
            } else {
                isNavigationActive = true
            }
        }
    }
}


struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        // Initialize the RoutineViewModel for the preview
        LoadingView()
            .environmentObject(RoutineViewModel())
    }
}
