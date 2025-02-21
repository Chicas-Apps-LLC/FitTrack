//
//  Calendar.swift
//  FitTrack
//
//  Created by Joseph Chica on 1/21/25.
//

import SwiftUI

struct CalendarView: View {
    @State private var currentDate = Date()

    private var calendar: Calendar {
        Calendar.current
    }

    private var daysOfWeek: [String] {
        calendar.shortWeekdaySymbols
    }

    private var currentMonthDays: [Date] {
        let range = calendar.range(of: .day, in: .month, for: currentDate)!
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentDate))!
        return range.compactMap { day -> Date? in
            calendar.date(byAdding: .day, value: day - 1, to: startOfMonth)
        }
    }

    private var firstDayOfWeekOffset: Int {
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentDate))!
        return (calendar.component(.weekday, from: startOfMonth) + 6) % 7
    }

    var body: some View {
        VStack {
            header
            daysOfWeekHeader
            calendarGrid
        }
        .padding()
    }

    private var header: some View {
        HStack {
            Button(action: {
                changeMonth(by: -1)
            }) {
                Image(systemName: "chevron.left")
            }
            Spacer()
            Text(monthYearString(from: currentDate))
                .font(.headline)
            Spacer()
            Button(action: {
                changeMonth(by: 1)
            }) {
                Image(systemName: "chevron.right")
            }
        }
        .padding()
    }

    private var daysOfWeekHeader: some View {
        HStack {
            ForEach(daysOfWeek, id: \..self) { day in
                Text(day)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private var calendarGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
            // Empty slots for the first week offset
            ForEach(0..<firstDayOfWeekOffset, id: \..self) { _ in
                Color.clear
                    .frame(height: 40)
            }
            // Days of the current month
            ForEach(currentMonthDays, id: \..self) { date in
                Text("\(calendar.component(.day, from: date))")
                    .font(.subheadline)
                    .frame(maxWidth: .infinity, minHeight: 40)
                    .background(AppColors.primary.opacity(0.2))
                    .cornerRadius(8)
            }
        }
    }

    private func changeMonth(by value: Int) {
        if let newDate = calendar.date(byAdding: .month, value: value, to: currentDate) {
            currentDate = newDate
        }
    }

    private func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
}

struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView()
    }
}

