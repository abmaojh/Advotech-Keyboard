import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore

struct UserView: View {
    @State private var userData: UserData? = nil
    @State private var showLoading = false
    @State private var showError = false
    @State private var errorMessage = ""

    struct UserData {
        let name: String
        let email: String
        let phoneNumber: String
        let userType: String
        let caretakerID: String? // Optional, only for users who are not caretakers
    }

    var body: some View {
        NavigationView {
            VStack {
                if let userData = userData {
                    VStack(alignment: .leading) {
                        Text("Welcome, \(userData.name)")
                        Text("Email: \(userData.email)")
                        Text("Phone Number: \(userData.phoneNumber)")
                        Text("User Type: \(userData.userType)")
                        // Logic for showing buttons based on user type
                        Group {
                            if userData.userType == "Caretaker" {
                                NavigationLink(destination: NotificationsView()) {
                                    Text("View Notifications")
                                }
                                .padding()
                            } else if let caretakerID = userData.caretakerID {
                                Button("Notify Caretaker") {
                                    sendNotification(to: caretakerID)
                                }
                                .padding()
                            }
                        }
                        Divider()
                        Button("Logout") {
                            do {
                                try Auth.auth().signOut()
                                self.userData = nil
                            } catch {
                                print("Error signing out: \(error.localizedDescription)")
                            }
                        }
                        .padding()
                    }
                } else {
                    if showLoading {
                        ProgressView()
                    } else if showError {
                        Text("Error: \(errorMessage)")
                    } else {
                        Text("Loading user data...")
                    }
                }
            }
            .padding()
            .onAppear(perform: fetchUserData)
        }
    }

    func fetchUserData() {
        showLoading = true
        guard let userID = Auth.auth().currentUser?.uid else {
            errorMessage = "Could not retrieve user ID."
            showError = true
            showLoading = false
            return
        }

        let db = Firestore.firestore()
        db.collection("users").document(userID).getDocument { snapshot, error in
            showLoading = false
            if let error = error {
                errorMessage = "Error fetching user data: \(error.localizedDescription)"
                showError = true
            } else if let snapshot = snapshot, snapshot.exists {
                let data = snapshot.data()!
                userData = UserData(
                    name: data["name"] as? String ?? "Unknown Name",
                    email: data["email"] as? String ?? "",
                    phoneNumber: data["phoneNumber"] as? String ?? "",
                    userType: data["userType"] as? String ?? "",
                    caretakerID: data["caretakerID"] as? String
                )
            } else {
                errorMessage = "User data not found."
                showError = true
            }
        }
    }

    func sendNotification(to caretakerID: String) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        let notification = ["fromUserID": userID, "message": "Sensitive information may have been shared", "timestamp": FieldValue.serverTimestamp()] as [String : Any]
        db.collection("notifications").document(caretakerID).collection("userNotifications").addDocument(data: notification) { error in
            if let error = error {
                print("Error sending notification: \(error.localizedDescription)")
            } else {
                print("Notification sent successfully")
            }
        }
    }
}