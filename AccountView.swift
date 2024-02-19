//
//  AccountView.swift
//  Advotech Keyboard
//
//  Created by Alhammadi, Abdulrahman (UMKC-Student) on 2/14/24.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseCore

struct AccountView: View {
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

            CustomSecureField(placeholder: "Password", text: $password)
                .padding()

            CustomSecureField(placeholder: "Confirm Password", text: $confirmPassword)
                .padding()
            
            TextField("Name", text: $name)
                .padding()

            TextField("Phone Number", text: $phoneNumber)
                .padding()
                .keyboardType(.phonePad)

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
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let userData = [
            "userID": uid,
            "name": name,
            "email": email,
            "phoneNumber": phoneNumber,
            "userType": selectedUserType.rawValue,
            "caretakerID": caretakerID // If provided
        ]

        Firestore.firestore().collection("users").document(uid).setData(userData) { error in
            if let error = error {
                errorMessage = "Failed to save user data: \(error)"
                showError = true
            } else {
                // Registration successful
            }
        }
    }
}
