//
//  DatabaseManagerTests.swift
//  FitTrack
//
//  Created by Joseph Chica on 12/18/24.
//

import XCTest
import SQLite3
@testable import FitTrack

final class DatabaseManagerTest: XCTestCase {

    override func setUpWithError() throws {
        // Set up test environment
        DatabaseManager.shared.openDatabase()
    }

    override func tearDownWithError() throws {
        // Clean up test environment
        DatabaseManager.shared.closeDatabase()
    }

    func testOpenAndCloseDatabase() throws {
        // Test opening the database
        DatabaseManager.shared.openDatabase()
        XCTAssertNotNil(DatabaseManager.shared.db, "Database should be open and not nil")

        // Test closing the database
        DatabaseManager.shared.closeDatabase()
        XCTAssertNil(DatabaseManager.shared.db, "Database should be closed and nil")
    }
    
    func testDatabaseOpensOnlyOnce() throws {
        // Attempt to open the database multiple times
        DatabaseManager.shared.openDatabase()
        DatabaseManager.shared.openDatabase()

        // Verify that the database is open and `isDatabaseOpen` is true
        XCTAssertNotNil(DatabaseManager.shared.db, "Database should be open.")
        XCTAssertTrue(DatabaseManager.shared.isDatabaseOpen, "Database should report as open.")

        // Close the database
        DatabaseManager.shared.closeDatabase()

        // Verify the database is closed and `isDatabaseOpen` is false
        XCTAssertNil(DatabaseManager.shared.db, "Database should be nil after closing.")
        XCTAssertFalse(DatabaseManager.shared.isDatabaseOpen, "Database should report as closed.")
    }

    /*
     Exercise Tests
     */
    func testGetExercisesByName() throws {
        let exercises = DatabaseManager.shared.getExercisesByName("Squat")
        XCTAssertNotNil(exercises, "Exercises array should not be nil")
        XCTAssertGreaterThan(exercises.count, 0, "Exercises count should be greater than zero")
        
        if exercises.count > 0 {
            let firstExercise = exercises.first
            XCTAssertNotNil(firstExercise?.name, "Exercise name should not be nil")
        }
    }
    
    func testFetchAllExercises() throws {
        let exercises = DatabaseManager.shared.getAllExercisesNames()
        XCTAssertNotNil(exercises, "Exercises array should not be nil")
        XCTAssertGreaterThan(exercises.count, 0, "Exercises count should be greater than zero")
    }
    
    func testSaveExerciseSet() throws {
        // Create a mock routine session, exercise, and set
        let routineSession = RoutineHistoryDto(id: 1, routineId: 1)
        let exercise = ExerciseDto(id: 101, name: "Bench Press", description: nil,
                                   level: nil, instructions: nil, equipmentNeeded: nil,
                                   overloading: nil, powerStrengthSupplement: nil,
                                   isolationCompoundAccessory: nil, pushPullLegs: nil,
                                   verticalHorizontalRotational: nil, stretch: nil, videoURL: nil)
        let set = SetsDto(setNumber: 1, reps: 10, weight: 135.0)
        
        // Act: Call the function to insert data
        let result = DatabaseManager.shared.saveExerciseSet(routineHistory: routineSession, exercise: exercise, set: set)
        
        // Assert: Ensure the function returns true
        XCTAssertTrue(result, "saveExerciseSet should return true on successful insertion")
        
        // Fetch the inserted data using `getExerciseHistory`
        let historyEntries = DatabaseManager.shared.getExerciseHistory(exerciseId: exercise.id)
        
        // Verify that at least one entry is found
        XCTAssertFalse(historyEntries.isEmpty, "No data found in ExerciseHistory table")
        
        // Extract the first result (assuming only one entry was added)
        if let entry = historyEntries.first {
            XCTAssertEqual(entry.exerciseId, exercise.id, "Exercise ID does not match")
            XCTAssertEqual(entry.routineId, routineSession.routineId, "Routine ID does not match")
            XCTAssertEqual(entry.routineHistoryId, routineSession.id, "Routine Session ID does not match")

            // Since `getExerciseHistory` groups sets under a single session, ensure the set exists
            XCTAssertFalse(entry.sets.isEmpty, "No sets found in exercise history")
            if let savedSet = entry.sets.first {
                XCTAssertEqual(savedSet.reps, set.reps, "Reps value does not match")
                XCTAssertEqual(savedSet.weight, set.weight, "Weight value does not match")
            }
        } else {
            XCTFail("Failed to retrieve saved exercise set data")
        }
    }
    
