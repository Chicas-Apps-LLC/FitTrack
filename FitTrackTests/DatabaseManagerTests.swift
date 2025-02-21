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
    
    func testUserDeletion() throws {
        var user = DatabaseManager.shared.getFirstUser()
        if(user != nil) {
            DatabaseManager.shared.deleteAllUsers()
        }
        user = DatabaseManager.shared.getFirstUser()
        XCTAssertTrue(user == nil, "Failed to delete user: \(String(describing: user?.name))")
    }
}
