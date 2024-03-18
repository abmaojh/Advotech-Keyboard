//
//  AppDelegate.swift
//  Advotech Keyboard
//
//  Created by Alhammadi, Abdulrahman (UMKC-Student) on 2/14/24.
//

import SwiftUI
import FirebaseCore
import UserNotifications
import FirebaseMessaging

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate { // Add MessagingDelegate

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {

        FirebaseApp.configure()

        // Request notification permissions
        UNUserNotificationCenter.current().delegate = self
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { _, _ in }
        application.registerForRemoteNotifications() // Register for remote notifications

        // Firebase Messaging setup
        Messaging.messaging().delegate = self

        return true
    }

    // Handle receiving FCM token (MessagingDelegate method)
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("FCM token: \(fcmToken ?? "")")
        // Send this fcmToken to your server and associate it with the caretaker
    }

     // Add functions to handle incoming notifications if needed (UNUserNotificationCenterDelegate methods)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // ... Handle notifications when the app is in the foreground ...
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // ... Handle notifications when the user taps on them ...
    }

}
@main
struct YourApp: App {
    // No change needed here with @UIApplicationDelegateAdaptor
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            NavigationView {
                WelcomeView()
            }
        }
    }
}
