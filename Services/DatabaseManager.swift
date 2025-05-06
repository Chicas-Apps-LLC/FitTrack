//
//  RoutineManager.swift
//  FitTrack
//
//  Created by Joseph Chica on 10/22/24.
//

import Foundation
import SQLite3
import Logging


class DatabaseManager {
    static let shared = DatabaseManager()
    private let dbQueue = DispatchQueue(label: "com.fittrack.databaseQueue")
    private(set) var db: OpaquePointer? = nil
    var isDatabaseOpen = false
    let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
    
    init() {}
    
    func performDatabaseTask<T>(_ task: () -> T) -> T {
        return dbQueue.sync {
            return task()
        }
    }
    
    func openDatabase() {
        guard !isDatabaseOpen else {
            log(.warning, "Database is already open.")
            return
        }

        // Path to the Documents directory
        let fileManager = FileManager.default
        let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let databasePath = documentDirectory.appendingPathComponent("FitTrack.db")

        // Check if the database already exists in Documents
        if !fileManager.fileExists(atPath: databasePath.path) {
            // If not, copy it from the bundle
            guard let bundleURL = Bundle.main.url(forResource: "FitTrack", withExtension: "db") else {
                log(.error, "Database file not found in bundle.")
                return
            }

            do {
                try fileManager.copyItem(at: bundleURL, to: databasePath)
                log(.info, "Database copied to Documents directory.")
            } catch {
                log(.error, "Error copying database: \(error.localizedDescription)")
                return
            }
        }

        // Open the database from the Documents directory
        if sqlite3_open(databasePath.path, &db) == SQLITE_OK {
            isDatabaseOpen = true
        } else {
            log(.error, "Error opening database.")
            db = nil
        }
        log(.info, "Database path: \(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("FitTrack.db").path)")
    }

    func closeDatabase() {
        guard isDatabaseOpen else {
            log(.warning, "Database is already closed.")
            return
        }
        
        if sqlite3_close(db) == SQLITE_OK {
            log(.info, "Successfully closed database.")
            isDatabaseOpen = false
            db = nil
        } else {
            log(.error, "Failed to close database.")
        }
    }
    
    func createMainLiftOne(user: UserDto) -> RoutineDto {
        let categoriesWithLimits: [(fetch: () -> [ExerciseDto], limit: Int)] = [
            ({ self.getExercisesWithKeyword("slam") }, 1),
            ({ self.getExercisesWithKeyword("jump") }, 1),
            ({ self.getExercisesByName("Squat") }, 1),
            ({ self.getExercisesByType("0") }, 1),
            ({ self.getExercisesByMuscle("10") }, 1)
        ]

        return createRoutine(
            routineID: 100,
            name: "Generated Routine 1",
            description: "First routine for your first day at the gym!",
            categoriesWithLimits: categoriesWithLimits,
            user: user
        )
    }
    
    func createMainLiftTwo(user: UserDto) -> RoutineDto {
        let categoriesWithLimits: [(fetch: () -> [ExerciseDto], limit: Int)] = [
            ({ self.getExercisesWithKeyword("row") }, 1),
            ({ self.getExercisesWithKeyword("pull") }, 1),
            ({ self.getExercisesWithKeyword("hinge") }, 1),
            ({ self.getExercisesWithKeyword("lunge") }, 1),
            ({ self.getExercisesWithKeyword("push") }, 1)
        ]

        return createRoutine(
            routineID: 200,
            name: "Generated Routine 2",
            description: "Now that you know what we are trying to do, hit this one a little harder!",
            categoriesWithLimits: categoriesWithLimits,
            user: user
        )
    }
    
    func createMainLiftThree(user: UserDto) -> RoutineDto {
        let categoriesWithLimits: [(fetch: () -> [ExerciseDto], limit: Int)] = [
            ({ self.getExercisesWithKeyword("Swing") }, 1),
            ({ self.getExercisesWithKeyword("hinge") }, 1),
            ({ self.getExercisesWithKeyword("pull") }, 1),
            ({ self.getExercisesWithKeyword("push") }, 1),
            ({ self.getExercisesWithKeyword("lunge") }, 1),
            ({ self.getExercisesByMuscle("10") }, 1)
        ]

        return createRoutine(
            routineID: 300,
            name: "Generated Routine 3",
            description: "Now that you know what we are trying to do, hit this one a little harder!",
            categoriesWithLimits: categoriesWithLimits,
            user: user
        )
    }

    func createGeneratedRoutine(name: String, user: UserDto) -> RoutineDto {
        let categoriesWithLimits: [(fetch: () -> [ExerciseDto], limit: Int)] = [
            ({ self.getExercisesWithKeyword("push") }, 1),
            ({ self.getExercisesWithKeyword("back") }, 1),
            ({ self.getExercisesWithKeyword("pull") }, 1),
            ({ self.getExercisesWithKeyword("squat") }, 1),
            ({ self.getExercisesWithKeyword("lunge") }, 1),
            ({ self.getExercisesByMuscle("10") }, 1)
        ]
        return createRoutine(
            routineID: 0,
            name: name,
            description: "Now that you know what we are trying to do, hit this one a little harder!",
            categoriesWithLimits: categoriesWithLimits,
            user: user
        )
    }
    
    func createRoutine(
        routineID: Int,
        name: String,
        description: String,
        categoriesWithLimits: [(fetch: () -> [ExerciseDto], limit: Int)],
        user: UserDto
    ) -> RoutineDto {
        let helper = DatabaseManagerHelper.shared

        var exercisesWithSets: [ExerciseWithSetsDto] = []
        var uniqueExerciseIDs = Set<Int>()

        for (fetchExercises, limit) in categoriesWithLimits {
            var categoryExercises = fetchExercises()
            log(.info, "\(categoryExercises.count) exercises fetched for category.")

            // Filter exercises based on limit
            if categoryExercises.count > limit {
                categoryExercises = helper.filterExercises(categoryExercises, limit)
            }

            for exercise in categoryExercises {
                // If the exercise is a duplicate, attempt to fetch a replacement
                if uniqueExerciseIDs.contains(exercise.id) {
                    log(.warning, "Duplicate exercise detected: \(exercise.name). Fetching a replacement...")
                    if let replacement = fetchReplacementExercise(exclude: uniqueExerciseIDs) {
                        let setsReps = createSetsRepsAndWeight(user: user) ?? []
                        let exerciseWithSets = ExerciseWithSetsDto(exercise: replacement, sets: setsReps)
                        exercisesWithSets.append(exerciseWithSets)
                        uniqueExerciseIDs.insert(replacement.id)
                    }
                } else {
                    let setsReps = createSetsRepsAndWeight(user: user) ?? []
                    let exerciseWithSets = ExerciseWithSetsDto(exercise: exercise, sets: setsReps)
                    exercisesWithSets.append(exerciseWithSets)
                    uniqueExerciseIDs.insert(exercise.id)
                }
            }
        }
        log(.info, "Final exercise list size: \(exercisesWithSets.count)")

        return RoutineDto(
            id: routineID,
            name: name,
            description: description,
            exerciseWithSetsDto: exercisesWithSets
        )
    }
    