    /*
     Routine Tests
     */
    func testSaveRoutineToDb() throws {
        //create exercise
        let exercise = ExerciseDto(
            id: 1,
            name: "Assisted Dips",
            description: "Dips using an assisted dip machine to reduce resistance.",
            level: "Beginner",
            instructions: "",
            equipmentNeeded: true,
            overloading: false,
            powerStrengthSupplement: "strength",
            isolationCompoundAccessory: "compound",
            pushPullLegs: "Push",
            verticalHorizontalRotational: "Vertical",
            stretch: false,
            videoURL: nil
        )
        
        //create sets
        let setReps = [
            SetsDto(setNumber: 1, reps: 12, weight: 0),
            SetsDto(setNumber: 2, reps: 12, weight: 0),
            SetsDto(setNumber: 3, reps: 12, weight: 0)]
        
        let exericsesWithSets = ExerciseWithSetsDto(exercise: exercise, sets: setReps)
        // Create a mock routine
        let routine = RoutineDto(
            id: 0, // Use an unlikely ID to avoid conflicts
            name: "Test Routine",
            description: "This routine is simply for testing purposes",
            exerciseWithSetsDto: [exericsesWithSets]
        )

        // Log before saving
        print("Saving routine: \(routine.name)")

        // After saving
        let success = DatabaseManager.shared.saveRoutineWithExercisesToDb(routine)
        XCTAssertTrue(success, "Routine should be saved successfully")
    }
    
    func testFetchAllRoutines() throws {
        let testExercise = ExerciseDto(
            id: Int.random(in: 1...1000), // Random ID for uniqueness
            name: "Test Exercise",
            description: "A test exercise description",
            level: "Beginner",
            instructions: "Perform the exercise correctly.",
            equipmentNeeded: false,
            overloading: false,
            powerStrengthSupplement: nil,
            isolationCompoundAccessory: "Compound",
            pushPullLegs: "Push",
            verticalHorizontalRotational: "Vertical",
            stretch: false,
            videoURL: nil
        )

        let testSets = [
            SetsDto(setNumber: 1, reps: 10, weight: 50.0),
            SetsDto(setNumber: 2, reps: 8, weight: 55.0),
            SetsDto(setNumber: 3, reps: 6, weight: 60.0)
        ]

        let testExerciseWithSets = ExerciseWithSetsDto(exercise: testExercise, sets: testSets)

        // Insert a test routine
        let routine = RoutineDto(
            id: 0,
            name: "Test Routine Fetch",
            description: "Testing fetch function",
            exerciseWithSetsDto: [testExerciseWithSets]
        )
        let saveSuccess = DatabaseManager.shared.saveRoutineWithExercisesToDb(routine)
        XCTAssertTrue(saveSuccess, "Routine should be saved successfully for fetching test.")

        // Fetch all routines
        let routines = DatabaseManager.shared.fetchAllRoutines()
        XCTAssertNotNil(routines, "Fetch all routines should return a non-nil array.")
        XCTAssertGreaterThan(routines.count, 0, "There should be at least one routine in the database.")

        // Debugging print statement
        if let lastRoutine = routines.last {
            print("Last Routine Name: \(lastRoutine.name)")
        } else {
            print("No routines found.")
        }

        // Verify the last inserted routine matches the expected name
        XCTAssertEqual(routines.last?.name, "Test Routine Fetch", "The fetched routine should match the last inserted test routine.")
    }

