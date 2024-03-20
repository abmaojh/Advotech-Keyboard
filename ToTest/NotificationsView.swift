import SwiftUI
import Firebase
import FirebaseFirestore

struct NotificationsView: View {
    @State private var notifications = [UserNotification]()
    @State private var isLoading = false

    var body: some View {
        List(notifications) { notification in
            VStack(alignment: .leading) {
                Text(notification.message)
                Text(notification.formattedDate)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .onAppear(perform: loadNotifications)
    }

    func loadNotifications() {
        isLoading = true

        guard let userID = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()

        db.collection("notifications").document(userID).collection("userNotifications")
            .order(by: "timestamp", descending: true)
            .getDocuments { (querySnapshot, error) in

                self.isLoading = false

                if let error = error {
                    print("Error getting notifications: \(error.localizedDescription)")
                } else if let querySnapshot = querySnapshot {
                    self.notifications = querySnapshot.documents.compactMap { document -> UserNotification? in
                        let data = document.data()
                        let id = document.documentID
                        let fromUserID = data["fromUserID"] as? String ?? ""
                        let message = data["message"] as? String ?? ""
                        let timestamp = data["timestamp"] as? Timestamp ?? Timestamp()

                        var newNotification = UserNotification(id: id, fromUserID: fromUserID, message: message, timestamp: timestamp)

                        // Fetch User Name Asynchronously
                        db.collection("users").document(fromUserID).getDocument { userSnapshot, userError in
                            if let userError = userError {
                                print("Error fetching user data: \(userError.localizedDescription)")
                            } else if let userSnapshot = userSnapshot, userSnapshot.exists {
                                let userData = userSnapshot.data()!
                                let userName = userData["name"] as? String ?? "Unknown User"
                                newNotification.userName = userName
                                // Update notifications after fetching the username:
                                self.updateNotification(newNotification)
                            }
                        }

                        return newNotification
                    }
                }
            }
    }

    // Helper function to update the notifications array
    private func updateNotification(_ updatedNotification: UserNotification) {
        if let index = notifications.firstIndex(where: { $0.id == updatedNotification.id }) {
            notifications[index] = updatedNotification
        }
    }
}

struct UserNotification: Identifiable {
    let id: String
    let fromUserID: String
    let message: String
    let timestamp: Timestamp
    var userName: String = ""

    var formattedDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        return dateFormatter.string(from: timestamp.dateValue())
    }
}