    func saveExerciseSet(routineHistory: RoutineHistoryDto, exercise: ExerciseDto, set: SetsDto) -> Bool {
        return performDatabaseTask {
            openDatabase()
            let query = """
            INSERT INTO ExerciseHistory (exercise_id, routine_id, routine_history_id, date, reps, weight) 
            VALUES (?, ?, ?, ?, ?, ?)
            """
            
            let dm = DatabaseManager.shared.db
            var statement: OpaquePointer?
            
            // Safely unwrap optional values
            guard let routineId = routineHistory.routineId, let sessionId = routineHistory.id else {
                log(.error, "Routine ID or Session ID is nil")
                return false
            }
            
            // Start a transaction
            guard sqlite3_exec(dm, "BEGIN TRANSACTION", nil, nil, nil) == SQLITE_OK else {
                let errorMessage = String(cString: sqlite3_errmsg(dm))
                log(.error, "Failed to begin transaction: \(errorMessage)")
                return false
            }
            
            defer {
                if statement != nil {
                    sqlite3_finalize(statement)
                }
            }
            
            guard sqlite3_prepare_v2(dm, query, -1, &statement, nil) == SQLITE_OK else {
                let errorMessage = String(cString: sqlite3_errmsg(dm))
                log(.error, "Failed to prepare insert statement: \(errorMessage)")
                return false
            }
            
            // Bind values to the query
            sqlite3_bind_int(statement, 1, Int32(exercise.id))
            sqlite3_bind_int(statement, 2, Int32(routineId))
            sqlite3_bind_int(statement, 3, Int32(sessionId))
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let dateString = dateFormatter.string(from: Date())
            sqlite3_bind_text(statement, 4, dateString, -1, nil)
            
            sqlite3_bind_int(statement, 5, Int32(set.reps))
            sqlite3_bind_double(statement, 6, set.weight)
            
            // Execute the statement
            if sqlite3_step(statement) != SQLITE_DONE {
                let errorMessage = String(cString: sqlite3_errmsg(dm))
                log(.error, "Failed to insert exercise set: \(errorMessage)")
                sqlite3_exec(dm, "ROLLBACK", nil, nil, nil)
                return false
            }
            
            // Commit transaction if successful
            guard sqlite3_exec(dm, "COMMIT", nil, nil, nil) == SQLITE_OK else {
                let errorMessage = String(cString: sqlite3_errmsg(dm))
                log(.error, "Failed to commit transaction: \(errorMessage)")
                sqlite3_exec(dm, "ROLLBACK", nil, nil, nil)
                return false
            }
            
            log(.info, "Successfully saved exercise set for exercise_id: \(exercise.id)")
            return true
        }
    }

    // Function to fetch a replacement exercise that excludes existing IDs
    func fetchReplacementExercise(exclude existingIDs: Set<Int>) -> ExerciseDto? {
        let query = """
        SELECT exercise_id, name, description, level, instructions
        FROM Exercises
        WHERE exercise_id NOT IN (\(existingIDs.map { String($0) }.joined(separator: ",")))
        LIMIT 1;
        """
        let replacements = getExercises(query: query) { _ in }
        return replacements.first
    }

    
    func getExercisesByMuscle(_ muscle: String) -> [ExerciseDto] {
        let query = """
        SELECT ex.exercise_id, ex.name, ex.description, ex.level, ex.instructions
        FROM Exercises ex
        JOIN ExercisesMuscles em ON ex.exercise_id = em.exercise_id
        WHERE em.muscle_id = ?;
        """
        return getExercises(query: query) { statement in
            sqlite3_bind_text(statement, 1, muscle, -1, unsafeBitCast(-1, to: sqlite3_destructor_type.self))
        }
    }


    func getExercisesByType(_ type: String) -> [ExerciseDto] {
        let query = """
        SELECT exercise_id, name, description, level, instructions
        FROM Exercises
        WHERE equipment_needed = ?
        LIMIT 50;
        """
        return getExercises(query: query) { statement in
            sqlite3_bind_text(statement, 1, type, -1, unsafeBitCast(-1, to: sqlite3_destructor_type.self))
        }
    }

    func getExercisesByName(_ name: String) -> [ExerciseDto] {
        let query = """
        SELECT exercise_id, name, description, level, instructions
        FROM Exercises
        WHERE name LIKE ? COLLATE NOCASE;
        """
        return getExercises(query: query) { statement in
            let keyword = "%\(name)%"  // Adding wildcards for partial matching
            sqlite3_bind_text(statement, 1, keyword, -1, unsafeBitCast(-1, to: sqlite3_destructor_type.self))        }
    }
    
    func getExercisesWithKeyword(_ keyword: String) -> [ExerciseDto] {
        let query = """
        SELECT exercise_id, name, description, level, instructions 
        FROM Exercises 
        WHERE name LIKE ? 
        OR description LIKE ?;
        """
        return getExercises(query: query) { statement in
            let keywordWithWildcard = "%\(keyword)%"
            sqlite3_bind_text(statement, 1, keywordWithWildcard, -1, unsafeBitCast(-1, to: sqlite3_destructor_type.self)) // Bind first parameter
            sqlite3_bind_text(statement, 2, keywordWithWildcard, -1, unsafeBitCast(-1, to: sqlite3_destructor_type.self)) // Bind second parameter
        }
    }
    
