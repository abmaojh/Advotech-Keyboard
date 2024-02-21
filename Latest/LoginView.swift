//
//  LoginView.swift
//  Keyboard Advotech
//
//  Created by Alhammadi, Abdulrahman (UMKC-Student) on 2/21/24.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore


struct LoginView: View {
    @State private var isLoggedIn = false
    @State private var email = ""
    @State private var password = ""
    @State private var showLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var userData: UserData?
    
    //@Binding var showAccountView: Bool
    
    struct UserData {
        let name: String
        let email: String
        let phoneNumber: String
        let userType: String
    }


    var body: some View {
        NavigationView {
            VStack {
                if isLoggedIn {
                    VStack(alignment: .leading) {
                        if let userData = userData {
                            Text("Welcome, \(userData.name)")
                            Text("Email: \(userData.email)")
                            Text("Phone Number: \(userData.phoneNumber)")
                            Text("User Type: \(userData.userType)")
                        } else {
                            ProgressView() // Show loading while fetching data
                        }

                        // Add a divider for visual separation (optional)
                        Divider()

                        Button("Logout") {
                            // Implementation for logout will go here
                            try? Auth.auth().signOut()  // Example logout attempt
                            isLoggedIn = false
                        }
                    }
                } else {
                    VStack {// Display Login Form
                        Text("Login").font(.title)
                        TextField("Email", text: $email).padding()
                        SecureField("Password", text: $password).padding()
                    }
                    Button("Login") {
                        showLoading = true
                        loginUser()
                    }
                    .padding()

                    if showLoading {
                        ProgressView()
                    }

                    if showError {
                        Text("Error: \(errorMessage)")
                    }
                }
            }
            .padding()
        }
    }

    func loginUser() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            showLoading = false
            if let error = error {
                errorMessage = error.localizedDescription
                showError = true
            } else {
                print("Login Successful!")
                isLoggedIn = true
                fetchUserData()
            }
        }
    }
    func fetchUserData() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        db.collection("users").document(userID).getDocument { snapshot, error in
            if let error = error {
                // Handle error
            } else if let snapshot = snapshot, snapshot.exists {
                let data = snapshot.data()!
                userData = UserData(
                    name: data["name"] as? String ?? "Unknown Name",
                    email: data["email"] as? String ?? "",
                    phoneNumber: data["phoneNumber"] as? String ?? "",
                    userType: data["userType"] as? String ?? ""
                )
            } else {
                // Handle case: document doesn't exist
            }
        }
    }
}

    