    func testSaveGeneralRoutine() throws {
        // Step 1: Create the routine
        let generalRoutine = DatabaseManager.shared.createMainLiftOne(user: UserDto(userId: 999, name: "Joe"))
        
        // Step 2: Save the routine to the database
        let saveSuccess = DatabaseManager.shared.saveRoutineWithExercisesToDb(generalRoutine)
        XCTAssertTrue(saveSuccess, "General Routine should be saved successfully.")
        
        // Step 3: Fetch the routine from the database to verify
        let fetchedRoutines = DatabaseManager.shared.fetchAllRoutines()
        XCTAssertNotNil(fetchedRoutines, "Fetch routines should not return nil.")
        XCTAssertGreaterThanOrEqual(fetchedRoutines.count, 1, "There should be at least one routine in the database.")
        
        // Step 4: Validate the saved routine's data
        if var savedRoutine = fetchedRoutines.first(where: { $0.name == "Generated Routine 1" }) {
            savedRoutine.exerciseWithSetsDto = DatabaseManager.shared.getExercisesWithSetsFromRoutine(routineId: savedRoutine.id)
            XCTAssertEqual(savedRoutine.name, generalRoutine.name, "Routine name should match.")
            XCTAssertEqual(savedRoutine.description, generalRoutine.description, "Routine description should match.")
            XCTAssertEqual(savedRoutine.exerciseWithSetsDto?.count, generalRoutine.exerciseWithSetsDto?.count, "Number of exercises should match.")
        } else {
            XCTFail("General Routine was not found in the database.")
        }
    }

    func testRoutineHistory() {
        // Step 1: Create a test routine session
        let testSession = RoutineHistoryDto()
        testSession.routineId = 1
        testSession.userId = 123
        testSession.date = Date() // Use current date
        testSession.duration = 45.5
        testSession.difficulty = 3
        testSession.caloriesBurnt = 200
        testSession.notes = "Great workout session!"

        // Step 2: Insert the test session into the database
        DatabaseManager.shared.createRoutineHistory(routineHistory: testSession)
        
        // Step 3: Fetch routine sessions for the same routineId
        let fetchedSessions = DatabaseManager.shared.getRoutineHistory(routineId: 1)
        
        // Step 4: Validate the results using XCTAssert functions
        XCTAssertFalse(fetchedSessions.isEmpty, "Expected at least one session, but found none.")
        
        guard let fetchedSession = fetchedSessions.first else {
            XCTFail("Failed to retrieve the inserted routine session.")
            return
        }
        
        XCTAssertNotNil(fetchedSession.id, "Routine session ID should not be nil.")
        XCTAssertEqual(fetchedSession.routineId, testSession.routineId, "Routine ID mismatch.")
        XCTAssertEqual(fetchedSession.userId, testSession.userId, "User ID mismatch.")
        XCTAssertEqual(fetchedSession.duration, testSession.duration, "Duration mismatch.")
        XCTAssertEqual(fetchedSession.difficulty, testSession.difficulty, "Difficulty mismatch.")
        XCTAssertEqual(fetchedSession.caloriesBurnt, testSession.caloriesBurnt, "Calories burnt mismatch.")
        XCTAssertEqual(fetchedSession.notes, testSession.notes, "Notes mismatch.")

        if let testDate = testSession.date, let fetchedDate = fetchedSession.date {
            let timeDifference = abs(testDate.timeIntervalSince(fetchedDate))
            XCTAssert(timeDifference < 1.0, "Date mismatch (Expected: \(testDate), Found: \(fetchedDate))")
        } else {
            XCTFail("Date is nil in either test session or fetched session.")
        }
    }
    
