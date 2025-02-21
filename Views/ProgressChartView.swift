//
//  ProgressChartView.swift
//  FitTrack
//
//  Created by Joseph Chica on 1/13/25.
//

import SwiftUI
import Charts

struct ProgressChartView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Progress Charts")
                    .font(.largeTitle)
                    .bold()

                LineGraphView()
                GymAttendanceChartView()
                ExerciseProgressChartView()
                BodyMeasurementChartView()
                GoalAchievementChartView()
            }
            .padding()
        }
    }
}

struct LineGraphView: View {
    let data = [
        ("Week 1", 175.0),
        ("Week 2", 174.5),
        ("Week 3", 173.5),
        ("Week 4", 172.0)
    ]

    var body: some View {
        Chart {
            ForEach(data, id: \.0) { week, weight in
                LineMark(
                    x: .value("Week", week),
                    y: .value("Weight", weight)
                )
            }
        }
        .chartYScale(domain: 165...180)
        .frame(height: 200)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}

struct GymAttendanceChartView: View {
    let data = [
        ("Mon", 60), ("Tue", 90), ("Wed", 0), ("Thu", 120), ("Fri", 45), ("Sat", 0), ("Sun", 75)
    ]

    var body: some View {
        Chart {
            ForEach(data, id: \.0) { day, minutes in
                BarMark(
                    x: .value("Day", day),
                    y: .value("Minutes", minutes)
                )
            }
        }
        .chartYScale(domain: 0...180) // Sets the y-axis range from 0 to 180 minutes
        .frame(height: 200)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}

struct ExerciseProgressChartView: View {
    // Progression data for squats (weight lifted each week)
    let data = [
        ("Week 1", 100),
        ("Week 2", 120),
        ("Week 3", 140),
        ("Week 4", 160)
    ]

    var body: some View {
        Chart {
            ForEach(data, id: \.0) { week, weight in
                BarMark(
                    x: .value("Week", week),
                    y: .value("Weight", weight)
                )
            }
        }
        .chartYScale(domain: 100...200) // Sets the y-axis range to handle weight progression
        .frame(height: 200)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}


struct BodyMeasurementChartView: View {
    let data = [
        ("Jan", 35.0), ("Feb", 34.8), ("Mar", 34.5), ("Apr", 34.0)
    ]

    var body: some View {
        Chart {
            ForEach(data, id: \.0) { month, measurement in
                LineMark(
                    x: .value("Month", month),
                    y: .value("Measurement", measurement)
                )
            }
        }
        .frame(height: 200)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}

struct GoalAchievementChartView: View {
    let data = [
        ("Weight Goal", 0.75),
        ("Exercise Goal", 0.9),
        ("Gym Attendance Goal", 0.85)
    ]

    var body: some View {
        Chart {
            ForEach(data, id: \.0) { goal, progress in
                BarMark(
                    x: .value("Goal", goal),
                    y: .value("Progress", progress * 100)
                )
            }
        }
        .frame(height: 200)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}

#Preview {
    ProgressChartView()
}
