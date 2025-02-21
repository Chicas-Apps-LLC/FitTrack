//
//  UserProfileView.swift
//  FitTrack
//
//  Created by Joseph Chica on 1/2/25.
//

import SwiftUI
import PhotosUI

struct UserProfileView: View {
    @ObservedObject var user: UserDto
    @StateObject private var userViewModel = UserViewModel()
        
    var body: some View {
        Form {
            BasicInformationView(user: user, validationErrors: userViewModel.validationErrors)
            PhysicalInformationView(user: user, validationErrors: userViewModel.validationErrors)
            UserGoalView(goals: user.goals, validationErrors: userViewModel.validationErrors)
            PictureView(user: user)
            
            Section {
                Button(action: saveChanges) {
                    Text("Save Changes")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppColors.primary)
                        .foregroundColor(.black)
                        .cornerRadius(8)
                }
            }
        }
        .navigationTitle("User Profile")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            userViewModel.loadFirstUser()
        }
    }
    
    private func saveChanges() {
        let success = userViewModel.saveChanges(for: user)

        if success {
            log(.info, "All changes saved successfully for user ID \(user.userId).")
        } else {
            if let error = userViewModel.saveError {
                log(.error, "Save changes failed: \(error)")
            } else {
                log(.error, "Save changes failed due to unknown error.")
            }
        }
    }
}

struct BasicInformationView: View {
    @ObservedObject var user: UserDto
    let validationErrors: [String]
    
    var body: some View {
        Section(header: Text("Basic Information")) {
            HStack {
                Text("ID:")
                    .bold()
                Spacer()
                Text("\(user.userId)")
                    .foregroundColor(AppColors.gray)
            }

            HStack {
                Text("Name:")
                    .bold()
                Spacer()
                TextField("Enter name", text: $user.name)
                    .multilineTextAlignment(.trailing)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }

            HStack {
                Text("Username:")
                    .bold()
                Spacer()
                TextField(
                    "Enter username",
                    text: Binding(
                        get: { user.username ?? "" },
                        set: { newValue in
                            user.username = newValue.isEmpty ? nil : newValue
                        }
                    )
                )
                .multilineTextAlignment(.trailing)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            }

            HStack {
                Text("Email:")
                    .bold()
                Spacer()
                TextField(
                    "Enter email",
                    text: Binding(
                        get: { user.email ?? "" },
                        set: { newValue in
                            user.email = newValue.isEmpty ? nil : newValue
                        }
                    )
                )
                .multilineTextAlignment(.trailing)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            }
        }
    }
}

struct PhysicalInformationView: View {
    @ObservedObject var user: UserDto
    let validationErrors: [String]

    var body: some View {
        HStack {
            Text("Age:")
                .bold()
            Spacer()
            TextField(
                "Enter age",
                text: Binding(
                    get: { "\(user.currentStats.age ?? 0)" },
                    set: { user.currentStats.age = Int($0) }
                )
            )
            .multilineTextAlignment(.trailing)
            .textFieldStyle(RoundedBorderTextFieldStyle())
        }

        HStack {
            Text("Height:")
                .bold()
            Spacer()
            TextField(
                "WIP",
                text: Binding(
                    get: { "WIP" },
                    set: { user.currentStats.height = Double($0) }
                )
            )
            .multilineTextAlignment(.trailing)
            .textFieldStyle(RoundedBorderTextFieldStyle())
        }

        HStack {
            Text("Current Weight:")
                .bold()
            Spacer()
            TextField(
                "Enter current weight",
                text: Binding(
                    get: { user.currentStats.currentWeight.map { "\($0)" } ?? "" },
                    set: { user.currentStats.currentWeight = Double($0) }
                )
            )
            .multilineTextAlignment(.trailing)
            .textFieldStyle(RoundedBorderTextFieldStyle())
        }

        HStack {
            Text("Body Fat (%):")
                .bold()
            Spacer()
            TextField(
                "Enter body fat percentage",
                text: Binding(
                    get: { user.currentStats.bodyFat.map { "\($0)" } ?? "" },
                    set: { user.currentStats.bodyFat = Double($0) }
                )
            )
            .multilineTextAlignment(.trailing)
            .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }
}

struct UserGoalView: View {
    @ObservedObject var goals: GoalsDto
    let validationErrors: [String]

    var body: some View {
        Section(header: Text("Goals")) {
            HStack {
                Text("Goal Weight:")
                    .bold()
                Spacer()
                TextField(
                    "Enter goal weight",
                    text: Binding(
                        get: { goals.goalWeight.map { "\($0)" } ?? "" },
                        set: { goals.goalWeight = Double($0) }
                    )
                )
                .multilineTextAlignment(.trailing)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.decimalPad)
            }

            HStack {
                Text("Goal Gym Days (per week):")
                    .bold()
                Spacer()
                TextField(
                    "Enter goal gym days",
                    text: Binding(
                        get: { goals.goalGymDays.map { "\($0)" } ?? "" },
                        set: { goals.goalGymDays = Int($0) }
                    )
                )
                .multilineTextAlignment(.trailing)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.numberPad)
            }

