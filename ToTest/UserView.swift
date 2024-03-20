import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseMessaging

struct UserView: View {
    @State private var userData: UserData? = nil
    @Binding var isLoggedIn: Bool // Binding to control login state in parent view

    struct UserData {
        let name: String
        let email: String
        let phoneNumber: String
        let userType: String
        let caretakerID: String? // Optional, only for users who are not caretakers
    }

    var body: some View {
        VStack(alignment: .leading) {
            if let userData = userData {
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
                        isLoggedIn = false // Update login state
                    } catch {
                        print("Error signing out: \(error.localizedDescription)")
                    }
                }
                .padding()
            } else {
                Text("Loading user data...")
            }
        }
        .padding()
        .onAppear(perform: fetchUserData)
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
                    userType: data["userType"] as? String ?? "",
                    caretakerID: data["caretakerID"] as? String
                )
            } else {
                // Handle case: document doesn't exist
            }
        }
    }

    func sendNotification(to caretakerID: String) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        let notification = [
            "fromUserID": userID,
            "message": "Sensitive information may have been shared",
            "timestamp": FieldValue.serverTimestamp()
        ] as [String : Any]
        db.collection("notifications").document(caretakerID).collection("userNotifications").addDocument(data: notification) { error in
            if let error = error {
                print("Error sending notification: \(error.localizedDescription)")
            } else {
                print("Notification sent successfully")
            }
        }
    }
}