    func getAllExercisesNames() -> [String] {
        return performDatabaseTask {
            openDatabase()
            
            var exercises = [String]()
            let query = "SELECT name FROM Exercises;"
            var statement: OpaquePointer?
            
            if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
                while sqlite3_step(statement) == SQLITE_ROW {
                    if let namePtr = sqlite3_column_text(statement, 0) {
                        let name = String(cString: namePtr)
                        exercises.append(name)
                    }
                }
            } else {
                let errorMessage = String(cString: sqlite3_errmsg(db))
                log(.error, "Error preparing statement: \(errorMessage)")
            }
            
            sqlite3_finalize(statement)
            closeDatabase()
            
            return exercises
        }
    }
    
    func getExercises(query: String, bindings: (OpaquePointer?) -> Void) -> [ExerciseDto] {
        return performDatabaseTask {
            openDatabase()
            var exercises = [ExerciseDto]()
            var statement: OpaquePointer?
                    
            // Prepare the statement
            let prepareResult = sqlite3_prepare_v2(db, query, -1, &statement, nil)
            if prepareResult != SQLITE_OK {
                log(.error, "Error preparing statement: \(String(cString: sqlite3_errmsg(db)))")
                return []
            }
            
            defer { sqlite3_finalize(statement) } // Ensure the statement is finalized
            
            // Apply bindings
            bindings(statement)
            log(.debug, "Bindings applied successfully.")
            
            // Execute the query
            while sqlite3_step(statement) == SQLITE_ROW {
                // Safely extract column data
                let id = Int(sqlite3_column_int(statement, 0))
                let name = sqlite3_column_text(statement, 1).flatMap { String(cString: $0) } ?? "Unknown"
                let description = sqlite3_column_text(statement, 2).flatMap { String(cString: $0) }
                let level = sqlite3_column_text(statement, 3).flatMap { String(cString: $0) }
                let instructions = sqlite3_column_text(statement, 4).flatMap { String(cString: $0) }
                
                // Create the ExerciseDto
                let exercise = ExerciseDto(
                    id: id,
                    name: name,
                    description: description,
                    level: level,
                    instructions: instructions,
                    equipmentNeeded: nil,
                    overloading: nil,
                    powerStrengthSupplement: nil,
                    isolationCompoundAccessory: nil,
                    pushPullLegs: nil,
                    verticalHorizontalRotational: nil,
                    stretch: nil,
                    videoURL: nil
                )
                exercises.append(exercise)
            }
            
            if exercises.isEmpty {
                log(.warning, "No exercises found for query: \(query)")
            } else {
                log(.info, "Exercises count: \(exercises.count)")
            }
            return exercises
        }
    }
    
    func getExerciseDetailsByName(forName name: String) -> ExerciseDto {
        return performDatabaseTask{
            openDatabase()
            let helper = DatabaseManagerHelper.shared
            var exercise: ExerciseDto?
            let query = "SELECT * FROM Exercises WHERE name = ?;"
            var statement: OpaquePointer?

            if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
                sqlite3_bind_text(statement, 1, (name as NSString).utf8String, -1, nil)
                while sqlite3_step(statement) == SQLITE_ROW {
                    let id = Int(sqlite3_column_int(statement, 0))
                    let name = String(cString: sqlite3_column_text(statement, 1))

                    let description = helper.getOptionalString(statement, columnIndex: 2)
                    let level = helper.getOptionalString(statement, columnIndex: 3)
                    let instructions = helper.getOptionalString(statement, columnIndex: 4)
                    let equipmentNeeded = sqlite3_column_int(statement, 5) == 1
                    let overloading = sqlite3_column_int(statement, 6) == 1
                    let powerStrengthSupplement = helper.getOptionalString(statement, columnIndex: 7)
                    let isolationCompoundAccessory = helper.getOptionalString(statement, columnIndex: 8)
                    let pushPullLegs = helper.getOptionalString(statement, columnIndex: 9)
                    let verticalHorizontalRotational = helper.getOptionalString(statement, columnIndex: 10)
                    let stretch = sqlite3_column_int(statement, 11) == 1
                    let videoURL = helper.getOptionalString(statement, columnIndex: 12)

                    exercise = ExerciseDto(
                        id: id,
                        name: name,
                        description: description,
                        level: level,
                        instructions: instructions,
                        equipmentNeeded: equipmentNeeded,
                        overloading: overloading,
                        powerStrengthSupplement: powerStrengthSupplement,
                        isolationCompoundAccessory: isolationCompoundAccessory,
                        pushPullLegs: pushPullLegs,
                        verticalHorizontalRotational: verticalHorizontalRotational,
                        stretch: stretch,
                        videoURL: videoURL
                    )
                }
            } else {
                let errorMessage = String(cString: sqlite3_errmsg(db))
                log(.error, "Error preparing statement: \(errorMessage)")
            }
            
            sqlite3_finalize(statement)
            closeDatabase()

            return exercise ?? ExerciseDto(id: 999, name: "NA", description: "NA", level: nil, instructions: nil, equipmentNeeded: nil, overloading: nil, powerStrengthSupplement: nil, isolationCompoundAccessory: nil, pushPullLegs: nil, verticalHorizontalRotational: nil, stretch: nil, videoURL: nil)
        }
    }
    
    func getExercisesFromRoutine(routineId: Int) -> [ExerciseDto] {
        return performDatabaseTask {
            openDatabase()
            log(.info, "Fetching exercises for routine ID: \(routineId)")
            var exercises = [ExerciseDto]()
            
            let query = """
                SELECT Exercises.*
                FROM Exercises
                INNER JOIN RoutineExercises ON Exercises.exercise_id = RoutineExercises.exercise_id
                WHERE RoutineExercises.routine_id = ?;
            """
            
            var statement: OpaquePointer?
            
            // Prepare the SQL query
            if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
                // Bind the routine ID to the query
                sqlite3_bind_int(statement, 1, Int32(routineId))
                
                // Iterate over the results
                while sqlite3_step(statement) == SQLITE_ROW {
                    let id = Int(sqlite3_column_int(statement, 0))
                    let name = sqlite3_column_text(statement, 1).flatMap { String(cString: $0) } ?? "Unknown Exercise"
                    let description = sqlite3_column_text(statement, 2).flatMap { String(cString: $0) }
                    let level = sqlite3_column_text(statement, 3).flatMap { String(cString: $0) } ?? "Unknown"
                    let instructions = sqlite3_column_text(statement, 4).flatMap { String(cString: $0) }
                    let equipmentNeeded = sqlite3_column_int(statement, 5) == 1
                    let overloading = sqlite3_column_int(statement, 6) == 1
                    let powerStrengthSupplement = sqlite3_column_text(statement, 7).flatMap { String(cString: $0) } ?? ""
                    let isolationCompoundAccessory = sqlite3_column_text(statement, 8).flatMap { String(cString: $0) } ?? ""
                    let pushPullLegs = sqlite3_column_text(statement, 9).flatMap { String(cString: $0) } ?? ""
                    let verticalHorizontalRotational = sqlite3_column_text(statement, 10).flatMap { String(cString: $0) } ?? ""
                    let stretch = sqlite3_column_int(statement, 11) == 1
                    let videoURL = sqlite3_column_text(statement, 12).flatMap { String(cString: $0) }
                    
                    // Create an ExerciseDto object and add it to the array
                    let exercise = ExerciseDto(
                        id: id,
                        name: name,
                        description: description,
                        level: level,
                        instructions: instructions,
                        equipmentNeeded: equipmentNeeded,
                        overloading: overloading,
                        powerStrengthSupplement: powerStrengthSupplement,
                        isolationCompoundAccessory: isolationCompoundAccessory,
                        pushPullLegs: pushPullLegs,
                        verticalHorizontalRotational: verticalHorizontalRotational,
                        stretch: stretch,
                        videoURL: videoURL
                    )
                    exercises.append(exercise)
                }
            } else {
                let errorMessage = String(cString: sqlite3_errmsg(db))
                log(.error, "Failed to fetch exercises for routine: \(errorMessage)")
            }
            
            sqlite3_finalize(statement)
            log(.info, "Fetched \(exercises.count) exercises for routine ID: \(routineId)")
            return exercises
        }
    }
    
    func getExercisesWithSetsFromRoutine(routineId: Int) -> [ExerciseWithSetsDto] {
        let exercises = getExercisesFromRoutine(routineId: routineId)
        return performDatabaseTask {
            openDatabase()
            log(.info, "Getting exercises and sets from routine: \(routineId)")
            
            var exercisesWithSets = [ExerciseWithSetsDto]()
            
            for exercise in exercises {
                let sets = getSetsFromExercise(exerciseId: exercise.id)
                exercisesWithSets.append(ExerciseWithSetsDto(exercise: exercise, sets: sets))
            }
            
            log(.info, "Fetched \(exercisesWithSets.count) exercises with sets for routine ID: \(routineId)")
            return exercisesWithSets
        }
    }
    
    func getExerciseHistory(exerciseId: Int) -> [ExerciseHistoryDto] {
        return performDatabaseTask {
            openDatabase()
            log(.info, "Getting exercise history for exercise ID: \(exerciseId)")
            
            var exerciseHistoryDict: [Int: ExerciseHistoryDto] = [:]
            var statement: OpaquePointer?

            let query = """
            SELECT id, exercise_id, routine_id, routine_history_id, date, reps, weight, notes
            FROM ExerciseHistory
            WHERE exercise_id = ?
            ORDER BY date DESC;
            """

            let prepareResult = sqlite3_prepare_v2(db, query, -1, &statement, nil)
            if prepareResult != SQLITE_OK {
                log(.error, "Error preparing statement: \(String(cString: sqlite3_errmsg(db)))")
                return []
            }

            defer { sqlite3_finalize(statement) }

            sqlite3_bind_int(statement, 1, Int32(exerciseId))

            let formatter = ISO8601DateFormatter()

            while sqlite3_step(statement) == SQLITE_ROW {
                let id = Int(sqlite3_column_int(statement, 0))
                let routineId = Int(sqlite3_column_int(statement, 2))
                let routineSessionId = Int(sqlite3_column_int(statement, 3))

                var date: Date?
                if let dateText = sqlite3_column_text(statement, 4) {
                    let dateString = String(cString: dateText)
                    date = formatter.date(from: dateString)
                }

                let reps = Int(sqlite3_column_int(statement, 5))
                let weight = sqlite3_column_double(statement, 6)

                var notes: String? = nil
                if let notesText = sqlite3_column_text(statement, 7) {
                    notes = String(cString: notesText)
                }

                // Check if an entry for this exercise session already exists
                if var exerciseEntry = exerciseHistoryDict[id] {
                    // Add a new set to the existing session
                    let set = SetsDto(setNumber: exerciseEntry.sets.count + 1, reps: reps, weight: weight)
                    exerciseEntry.sets.append(set)
                    exerciseHistoryDict[id] = exerciseEntry
                } else {
                    // Create a new exercise session entry
                    let exerciseEntry = ExerciseHistoryDto(
                        id: id,
                        exerciseId: exerciseId,
                        routineId: routineId,
                        routineHistoryId: routineSessionId,
                        date: date ?? Date(),
                        sets: [SetsDto(setNumber: 1, reps: reps, weight: weight)], // First set
                        notes: notes
                    )
                    exerciseHistoryDict[id] = exerciseEntry
                }
            }

            let exerciseHistory = Array(exerciseHistoryDict.values)

            if exerciseHistory.isEmpty {
                log(.warning, "No exercise history found for exercise ID: \(exerciseId)")
            } else {
                log(.info, "Retrieved \(exerciseHistory.count) exercise history records.")
            }

            return exerciseHistory
        }
    }
    
    func saveRoutineWithExercisesToDb(_ routine: RoutineDto) -> Bool {
        return performDatabaseTask {
            openDatabase()
            let query = "INSERT INTO Routines (name, description) VALUES (?, ?);"
            let dm = DatabaseManager.shared.db
            var statement: OpaquePointer?

            // Begin transaction
            guard sqlite3_exec(dm, "BEGIN TRANSACTION", nil, nil, nil) == SQLITE_OK else {
                let errorMessage = String(cString: sqlite3_errmsg(dm))
                log(.error, "Failed to begin transaction: \(errorMessage)")
                return false
            }

            defer {
                if sqlite3_exec(dm, "ROLLBACK", nil, nil, nil) == SQLITE_OK {
                    log(.info, "Transaction rolled back due to an error.")
                }
            }

            guard sqlite3_prepare_v2(dm, query, -1, &statement, nil) == SQLITE_OK else {
                let errorMessage = String(cString: sqlite3_errmsg(dm))
                log(.error, "Failed to prepare routine insert statement: \(errorMessage)")
                return false
            }

            defer { sqlite3_finalize(statement) } // Finalize statement

            // Bind values
            sqlite3_bind_text(statement, 1, routine.name, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 2, routine.description ?? "", -1, SQLITE_TRANSIENT)

            guard sqlite3_step(statement) == SQLITE_DONE else {
                let errorMessage = String(cString: sqlite3_errmsg(dm))
                log(.error, "Failed to insert routine: \(errorMessage)")
                return false
            }

            let routineId = sqlite3_last_insert_rowid(dm)
            log(.info, "Routine inserted with ID: \(routineId)")

            // Insert exercises into RoutineExercises table
            if !_saveExercisesWithSetsToDb(exercisesWithSets: routine.exerciseWithSetsDto!, routineId: Int(routineId)) {
                log(.error, "Error saving exercises for routine \(routineId)")
            }

            // Commit transaction
            guard sqlite3_exec(dm, "COMMIT", nil, nil, nil) == SQLITE_OK else {
                let errorMessage = String(cString: sqlite3_errmsg(dm))
                log(.error, "Failed to commit transaction: \(errorMessage)")
                return false
            }

            log(.info, "Transaction committed successfully.")
            return true
        }
    }
    
    private func _saveExercisesWithSetsToDb(exercisesWithSets: [ExerciseWithSetsDto], routineId: Int) -> Bool {
        let dm = DatabaseManager.shared.db
        
        let insertExerciseQuery = "INSERT INTO RoutineExercises (routine_id, exercise_id) VALUES (?, ?);"
        let insertSetQuery = "INSERT INTO RoutineExerciseSets (routine_exercise_id, set_number, reps, weight) VALUES (?, ?, ?, ?);"
        
        for exerciseWithSets in exercisesWithSets {
            let exerciseId = exerciseWithSets.exercise.id
            var exerciseStatement: OpaquePointer?
            
            // Insert into RoutineExercises table
            guard sqlite3_prepare_v2(dm, insertExerciseQuery, -1, &exerciseStatement, nil) == SQLITE_OK else {
                let errorMessage = String(cString: sqlite3_errmsg(dm))
                log(.error, "Failed to prepare exercise insert statement: \(errorMessage)")
                return false
            }
            
            sqlite3_bind_int(exerciseStatement, 1, Int32(routineId))
            sqlite3_bind_int(exerciseStatement, 2, Int32(exerciseId))
            
            guard sqlite3_step(exerciseStatement) == SQLITE_DONE else {
                let errorMessage = String(cString: sqlite3_errmsg(dm))
                log(.error, "Failed to insert exercise into RoutineExercises: \(errorMessage)")
                sqlite3_finalize(exerciseStatement)
                return false
            }
            
            // Get last inserted ID for routine_exercise_id
            let routineExerciseId = sqlite3_last_insert_rowid(dm)
            log(.info, "Inserted Exercise ID: \(exerciseId) into RoutineExercises with ID: \(routineExerciseId).")
            
            // Finalize exerciseStatement before moving to sets
            sqlite3_finalize(exerciseStatement)
            
            // Insert sets into RoutineExerciseSets table
            for set in exerciseWithSets.sets {
                var setStatement: OpaquePointer?
                
                guard sqlite3_prepare_v2(dm, insertSetQuery, -1, &setStatement, nil) == SQLITE_OK else {
                    let errorMessage = String(cString: sqlite3_errmsg(dm))
                    log(.error, "Failed to prepare set insert statement: \(errorMessage)")
                    return false
                }
                
                sqlite3_bind_int(setStatement, 1, Int32(routineExerciseId))
                sqlite3_bind_int(setStatement, 2, Int32(set.setNumber))
                sqlite3_bind_int(setStatement, 3, Int32(set.reps))
                sqlite3_bind_double(setStatement, 4, set.weight)
                
                guard sqlite3_step(setStatement) == SQLITE_DONE else {
                    let errorMessage = String(cString: sqlite3_errmsg(dm))
                    log(.error, "Failed to insert set into RoutineExerciseSets: \(errorMessage)")
                    sqlite3_finalize(setStatement)
                    return false
                }
                
                log(.info, "Inserted Set: \(set.setNumber), Reps: \(set.reps), Weight: \(set.weight) for RoutineExercise ID: \(routineExerciseId).")
                
                // Finalize setStatement after each set
                sqlite3_finalize(setStatement)
            }
        }
        return true
    }

    func chooseAndCreateRoutines(user: UserDto) {
        let days = user.goals.goalGymDays
        var routines = [RoutineDto]()
        if let days = days {
            for _ in 0..<days {
                if user.currentStats.gymMembership != true {
                    log(.info, "No gym membership, creating bodyweight routines")
                    routines.append(createBodyWeightRoutines(user: user))
                }
                else {
                    log(.info, "Gym membership available, creating routines")
                    
                    if user.goals.goalExercise?.lowercased() == "cardio" {
                        log(.info, "Creating cardio routines")
                        routines = createCardioRoutines(user: user)
                        break;
                    }
                    else if user.goals.goalExercise?.lowercased() == "strength" {
                        log(.info, "Creating strength routines")
                        routines = createStrengthRoutines(user: user)
                        break;
                    }
                    else if user.goals.goalExercise?.lowercased() == "weight loss" {
                        log(.info, "Creating weight loss routines")
                        createWeightLossRoutines(user: user)
                        break;
                    }
                }
            }
        }
        for routine in routines {
            if saveRoutineWithExercisesToDb(routine) {
                log(.info, "Successfully saved routine: \(routine.name)")
            } else {
                log(.error, "Failed to save routine: \(routine.name)")
            }
        }
    }
    
    func createCardioRoutines(user: UserDto) -> [RoutineDto]{
        var routines = [RoutineDto]()
        routines.append(createMainLiftOne(user: user))
        routines.append(createMainLiftTwo(user: user))
        routines.append(createMainLiftThree(user: user))
        return routines
    }
    
    func createBodyWeightRoutines(user: UserDto) -> RoutineDto{
        let exercises = getExercisesByType("0")
        
        guard !exercises.isEmpty else {
            log(.warning, "No bodyweight exercises found.")
            return RoutineDto(id: 0, name: "Bodyweight Routine", description: "No exercises found", exerciseWithSetsDto: [])
        }
        let selectedExercises = exercises.count > 5 ? Array(exercises.shuffled().prefix(5)) : exercises
        
        var exercisesWithSets: [ExerciseWithSetsDto] = []
        for exercise in selectedExercises {
            let setsReps = createSetsRepsAndWeight(user: user) ?? []
            let exerciseWithSets = ExerciseWithSetsDto(exercise: exercise, sets: setsReps)
            exercisesWithSets.append(exerciseWithSets)
        }
        return RoutineDto(
            id: Int.random(in: 1000...9999),
            name: "Bodyweight Routine",
            description: "A bodyweight-only workout routine.",
            exerciseWithSetsDto: exercisesWithSets
        )
    }
    
    func createStrengthRoutines(user: UserDto) -> [RoutineDto] {
        // **CST Routine (Chest, Shoulders, Triceps)**
        let chestExercises = getExercisesByMuscle("1")
        let frontDeltExercises = getExercisesByMuscle("18") // Anterior Head
        let lateralDeltExercises = getExercisesByMuscle("19") // Lateral Head
        let rearDeltExercises = getExercisesByMuscle("20") // Posterior Head
        let tricepLateralExercises = getExercisesByMuscle("21")
        let tricepLongExercises = getExercisesByMuscle("22")
        let tricepMedialExercises = getExercisesByMuscle("23")

        // Ensure an incline chest exercise is included
        let inclineChest = chestExercises.first(where: { $0.name.lowercased().contains("incline") })
        var selectedChest = Array(chestExercises.prefix(3))
        if let incline = inclineChest {
            selectedChest = [incline] + selectedChest.filter { $0.id != incline.id }
        }

        // Select one exercise from each shoulder head
        let selectedShoulders = [
            frontDeltExercises.first,
            lateralDeltExercises.first,
            rearDeltExercises.first
        ].compactMap { $0 }

        // Select two tricep exercises
        let selectedTriceps = [
            tricepLateralExercises.first,
            tricepLongExercises.first
        ].compactMap { $0 }

        let cstExercises = selectedChest + selectedShoulders + selectedTriceps
        let cstRoutine = RoutineDto(
            id: 1,
            name: "Chest/Shoulders/Triceps",
            description: "Strength routine for CST",
            exerciseWithSetsDto: cstExercises.map { ExerciseWithSetsDto(exercise: $0, sets: createSetsRepsAndWeight(user: user) ?? []) }
        )

        // **QC Routine (Quads, Calves)**
        let quadExercises = getExercisesByMuscle("7")
        let calfExercises = getExercisesByMuscle("9")

        let selectedQuads = Array(quadExercises.prefix(3))
        let selectedCalves = Array(calfExercises.prefix(2))

        let qcExercises = selectedQuads + selectedCalves
        let qcRoutine = RoutineDto(
            id: 2,
            name: "Quads/Calves",
            description: "Strength routine for quads and calves",
            exerciseWithSetsDto: qcExercises.map { ExerciseWithSetsDto(exercise: $0, sets: createSetsRepsAndWeight(user: user) ?? []) }
        )

        // **BB Routine (Back, Biceps)**
        let backExercises = getExercisesByMuscle("2")
        let latExercises = getExercisesByMuscle("15")
        let rhomboidExercises = getExercisesByMuscle("14")
        let bicepExercises = getExercisesByMuscle("5")
        let brachialisExercises = getExercisesByMuscle("17")

        let selectedLats = Array(latExercises.prefix(1))
        let selectedRhomboids = Array(rhomboidExercises.prefix(1))
        let selectedBack = Array(backExercises.prefix(3))
        let selectedBiceps = Array(bicepExercises.prefix(2))
        let selectedBrachialis = Array(brachialisExercises.prefix(1))

        let bbExercises = selectedLats + selectedRhomboids + selectedBack + selectedBiceps + selectedBrachialis
        let bbRoutine = RoutineDto(
            id: 3,
            name: "Back/Biceps",
            description: "Strength routine for back and biceps",
            exerciseWithSetsDto: bbExercises.map { ExerciseWithSetsDto(exercise: $0, sets: createSetsRepsAndWeight(user: user) ?? []) }
        )

        // **HG Routine (Hamstrings, Glutes)**
        let hamstringExercises = getExercisesByMuscle("8")
        let gluteExercises = getExercisesByMuscle("12")

        let selectedHamstrings = Array(hamstringExercises.prefix(3))
        let selectedGlutes = Array(gluteExercises.prefix(2))

        let hgExercises = selectedHamstrings + selectedGlutes
        let hgRoutine = RoutineDto(
            id: 4,
            name: "Hamstrings/Glutes",
            description: "Strength routine for hamstrings and glutes",
            exerciseWithSetsDto: hgExercises.map { ExerciseWithSetsDto(exercise: $0, sets: createSetsRepsAndWeight(user: user) ?? []) }
        )
        return [cstRoutine, qcRoutine, bbRoutine, hgRoutine]
    }

    
    func createWeightLossRoutines(user: UserDto) {
        
    }
 
    func saveRoutineHistoryToDb(routineHistory: RoutineHistoryDto) -> Bool {
        performDatabaseTask {
            openDatabase()
            let query = """
            INSERT INTO RoutineHistory (routine_id, user_id, date, duration, difficulty, calories_burnt, notes) 
            VALUES (?, ?, ?, ?, ?, ?, ?);
            """
            
            var statement: OpaquePointer?
            
            // Prepare the SQL statement
            let prepareResult = sqlite3_prepare_v2(db, query, -1, &statement, nil)
            if prepareResult != SQLITE_OK {
                log(.error, "Error preparing statement: \(String(cString: sqlite3_errmsg(db)))")
                return false
            }
            
            defer { sqlite3_finalize(statement) } // Ensure statement is finalized
            
            // Bind parameters
            sqlite3_bind_int(statement, 1, Int32(routineHistory.routineId ?? 0))
            sqlite3_bind_int(statement, 2, Int32(routineHistory.userId ?? 0))
            
            if let date = routineHistory.date {
                let formatter = ISO8601DateFormatter()
                let dateString = formatter.string(from: date)
                sqlite3_bind_text(statement, 3, dateString, -1, SQLITE_TRANSIENT)
            } else {
                sqlite3_bind_null(statement, 3)
            }
            
            sqlite3_bind_double(statement, 4, routineHistory.duration ?? 0.0)
            sqlite3_bind_int(statement, 5, Int32(routineHistory.difficulty ?? 0))
            sqlite3_bind_int(statement, 6, Int32(routineHistory.caloriesBurnt ?? 0))
            
            if let notes = routineHistory.notes {
                sqlite3_bind_text(statement, 7, notes, -1, SQLITE_TRANSIENT)
            } else {
                sqlite3_bind_null(statement, 7)
            }
            
            // Execute the statement
            let stepResult = sqlite3_step(statement)
            if stepResult != SQLITE_DONE {
                log(.error, "Error inserting routine session: \(String(cString: sqlite3_errmsg(db)))")
                return false
                
            } else {
                log(.info, "Routine session successfully inserted.")
            }
            return true
        }
    }
    
    func addDayToRoutine(day: Int, routineId: Int) {
        guard (1...7).contains(day) else {
            log(.error, "Error: Invalid day. Must be between 1 (Sunday) and 7 (Saturday).")
            return
        }
        performDatabaseTask {
            openDatabase()
            
            let query = "INSERT INTO RoutineSchedule (routine_id, day_of_week) VALUES (?, ?);"
            
            var statement: OpaquePointer?
            
            if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
                sqlite3_bind_int(statement, 1, Int32(routineId))
                sqlite3_bind_int(statement, 2, Int32(day))
                
                if sqlite3_step(statement) == SQLITE_DONE {
                    log(.info, "Successfully added routine to day \(day).")
                } else {
                    log(.error, "Error inserting data.")
                }
            }
            sqlite3_finalize(statement)
            closeDatabase()
        }
    }
    
    func toggleFavoriteRoutine(routine: RoutineDto) {
        return performDatabaseTask {
            openDatabase()
            var newValue = routine.isFavorite ?? false ? 0 : 1
            let query = "UPDATE Routines SET is_favorite = ? WHERE routine_id = ?"
            var statement: OpaquePointer?
            
            if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
                sqlite3_bind_int(statement, 1, Int32(newValue))
                sqlite3_bind_int(statement, 2, Int32(routine.id))
                sqlite3_step(statement)
            } else {
                log(.error, "Failed to update routine favorite status: \(String(cString: sqlite3_errmsg(db)!))")
            }
            log(.info, "Updated favorite status for routine \(routine.id)")
            sqlite3_finalize(statement)            
        }
    }

    func getAllRoutines() -> [RoutineDto] {
        return performDatabaseTask {
            openDatabase()
            var routines = [RoutineDto]()
            log(.info, "Fetching all routines...")
            
            let query = "SELECT routine_id, name, description FROM Routines;"
            var statement: OpaquePointer?
            
            if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
                while sqlite3_step(statement) == SQLITE_ROW {
                    let id = sqlite3_column_int(statement, 0)
                    let namePointer = sqlite3_column_text(statement, 1)
                    let name = namePointer != nil ? String(cString: namePointer!) : "NULL_OR_EMPTY"
                    let descriptionPointer = sqlite3_column_text(statement, 2)
                    let description = descriptionPointer != nil ? String(cString: descriptionPointer!) : "NULL_OR_EMPTY"
                    log(.info, "Finished fetching routine with id: \(id)")
                    routines.append(RoutineDto(id: Int(id), name: name, description: description, exerciseWithSetsDto: nil))
                }
                log(.info, "Total routines: \(routines.count)")
            } else {
                let errorMessage = String(cString: sqlite3_errmsg(db))
                log(.error, "Failed to fetch routines: \(errorMessage)")
            }
            sqlite3_finalize(statement)
            return routines
        }
    }

    func getRoutineById(id: Int) -> RoutineDto? {
        return performDatabaseTask {
            openDatabase()
            let query = "SELECT * FROM Routines WHERE routine_id = ?;"
            var statement: OpaquePointer?
            
            guard sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK else {
                let errorMessage = String(cString: sqlite3_errmsg(db))
                log(.error, "Failed to prepare routine query: \(errorMessage)")
                return RoutineDto(
                    id: 0,
                    name: "None",
                    description: "None",
                    exerciseWithSetsDto: nil
                )
            }
            
            defer { sqlite3_finalize(statement) }

            // Bind values
            sqlite3_bind_int(statement, 1, Int32(id))

            if sqlite3_step(statement) == SQLITE_ROW {
                let routineId = sqlite3_column_int(statement, 0)
                let routineName = String(cString: sqlite3_column_text(statement, 1))
                let routineDescription = sqlite3_column_text(statement, 2).flatMap { String(cString: $0) }

                log(.info, "Routine retrieved successfully: \(routineName)")
                return RoutineDto(
                    id: Int(routineId),
                    name: routineName,
                    description: routineDescription,
                    exerciseWithSetsDto: nil
                )
            } else {
                log(.warning, "No routine found with id \(id)")
            }

            return nil
        }
    }
    
    func getRoutineByName(_ name: String) -> RoutineDto? {
        return performDatabaseTask {
            openDatabase()
            let query = "SELECT * FROM Routines WHERE name = ?;"
            var statement: OpaquePointer?

            guard sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK else {
                let errorMessage = String(cString: sqlite3_errmsg(db))
                log(.error, "Failed to prepare routine query: \(errorMessage)")
                return nil
            }
            
            defer { sqlite3_finalize(statement) }

            // Bind values
            sqlite3_bind_text(statement, 1, name, -1, SQLITE_TRANSIENT)

            if sqlite3_step(statement) == SQLITE_ROW {
                let routineId = sqlite3_column_int(statement, 0)
                let routineName = String(cString: sqlite3_column_text(statement, 1))
                let routineDescription = sqlite3_column_text(statement, 2).flatMap { String(cString: $0) }

                log(.info, "Routine retrieved successfully: \(routineName)")
                return RoutineDto(
                    id: Int(routineId),
                    name: routineName,
                    description: routineDescription,
                    exerciseWithSetsDto: nil
                )
            } else {
                log(.warning, "No routine found with name \(name)")
            }

            return nil
        }
    }
    
    func getSetsFromExercise(exerciseId: Int) -> [SetsDto] {
        openDatabase()
        var sets = [SetsDto]()
        let query = """
            SELECT res.set_number, res.reps, res.weight
            FROM RoutineExerciseSets res
            INNER JOIN RoutineExercises re on res.routine_exercise_id = re.id
            WHERE re.exercise_id = ?;
        """
        
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(exerciseId))
            
            while sqlite3_step(statement) == SQLITE_ROW {
                let setNumber = Int(sqlite3_column_int(statement, 0))
                let reps = Int(sqlite3_column_int(statement, 1))
                let weight = sqlite3_column_double(statement, 2)
                   
                let set = SetsDto(setNumber: setNumber, reps: reps, weight: weight)
                sets.append(set)
            }
        } else {
                    let errorMessage = String(cString: sqlite3_errmsg(db))
                    log(.error, "Failed to fetch sets for routine: \(errorMessage)")
        }
        sqlite3_finalize(statement)
        log(.info, "Fetched \(sets.count) sets for exercise ID: \(exerciseId)")
        return sets
    }
    
    func getSetsFromRoutine(routineId: Int) -> [SetsDto] {
        return performDatabaseTask {
            openDatabase()
            var sets = [SetsDto]()
            let query = """
                SELECT res.set_number, res.reps, res.weight
                FROM RoutineExericeSets res
                INNER JOIN RoutineExercises re ON res.routine_exercise_id = re.id
                WHERE re.routine_id = ?;
            """
            
            var statement: OpaquePointer?
            
            if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
                sqlite3_bind_int(statement, 1, Int32(routineId))
                
                while sqlite3_step(statement) == SQLITE_ROW {
                    let setNumber = Int(sqlite3_column_int(statement, 0))
                    let reps = Int(sqlite3_column_int(statement, 1))
                    let weight = sqlite3_column_double(statement, 2)
                       
                    let set = SetsDto(setNumber: setNumber, reps: reps, weight: weight)
                    sets.append(set)
                }
            } else {
                        let errorMessage = String(cString: sqlite3_errmsg(db))
                        log(.error, "Failed to fetch sets for routine: \(errorMessage)")
            }
            sqlite3_finalize(statement)
            log(.info, "Fetched \(sets.count) sets for routine ID: \(routineId)")
            return sets
        }
    }
    
    func getRoutineHistory(routineId: Int) -> [RoutineHistoryDto] {
        return performDatabaseTask {
            openDatabase()
            var routineSessions = [RoutineHistoryDto]()
            var statement: OpaquePointer?
            
            let query = """
            SELECT id, routine_id, user_id, date, duration, difficulty, calories_burnt, notes
            FROM RoutineHistory
            WHERE routine_id = ?;
            """
            
            // Prepare the SQL statement
            let prepareResult = sqlite3_prepare_v2(db, query, -1, &statement, nil)
            if prepareResult != SQLITE_OK {
                log(.error, "Error preparing statement: \(String(cString: sqlite3_errmsg(db)))")
                return []
            }
            
            defer { sqlite3_finalize(statement) }
            
            // Bind the routine ID to the statement
            sqlite3_bind_int(statement, 1, Int32(routineId))
            
            // Execute the query and iterate through results
            while sqlite3_step(statement) == SQLITE_ROW {
                var session = RoutineHistoryDto()
                
                session.id = Int(sqlite3_column_int(statement, 0))
                session.routineId = Int(sqlite3_column_int(statement, 1))
                session.userId = Int(sqlite3_column_int(statement, 2))
                
                if let dateText = sqlite3_column_text(statement, 3) {
                    let dateString = String(cString: dateText)
                    let formatter = ISO8601DateFormatter()
                    session.date = formatter.date(from: dateString)
                }
                
                session.duration = sqlite3_column_double(statement, 4)
                session.difficulty = Int(sqlite3_column_int(statement, 5))
                session.caloriesBurnt = Int(sqlite3_column_int(statement, 6))
                
                if let notesText = sqlite3_column_text(statement, 7) {
                    session.notes = String(cString: notesText)
                }
                
                routineSessions.append(session)
            }
            
            if routineSessions.isEmpty {
                log(.warning, "No routine history found for routine ID: \(routineId)")
            } else {
                log(.info, "Retrieved \(routineSessions.count) routine history records.")
            }
            return routineSessions
        }
    }
    
    func getDaysForRoutine(routineId: Int) -> [Int] {
        var days: [Int] = []
        
        performDatabaseTask {
            openDatabase()
            
            let query = "SELECT day_of_week FROM RoutineSchedule WHERE routine_id = ?;"
            var statement: OpaquePointer?
            
            if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
                sqlite3_bind_int(statement, 1, Int32(routineId))
                
                while sqlite3_step(statement) == SQLITE_ROW {
                    let day = Int(sqlite3_column_int(statement, 0))
                    days.append(day)
                }
            } else {
                log(.error, "Error preparing statement: \(String(cString: sqlite3_errmsg(db)))")
            }
            
            sqlite3_finalize(statement)
            closeDatabase()
        }        
        return days
    }
    
    func getRoutinesForDay(day: Int) -> [Int] {
        var routines: [Int] = []

        performDatabaseTask {
            openDatabase()
            
            let query = """
            SELECT routine_id
            FROM RoutineSchedule
            WHERE day_of_week = ?;
            """
            
            var statement: OpaquePointer?
            
            if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
                sqlite3_bind_int(statement, 1, Int32(day))
                
                while sqlite3_step(statement) == SQLITE_ROW {
                    let routineId = Int(sqlite3_column_int(statement, 0))
                    routines.append(routineId)
                }
            } else {
                log(.error, "Error preparing statement: \(String(cString: sqlite3_errmsg(db)))")
            }
            
            sqlite3_finalize(statement)
            closeDatabase()
        }
        return routines
    }

    func getAllRoutineSchedules() -> [(routineId: Int, dayOfWeek: Int)] {
        var result: [(Int, Int)] = []
        //TODO: gets all info from routine schedule table in db. add to result
        
        return result
    }
    func deleteRoutine(routine: RoutineDto) -> Bool {
        return performDatabaseTask {
            openDatabase() // Ensure the database is open
            
            let query = "DELETE FROM Routines WHERE routine_id = ?;"
            var statement: OpaquePointer?

            // Prepare the statement
            guard sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK else {
                let errorMessage = String(cString: sqlite3_errmsg(db))
                log(.error, "Failed to prepare delete query: \(errorMessage)")
                return false
            }

            defer { sqlite3_finalize(statement) } // Ensure the statement is finalized

            // Bind the routine ID to the query
            guard sqlite3_bind_int(statement, 1, Int32(routine.id)) == SQLITE_OK else {
                let errorMessage = String(cString: sqlite3_errmsg(db))
                log(.error, "Failed to bind routine ID: \(errorMessage)")
                return false
            }

            // Execute the statement
            guard sqlite3_step(statement) == SQLITE_DONE else {
                let errorMessage = String(cString: sqlite3_errmsg(db))
                log(.error, "Failed to delete routine: \(errorMessage)")
                return false
            }
            log(.info, "Routine with ID \(routine.id) successfully deleted.")
            return true
        }
    }
    
    func createSetsRepsAndWeight(user: UserDto) -> [SetsDto]? {
        guard let level = user.currentStats.fitnessLevel?.lowercased(),
              let goal = user.goals.goalExercise?.lowercased() else {
            return nil
        }
        
        let trainingData: [String: [String: (ClosedRange<Int>, ClosedRange<Double>, ClosedRange<Int>)]] = [
            "beginner": [
                "strength": (4...6, 60.0...70.0, 2...3),
                "weight loss": (8...12, 50.0...60.0, 1...3),
                "cardio": (12...20, 35.0...45.0, 2...3)
            ],
            "intermediate": [
                "strength": (3...5, 70.0...80.0, 3...4),
                "weight loss": (6...10, 60.0...70.0, 2...4),
                "cardio": (15...20, 45.0...55.0, 3...4)
            ],
            "advanced": [
                "strength": (2...4, 80.0...95.0, 4...5),
                "weight loss": (6...10, 65.0...75.0, 2...4),
                "cardio": (15...20, 55.0...65.0, 3...5)
            ]
        ]
        
        guard let goalData = trainingData[level]?[goal] else {
            return nil
        }
        
        let numberOfSets = Int.random(in: goalData.2)
        
        var sets: [SetsDto] = []
        for setNumber in 1...numberOfSets {
            let reps = Int.random(in: goalData.0)
            let weightPercentage = Double.random(in: goalData.1)
            
            sets.append(SetsDto(setNumber: setNumber, reps: reps, weight: 0))
        }
        return sets
    }
    
    func createUser(withName name: String) -> Bool {
        return performDatabaseTask {
            openDatabase()
            let query = """
            INSERT INTO Users (name, username, created_at)
            VALUES (?, (SELECT IFNULL(MAX(user_id), 0) + 1 FROM Users), CURRENT_TIMESTAMP);
            """
            var statement: OpaquePointer?

            guard sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK else {
                let errorMessage = String(cString: sqlite3_errmsg(db))
                log(.error, "Error preparing statement: \(errorMessage)")
                return false
            }

            defer { sqlite3_finalize(statement) }

            // Bind the name
            guard sqlite3_bind_text(statement, 1, name, -1, SQLITE_TRANSIENT) == SQLITE_OK else {
                let errorMessage = String(cString: sqlite3_errmsg(db))
                log(.error, "Error binding name: \(errorMessage)")
                return false
            }

            // Execute the statement
            guard sqlite3_step(statement) == SQLITE_DONE else {
                let errorMessage = String(cString: sqlite3_errmsg(db))
                log(.error, "Failed to insert user: \(errorMessage)")
                return false
            }

            log(.info, "Successfully inserted user: \(name)")
            return true
        }
    }
    
    func updateUserField(userId: Int, fieldName: String, value: Any) -> Bool {
        return performDatabaseTask {
            openDatabase()
            let query = "UPDATE Users SET \(fieldName) = ? WHERE user_id = ?;"
            var statement: OpaquePointer?
            
            guard sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK else {
                let errorMessage = String(cString: sqlite3_errmsg(db))
                log(.error, "Failed to prepare query: \(errorMessage)")
                return false
            }
            
            defer { sqlite3_finalize(statement) }
            
            // Bind the value based on its type
            if let textValue = value as? String {
                guard sqlite3_bind_text(statement, 1, textValue, -1, SQLITE_TRANSIENT) == SQLITE_OK else {
                    let errorMessage = String(cString: sqlite3_errmsg(db))
                    log(.error, "Failed to bind text value: \(errorMessage)")
                    return false
                }
            } else if let intValue = value as? Int {
                guard sqlite3_bind_int(statement, 1, Int32(intValue)) == SQLITE_OK else {
                    let errorMessage = String(cString: sqlite3_errmsg(db))
                    log(.error, "Failed to bind int value: \(errorMessage)")
                    return false
                }
            } else if let doubleValue = value as? Double {
                guard sqlite3_bind_double(statement, 1, doubleValue) == SQLITE_OK else {
                    let errorMessage = String(cString: sqlite3_errmsg(db))
                    log(.error, "Failed to bind double value: \(errorMessage)")
                    return false
                }
            } else {
                log(.error, "Unsupported value type for binding.")
                return false
            }
            
            // Bind the user ID
            guard sqlite3_bind_int(statement, 2, Int32(userId)) == SQLITE_OK else {
                let errorMessage = String(cString: sqlite3_errmsg(db))
                log(.error, "Failed to bind user ID: \(errorMessage)")
                return false
            }
            
            // Execute the statement
            guard sqlite3_step(statement) == SQLITE_DONE else {
                let errorMessage = String(cString: sqlite3_errmsg(db))
                log(.error, "Failed to execute update: \(errorMessage)")
                return false
            }
            
            log(.info, "\(fieldName.capitalized) updated successfully for user with ID \(userId).")
            return true
        }
    }

    func changeName(userId: Int, name: String) -> Bool {
        updateUserField(userId: userId, fieldName: "name", value: name)
    }

    func changeUserEmail(userId: Int, email: String) -> Bool {
        updateUserField(userId: userId, fieldName: "email", value: email)
    }

    func changeUsername(userId: Int, username: String) -> Bool {
        updateUserField(userId: userId, fieldName: "username", value: username)
    }
    
    func changeAge(userId: Int, age: Int) -> Bool {
        return updateUserField(userId: userId, fieldName: "age", value: age)
    }

    func changeHeight(userId: Int, height: Double) -> Bool {
        return updateUserField(userId: userId, fieldName: "height", value: height)
    }

    func changeCurrentWeight(userId: Int, currentWeight: Double) -> Bool {
        return updateUserField(userId: userId, fieldName: "current_weight", value: currentWeight)
    }

    func changeBodyFat(userId: Int, bodyFat: Double) -> Bool {
        return updateUserField(userId: userId, fieldName: "body_fat", value: bodyFat)
    }

    func changeFitnessLevel(userId: Int, fitnessLevel: String) -> Bool {
        return updateUserField(userId: userId, fieldName: "fitness_level", value: fitnessLevel)
    }

    func changeGymMembership(userId: Int, gymMembership: Bool) -> Bool {
        return updateUserField(userId: userId, fieldName: "gym_membership", value: gymMembership ? 1 : 0)
    }

    func changeGoalWeight(userId: Int, goalWeight: Double) -> Bool {
        return updateUserField(userId: userId, fieldName: "goal_weight", value: goalWeight)
    }

    func changeGoalGymDays(userId: Int, goalGymDays: Int) -> Bool {
        return updateUserField(userId: userId, fieldName: "goal_gym_days", value: goalGymDays)
    }

    func changeGoalExercise(userId: Int, goalExercise: String) -> Bool {
        return updateUserField(userId: userId, fieldName: "goal_exercise", value: goalExercise)
    }

    func changeGoalBodyFat(userId: Int, goalBodyFat: Double) -> Bool {
        return updateUserField(userId: userId, fieldName: "goal_body_fat", value: goalBodyFat)
    }

    private func getUserBy(query: String, parameter: String? = nil) -> UserDto? {
        openDatabase()
        
        var statement: OpaquePointer?
        var user: UserDto? = nil
        let helper = DatabaseManagerHelper.shared
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            // Bind the parameter if provided
            if let parameter = parameter {
                sqlite3_bind_text(statement, 1, (parameter as NSString).utf8String, -1, SQLITE_TRANSIENT)
            }
            
            // Execute the query and retrieve the results
            if sqlite3_step(statement) == SQLITE_ROW {
                // User fields
                let userId = Int(sqlite3_column_int(statement, 0))
                let name = String(cString: sqlite3_column_text(statement, 1))
                let username = helper.getOptionalString(statement, columnIndex: 2)
                let email = helper.getOptionalString(statement, columnIndex: 3)
                let createdAt = helper.getOptionalString(statement, columnIndex: 5)
                let profilePictureUrl = helper.getOptionalString(statement, columnIndex: 6)
                let startingPicture = helper.getOptionalString(statement, columnIndex: 7)
                let progressPicture = helper.getOptionalString(statement, columnIndex: 8)
                let subscriptionId = helper.getOptionalInt(statement, columnIndex: 9)
                
                // CurrentStatsDto fields
                let age = helper.getOptionalInt(statement, columnIndex: 10)
                let height = helper.getOptionalDouble(statement, columnIndex: 11)
                let currentWeight = helper.getOptionalDouble(statement, columnIndex: 12)
                let bodyFat = helper.getOptionalDouble(statement, columnIndex: 13)
                let fitnessLevel = helper.getOptionalString(statement, columnIndex: 14)
                let gymMembership = helper.getOptionalBool(statement, columnIndex: 15)
                
                let currentStats = CurrentStatsDto(
                    age: age,
                    height: height,
                    currentWeight: currentWeight,
                    bodyFat: bodyFat,
                    fitnessLevel: fitnessLevel,
                    gymMembership: gymMembership
                )
                
                // GoalsDto fields
                let goalWeight = helper.getOptionalDouble(statement, columnIndex: 16)
                let goalGymDays = helper.getOptionalInt(statement, columnIndex: 17)
                let goalExercise = helper.getOptionalString(statement, columnIndex: 18)
                let goalBodyFat = helper.getOptionalDouble(statement, columnIndex: 19)
                
                let goals = GoalsDto(
                    goalWeight: goalWeight,
                    goalGymDays: goalGymDays,
                    goalExercise: goalExercise,
                    goalBodyFat: goalBodyFat
                )
                
                // Create UserDto
                user = UserDto(
                    userId: userId,
                    name: name,
                    username: username,
                    email: email,
                    createdAt: createdAt,
                    profilePictureUrl: profilePictureUrl,
                    startingPicture: startingPicture,
                    progressPicture: progressPicture,
                    subscriptionId: subscriptionId,
                    currentStats: currentStats,
                    goals: goals
                )
            }
        } else {
            let errorMessage = String(cString: sqlite3_errmsg(db))
            log(.error, "Error preparing statement: \(errorMessage)")
        }
        
        sqlite3_finalize(statement)
        closeDatabase()
        
        return user
    }

    func getUserById(userId: Int) -> UserDto? {
        let query = "SELECT * FROM Users WHERE user_id = ?;"
        return dbQueue.sync {
            return getUserBy(query: query, parameter: "\(userId)")
        }
    }

    func getUserByName(name: String) -> UserDto? {
        let query = "SELECT * FROM Users WHERE name = ?;"
        return dbQueue.sync {
            return getUserBy(query: query, parameter: name)
        }
    }

    func getUserByUsername(username: String) -> UserDto? {
        let query = "SELECT * FROM Users WHERE username = ?;"
        return dbQueue.sync {
            return getUserBy(query: query, parameter: username)
        }
    }

    func getFirstUser() -> UserDto? {
        let query = "SELECT * FROM Users ORDER BY user_id ASC LIMIT 1;"
        return dbQueue.sync {
            return getUserBy(query: query)
        }
    }
    
    func deleteAllUsers() {
        return performDatabaseTask {
            openDatabase()
            let table = "Users"
            
            let deleteQuery = "DELETE FROM \(table)"
            var statement: OpaquePointer? = nil
            
            if sqlite3_prepare_v2(db, deleteQuery, -1, &statement, nil) == SQLITE_OK {
                if sqlite3_step(statement) == SQLITE_DONE {
                    log(.info, "Successfully deleted all data from table \(table).")
                } else {
                    log(.error, "Failed to delete data from table \(table): \(String(cString: sqlite3_errmsg(db)))")
                }
            } else {
                log(.error, "Failed to prepare delete statement for table \(table): \(String(cString: sqlite3_errmsg(db)))")
            }
            sqlite3_finalize(statement)
        }
    }
    
    deinit {
        closeDatabase()
    }
}

enum DatabaseManagerError: Error, LocalizedError {
    case queryError(message: String)  // Error when the query preparation or execution fails
    case noDataFound(message: String)  // Error when no data is found for the given criteria

    var errorDescription: String? {
        switch self {
        case .queryError(let message):
            return "Database query error: \(message)"
        case .noDataFound(let message):
            return message
        }
    }
}
