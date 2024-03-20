import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var showLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    @Binding var isLoggedIn: Bool // Binding to control login state in parent view

    var body: some View {
        VStack {
            Text("Login").font(.title)
            TextField("Email", text: $email).padding()
            SecureField("Password", text: $password).padding()
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
        .padding()
    }

    func loginUser() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            showLoading = false
            if let error = error {
                errorMessage = error.localizedDescription
                showError = true
            } else {
                print("Login Successful!")
                isLoggedIn = true // Update login state
            }
        }
    }
}