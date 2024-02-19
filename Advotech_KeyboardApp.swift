//
//  Advotech_KeyboardApp.swift
//  Advotech Keyboard
//
//  Created by Alhammadi, Abdulrahman (UMKC-Student) on 2/14/24.
//

import SwiftUI
import FirebaseCore
import Firebase

@main
struct Advotech_KeyboardApp: App {
    init() {
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            RegistrationView()
        }
    }
}