    func testRoutineDeletion() throws {
        var routines = DatabaseManager.shared.fetchAllRoutines()
        
        if(routines.count < 1) {
            let routine = DatabaseManager.shared.createMainLiftOne(user: UserDto(userId: 9999, name: "Nala"))
            XCTAssertTrue(DatabaseManager.shared.saveRoutineWithExercisesToDb(routine), "Failed saving routine")
            routines.append(routine)
        }
        XCTAssertTrue(DatabaseManager.shared.deleteRoutine(routine: routines.first!), "Failed to delete routine")
        
        let secondRoutines = DatabaseManager.shared.fetchAllRoutines()
        XCTAssertTrue(routines.count == secondRoutines.count + 1, "New routines list is not 1 less than previous routine list")
    }
    
    func testRoutineDynamicallyGenerated() throws {
        let userName = "Benito"
        //create user
        XCTAssertTrue(DatabaseManager.shared.createUser(withName: userName), "Failed to create user")
        
        //get user from db
        guard let user = DatabaseManager.shared.getUserByName(name: userName) else {
            XCTFail("Failed to get user from DB")
            return
        }
        let id = user.userId
        XCTAssertTrue(DatabaseManager.shared.changeFitnessLevel(userId: id, fitnessLevel: "Intermediate"), "Failed to update fitness level")
        XCTAssertTrue(DatabaseManager.shared.changeGymMembership(userId: id, gymMembership: true), "Failed to update gym membership")
        XCTAssertTrue(DatabaseManager.shared.changeGoalExercise(userId: id, goalExercise: "Strength"), "Failed to update goal exercise")
        XCTAssertTrue(DatabaseManager.shared.changeGoalGymDays(userId: id, goalGymDays: 6), "Failed to update gym days")
        
        DatabaseManager.shared.chooseAndCreateRoutines(user: user)
        
        let routines = DatabaseManager.shared.fetchAllRoutines()
        XCTAssertNotNil(routines, "Failed to fetch routines")
        
        for routine in routines {
            XCTAssertFalse(((routine.exerciseWithSetsDto?.isEmpty) != nil), "Routine \(routine.name) is empty")
        }
    }

    /*
     User Tests
     */
    func testUserFunctions() throws {
        let user = DatabaseManager.shared.getFirstUser()
        
        if user == nil {
            
        }
        // Step 1: Create a user
        let name = "JoeShmoe"
        let username = "joe_shmoe"
        let email = "joe@example.com"
        let secondName = "Poopy"
        
        // Assuming createUser returns the userId after creating the user
        let success = DatabaseManager.shared.createUser(withName: name)
        XCTAssertTrue(success, "Failed to create user")
        
        if let user = DatabaseManager.shared.getUserByName(name: name) {
            XCTAssertEqual(user.name, name, "User name does not match")
            
            if let firstUser = DatabaseManager.shared.getFirstUser() {
                XCTAssertEqual(firstUser.name, name, "First user name does not match")
            } else {
                XCTFail("Failed to load first user")
            }
            
            //updating and checking username
            XCTAssertTrue(DatabaseManager.shared.changeUsername(userId: user.userId, username: username), "Changing username returned false")
            XCTAssertEqual(DatabaseManager.shared.getUserByUsername(username: username)?.username, username, "Username was not changed")
            
            //updating and checking email
            XCTAssertTrue(DatabaseManager.shared.changeUserEmail(userId: user.userId, email: email), "Changing email returned false")
            XCTAssertEqual(DatabaseManager.shared.getUserById(userId: user.userId)?.email, email, "Email was not changed")
            
            //updating and checking name
            XCTAssertTrue(DatabaseManager.shared.changeName(userId: user.userId, name: secondName), "Changing name returned false")
            XCTAssertEqual(DatabaseManager.shared.getUserByName(name: secondName)?.name, secondName, "Name was not changed")
            
        } else {
            XCTFail("Failed to retrieve user by name")
        }
    }
    
    func testUserDeletion() throws {
        var user = DatabaseManager.shared.getFirstUser()
        if(user != nil) {
            DatabaseManager.shared.deleteAllUsers()
        }
        user = DatabaseManager.shared.getFirstUser()
        XCTAssertTrue(user == nil, "Failed to delete user: \(String(describing: user?.name))")
    }
}
