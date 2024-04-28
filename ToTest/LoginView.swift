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
import SendGrid

let apiKey = "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"

struct LoginView: View {
    @State private var isLoggedIn = false
    @State private var email = ""
    @State private var password = ""
    @State private var showLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var userData: UserData? = nil // Ensure userData is optional
    @State private var caretakerEmail: String?
    
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
                if isLoggedIn, let userData = userData {
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
                                isLoggedIn = false
                                self.userData = nil // Should work if userData is declared as UserData?
                            } catch {
                                print("Error signing out: \(error.localizedDescription)")
                            }
                        }
                        .padding()
                    }
                } else {
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
                }
            }
            .padding()
            //.navigationBarBackButtonHidden(true) // Add this line
                       //.toolbar { // Add this block of code
                          // ToolbarItem(placement: .navigationBarLeading) {
                             //  Button("Back") {
                               //    navigationController?.popViewController(animated: true)
                              // }
                          // }
                      // }
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
                    userType: data["userType"] as? String ?? "",
                    caretakerID: data["caretakerID"] as? String
                )
                // Store caretaker ID in shared defaults
                if let userData = userData {
                               let sharedDefaults = UserDefaults(suiteName: "group.UMKCAdvotech")
                               sharedDefaults?.set(userData.caretakerID, forKey: "caretakerID")
                           }
            } else {
                // Handle case: document doesn't exist
            }
        }
    }
    func sendNotification(to caretakerID: String) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()

        // 1. Retrieve caretaker's email address
        db.collection("users").document(caretakerID).getDocument { snapshot, error in
            if let error = error {
                print("Error fetching caretaker data: \(error)")
                return
            }

            guard let snapshot = snapshot, snapshot.exists,
                  let caretakerData = snapshot.data(),
                  let caretakerEmailString = caretakerData["email"] as? String else {
                print("Error: Caretaker email not found")
                return
            }

            // 2. Create Firestore notification
            let notification = ["fromUserID": userID, "message": "Sensitive information may have been shared", "timestamp": FieldValue.serverTimestamp()] as [String : Any]
            db.collection("notifications").document(caretakerID).collection("userNotifications").addDocument(data: notification) { error in
                if let error = error {
                    print("Error sending notification: \(error.localizedDescription)")
                } else {
                    print("Firestore notification sent successfully")
                }
            }

            // 3. Send email notification
            sendEmailNotification(to: caretakerEmailString)
        }
    }

}
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
            isLoading = true // Show loading state

            guard let userID = Auth.auth().currentUser?.uid else { return }
            let db = Firestore.firestore()

            db.collection("notifications").document(userID).collection("userNotifications")
                .order(by: "timestamp", descending: true)
                .getDocuments { (querySnapshot, error) in

                    self.isLoading = false // Hide loading state

                    if let error = error {
                        // Handle the error appropriately in your app
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
//EMAIL
func sendEmailNotification(to emailAddress: String) {
    
    let apiKey = "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"

    // 2. Configure SendGrid session
    let session = Session()
    session.authentication = Authentication.apiKey(apiKey)

    // 3. Create email content
    let personalization = Personalization(recipients: emailAddress)
    let plainTextContent = Content(contentType: .plainText, value: "Please check the app. Sensitive information may have been shared.")
    let email = Email(
        personalizations: [personalization],
        from: "hamani4624@gmail.com", // Replace with your sender email
        content: [plainTextContent],
        subject: "Sensitive Information Detected"
    )

    // 4. Send email
    do {
        try session.send(request: email)
        print("Email sent successfully!")
    } catch {
        print("Error sending email: \(error)")
    }
}
  // Define your UserNotification model here, making sure it conforms to Identifiable
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
