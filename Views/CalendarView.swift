//
//  Calendar.swift
//  FitTrack
//
//  Created by Joseph Chica on 1/21/25.
//

import SwiftUI

struct CalendarView: View {
    @State private var currentDate = Date()
    @State private var showAddRoutineMenu = false
    @State private var selectedDate: Date? = nil
    @State private var navigateToExerciseList = false
    @State private var showRoutines = false
    @State private var selectedRoutine: RoutineDto? = nil
    @State private var monthSlideOffset: CGFloat = 0

    
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
            daysOfWeekHeader
                .padding(.top, 25)
            calendarGrid
                .padding(.top, 20)
                .padding(.bottom, 60)
            addRoutineButton
                .padding(.bottom, 10)
            
            
        }
        .onAppear {
            if selectedDate == nil {
                selectedDate = Date()
            }
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
                    .offset(x: monthSlideOffset)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                monthSlideOffset = value.translation.width
                            }
                            .onEnded { value in
                                if value.translation.width < -50 {
                                    withAnimation(.spring()) {
                                        monthSlideOffset = -100
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        changeMonth(by: 1)
                                        withAnimation(.spring()) {
                                            monthSlideOffset = 0
                                        }
                                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                    }
                                } else if value.translation.width > 50 {
                                    withAnimation(.spring()) {
                                        monthSlideOffset = 100
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        changeMonth(by: -1)
                                        withAnimation(.spring()) {
                                            monthSlideOffset = 0
                                        }
                                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                    }
                                } else {
                                    // Snap back if not enough swipe
                                    withAnimation(.spring()) {
                                        monthSlideOffset = 0
                                    }
                                }
                            }
                    )
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
                let isSelected = selectedDate != nil && calendar.isDate(date, inSameDayAs: selectedDate!)
                let hasRoutine = hasRoutineForDate(date)
                
                Button(action: {
                    selectedDate = date
                }) {
                    VStack(spacing: 4) {
                        Text("\(calendar.component(.day, from: date))")
                            .font(.subheadline)
                            .foregroundColor(isSelected ? .white : .primary)
                        
                        if hasRoutine {
                            Circle()
                                .fill(AppColors.night)
                                .frame(width: 6, height: 6)
                        } else {
                            // Reserve space to keep all cards same height
                            Spacer().frame(height: 6)
                        }
                    }
                    .frame(maxWidth: .infinity, minHeight: 75)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(isSelected ? AppColors.primary : AppColors.primary.opacity(0.2))
                    )
                }
                .buttonStyle(PlainButtonStyle())
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
    
    private func getWeekdayIndex(from date: Date) -> Int {
        return calendar.component(.weekday, from: date)
    }
    
    private func hasRoutineForDate(_ date: Date) -> Bool {
        let weekdayIndex = getWeekdayIndex(from: date)
        return !routineViewModel.getRoutinesForDay(day: weekdayIndex).isEmpty
    }
    
    private var addRoutineButton: some View {
        ZStack {
            NavigationLink(
                destination: ExercisesListView(selectedDate: selectedDate),
                isActive: $navigateToExerciseList
            ) {
                EmptyView()
            }

            Button(action: {
                showAddRoutineMenu = true
            }) {
                HStack {
                    Image(systemName: "plus")
                    Text("Add Routine To Day")
                }
                .font(.subheadline)
                .foregroundColor(.white)
                .padding(.vertical, 18)
                .frame(maxWidth: .infinity)
                .background(AppColors.primary)
                .cornerRadius(10)
                .shadow(color: AppColors.primary.opacity(0.3), radius: 5, x: 0, y: 2)
            }
            .frame(width: UIScreen.main.bounds.width * 0.40)
            .confirmationDialog("Add Routine", isPresented: $showAddRoutineMenu, titleVisibility: .visible) {
                Button("Create New Routine") {
                    navigateToExerciseList = true
                }
                Button("Select Existing Routine") {
                    showRoutines = true
                }
                Button("Cancel", role: .cancel) {}
            }
        }
        .sheet(isPresented: $showRoutines) {
            RoutinePickerView(
                routines: routineViewModel.routines,
                onSelect: { routine in
                    selectedRoutine = routine
                    routineViewModel.assignRoutineToDay(routine: routine, date: selectedDate!)
                    showRoutines = false
                }
            )
        }
    }
}

struct RoutinePickerView: View {
    let routines: [RoutineDto]
    let onSelect: (RoutineDto) -> Void

    var body: some View {
        NavigationView {
            List(routines, id: \.id) { routine in
                Button(action: {
                    onSelect(routine)
                }) {
                    VStack(alignment: .leading) {
                        Text(routine.name).font(.headline)
                        if let desc = routine.description {
                            Text(desc).font(.subheadline).foregroundColor(.gray)
                        }
                    }
                }
            }
            .navigationTitle("Select a Routine")
        }
    }
}


struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView(routineViewModel: RoutineViewModel())
    }
}
