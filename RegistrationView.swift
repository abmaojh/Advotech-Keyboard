//
//  AccountView.swift
//  Advotech Keyboard
//
//  Created by Alhammadi, Abdulrahman (UMKC-Student) on 2/14/24.
//

import SwiftUI
import Firebase
import FirebaseCore // Used for Firebase initialization
import FirebaseAuth // Used for user authentication
import FirebaseFirestore

struct RegistrationView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var name = ""
    @State private var phoneNumber = ""
    @State private var selectedUserType = UserType.user  // Default
    @State private var caretakerID = ""  // For users only
    @State private var showLoading = false
    @State private var showError = false
    @State private var errorMessage = ""

    enum UserType: String, CaseIterable, Identifiable {
        case user = "User"
        case caretaker = "Caretaker"
        var id: String { self.rawValue }
    }

    var body: some View {
        VStack {
            Text("Create an Account")
                .font(.title)

            TextField("Email", text: $email)
                .padding()

            SecureField("Password", text: $password)
                .padding()
                .accessibilityIdentifier("passwordField")

            SecureField("Confirm Password", text: $confirmPassword)
                .padding()
                .accessibilityIdentifier("confirmPasswordField")

            TextField("Name", text: $name)
                .padding()
            
            TextField("Phone Number", text: $phoneNumber)
                .padding()
                .keyboardType(.phonePad) // Enforce phone number keyboard

            Picker("User Type", selection: $selectedUserType) {
                ForEach(UserType.allCases) { type in
                    Text(type.rawValue).tag(type)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            if selectedUserType == .user {
                TextField("Caretaker ID", text: $caretakerID)
                    .padding()
            }

            Button("Register") {
                showLoading = true
                registerUser()
            }
            .padding()

            if showLoading {
                ProgressView()
            }

            /*if showError {
                Text("Error: \(errorMessage)")
            }*/
        }
        .padding()
    }

    func registerUser() {
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match"
            showError = true
            showLoading = false
            return
        }

        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                errorMessage = error.localizedDescription
                showError = true
            } else {
                createFirestoreUser() // Successful authentication
            }
            showLoading = false
        }
    }

    func createFirestoreUser() {
        guard let uid = Auth.auth().currentUser?.uid else {
            errorMessage = "Could not retrieve user ID. Please try again."
            showError = true
            return
        }

        let userData = [
            "userID": uid,
            "name": name,
            "email": email,
            "userType": selectedUserType.rawValue,
            "caretakerID": caretakerID,
            "phoneNumber": phoneNumber
        ]

        Firestore.firestore().collection("users").document(uid).setData(userData) { error in
            if let error = error {
                errorMessage = "Failed to save user data: \(error.localizedDescription)"
                showError = true
            } else {
                // Successful Firestore Save
                print("User data saved successfully!") // Adjust the logging if needed
            }
        }
    }

}
