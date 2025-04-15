//
//  Calendar.swift
//  FitTrack
//
//  Created by Joseph Chica on 1/21/25.
//

import SwiftUI

struct CalendarView: View {
    @State private var currentDate = Date()
    @ObservedObject var routineViewModel: RoutineViewModel

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
        VStack(spacing: 0) {
            header
                .padding(.bottom, 25)
            daysOfWeekHeader
                .padding(.bottom, 25)
            calendarGrid
                .padding(.bottom, 120)
        }
        .padding([.leading, .trailing, .top], 12)
    }

    private var header: some View {
        VStack {
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
            Button("Today") {
                withAnimation(.easeInOut) {
                    currentDate = Date()
                }
            }
            .font(.caption)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(AppColors.gray.opacity(0.2))
            .cornerRadius(6)
        }
        
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
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 16) {
            // Empty slots for the first week offset
            ForEach(0..<firstDayOfWeekOffset, id: \.self) { _ in
                Color.clear
                    .frame(height: 75)
            }
            // Days of the current month
            ForEach(currentMonthDays, id: \.self) { date in
                let isToday = calendar.isDate(date, inSameDayAs: Date())
                let hasRoutine = hasRoutineForDate(date)
                
                Text("\(calendar.component(.day, from: date))")
                    .font(.subheadline)
                    .frame(maxWidth: .infinity, minHeight: 75)
                    .background(isToday ? AppColors.primary : AppColors.primary.opacity(0.2))
                    .foregroundColor(isToday ? .white : .primary)
                    .cornerRadius(8)
                    .shadow(color: isToday ? Color.black.opacity(0.3) : Color.clear, radius: 5)
                
                if hasRoutine {
                    Circle()
                        .fill(AppColors.night)
                        .frame(width: 6, height: 6)
                }
            }
        }
        .transition(.opacity)
        .animation(.easeInOut, value: currentDate)
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
    
    private func getWeekdayIndex(from date: Date) -> Int {
        return calendar.component(.weekday, from: date)
    }
    
    private func hasRoutineForDate(_ date: Date) -> Bool {
        let weekdayIndex = getWeekdayIndex(from: date)
        return !routineViewModel.getRoutinesForDay(day: weekdayIndex).isEmpty
    }
}

struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView(routineViewModel: RoutineViewModel())
    }
}