            HStack {
                Text("Goal Exercise:")
                    .bold()
                Spacer()
                TextField(
                    "Enter goal exercise type",
                    text: Binding(
                        get: { goals.goalExercise ?? "" },
                        set: { goals.goalExercise = $0.isEmpty ? nil : $0 }
                    )
                )
                .multilineTextAlignment(.trailing)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            }

            HStack {
                Text("Goal Body Fat (%):")
                    .bold()
                Spacer()
                TextField(
                    "Enter goal body fat percentage",
                    text: Binding(
                        get: { goals.goalBodyFat.map { "\($0)" } ?? "" },
                        set: { goals.goalBodyFat = Double($0) }
                    )
                )
                .multilineTextAlignment(.trailing)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.decimalPad)
            }
        }
    }
}


struct PictureView: View {
    @ObservedObject var user: UserDto
    
    @State private var isShowingImagePicker = false
    @State private var selectedPictureType: PictureType?
    @State private var selectedImage: UIImage?
    @StateObject private var userViewModel = UserViewModel()
    
    var body: some View {
        Section(header: Text("Pictures")) {
            PictureRow(
                title: "Profile Picture",
                imageExists: user.profilePictureUrl != nil && !user.profilePictureUrl!.isEmpty
            ) {
                selectedPictureType = .profilePicture
                isShowingImagePicker = true
            }
            PictureRow(
                title: "Starting Picture",
                imageExists: user.startingPicture != nil && !user.startingPicture!.isEmpty
            ) {
                selectedPictureType = .startingPicture
                isShowingImagePicker = true
            }
            PictureRow(
                title: "Progress Picture",
                imageExists: user.progressPicture != nil && !user.progressPicture!.isEmpty
            ) {
                selectedPictureType = .progressPicture
                isShowingImagePicker = true
            }
        }
        .sheet(isPresented: $isShowingImagePicker) {
            ImagePicker { image in
                handleImageSelection(image)
            }
        }
    }

    
    
    private func handleImageSelection(_ image: UIImage?) {
        guard let image = image else { return }
        selectedImage = image

        switch selectedPictureType {
                case .profilePicture:
                    saveImageToStorage(image: image, for: "profilePicture")
                case .startingPicture:
                    saveImageToStorage(image: image, for: "startingPicture")
                case .progressPicture:
                    saveImageToStorage(image: image, for: "progressPicture")
                case .none:
                    break
                }

        selectedPictureType = nil
    }

    private func saveImageLocally(_ image: UIImage, name: String) -> URL? {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return nil }
        let fileManager = FileManager.default
        let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentDirectory.appendingPathComponent("\(name).jpg")
        do {
            try data.write(to: fileURL)
            return fileURL
        } catch {
            print("Error saving image locally: \(error)")
            return nil
        }
    }

    private func saveImageToStorage(image: UIImage, for field: String) {
        // Save image locally
        if let localURL = saveImageLocally(image, name: field) {
            print("Image saved locally at: \(localURL)")
            
            // Update UserDto with local file path
            switch field {
            case "profilePicture":
                user.profilePictureUrl = localURL.absoluteString
            case "startingPicture":
                user.startingPicture = localURL.absoluteString
            case "progressPicture":
                user.progressPicture = localURL.absoluteString
            default:
                break
            }

            // TODO: Add logic to upload to cloud storage in the future
            // Example:
            // uploadImageToCloud(localURL: localURL, field: field)
        }
    }


}

struct PictureRow: View {
    let title: String
    let imageExists: Bool
    let action: () -> Void

    var body: some View {
        HStack {
            Text(title)
                .bold()
            Spacer()
            Button(action: action) {
                Text(imageExists ? "Change" : "Add")
                    .foregroundColor(.blue)
            }
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    var onImageSelected: (UIImage?) -> Void

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onImageSelected: onImageSelected)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        var onImageSelected: (UIImage?) -> Void

        init(onImageSelected: @escaping (UIImage?) -> Void) {
            self.onImageSelected = onImageSelected
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            guard let provider = results.first?.itemProvider, provider.canLoadObject(ofClass: UIImage.self) else {
                onImageSelected(nil)
                return
            }
            provider.loadObject(ofClass: UIImage.self) { image, _ in
                DispatchQueue.main.async {
                    self.onImageSelected(image as? UIImage)
                }
            }
        }
    }
}

struct UserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        UserProfileView(user: UserDto(
            userId: 1,
            name: "John Doe",
            username: "johndoe",
            email: "johndoe@example.com",
            createdAt: "2023-01-01",
            profilePictureUrl: nil,
            startingPicture: nil,
            progressPicture: nil,
            subscriptionId: 123
        ))
    }
}

private enum FocusField: Hashable {
    case username
    case email
}

enum PictureType {
    case profilePicture
    case startingPicture
    case progressPicture
}
