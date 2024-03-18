import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseMessaging

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var showLoading = false
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationView {
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
    }

    func loginUser() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            showLoading = false
            if let error = error {
                errorMessage = error.localizedDescription
                showError = true
            } else {
                print("Login Successful!")
                // Send FCM Token after successful login
                sendFCMTokenToServer()
                // Navigate to UserView
                let userView = UserView()
                let hostingController = UIHostingController(rootView: userView)
                UIApplication.shared.windows.first?.rootViewController = hostingController
            }
        }
    }

    func sendFCMTokenToServer() {
        Messaging.messaging().token { token, error in
            if let error = error {
                print("Error fetching FCM token: \(error)")
            } else if let token = token {
                guard let userID = Auth.auth().currentUser?.uid else { return }

                let db = Firestore.firestore()
                db.collection("fcmTokens").document(userID).setData([
                    "token": token
                ]) { error in
                    if let error = error {
                        print("Error saving FCM token: \(error)")
                    } else {
                        print("FCM token saved successfully")
                    }
                }
            }
        }
    }
}