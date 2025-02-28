//
//  DatabaseManagerHelper.swift
//  FitTrack
//
//  Created by Joseph Chica on 12/18/24.
//
import Foundation
import SQLite3

class DatabaseManagerHelper {
    static let shared = DatabaseManagerHelper()

    private init() {}

    func getOptionalString(_ statement: OpaquePointer?, columnIndex: Int) -> String? {
        if let cString = sqlite3_column_text(statement, Int32(columnIndex)) {
            return String(cString: cString)
        }
        return nil
    }

    func getOptionalInt(_ statement: OpaquePointer?, columnIndex: Int) -> Int? {
        if sqlite3_column_type(statement, Int32(columnIndex)) == SQLITE_NULL {
            return nil
        }
        return Int(sqlite3_column_int(statement, Int32(columnIndex)))
    }

    func getOptionalBool(_ statement: OpaquePointer?, columnIndex: Int) -> Bool? {
        let value = sqlite3_column_int(statement, Int32(columnIndex))
        return value == 0 ? nil : (value != 0)
    }
    
    func getOptionalDouble(_ statement: OpaquePointer?, columnIndex: Int) -> Double? {
        if sqlite3_column_type(statement, Int32(columnIndex)) == SQLITE_NULL {
            return nil
        }
        return sqlite3_column_double(statement, Int32(columnIndex))
    }
    
    func filterExercises(_ exercises: [ExerciseDto], _ num: Int) -> [ExerciseDto] {
        var filteredExercises = [ExerciseDto]()
        let randomIndex = Int.random(in: 0..<exercises.count)
        filteredExercises.append(exercises[randomIndex])
        return filteredExercises
    }
    
    func dateFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss" // Match your database format
        formatter.timeZone = TimeZone.current
        return formatter
    }
}


