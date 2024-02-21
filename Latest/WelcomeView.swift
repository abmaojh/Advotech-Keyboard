//
//  WelcomeView.swift
//  Keyboard Advotech
//
//  Created by Alhammadi, Abdulrahman (UMKC-Student) on 2/19/24.
//
import Foundation
import SwiftUI
import Firebase
import FirebaseAuth

struct WelcomeView: View {
    @State private var showLoginView = false // For presenting LoginView modally
   // @State private var navigateToAccountView: Bool = false
    //@State private var showAccountView = false
    
    
    var body: some View {
        NavigationView { // Enables navigation within app
            VStack(alignment: .center) {
                Text("Advotech Keyboard")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()
                
                Spacer() // Pushes buttons toward the bottom
                if showLoginView {
                                  LoginView() // Include LoginView conditionally
                } else {
                    // Login Button
                    Button("Login") {
                        showLoginView = true // Show the LoginView modally
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    
                    // Register Button
                    NavigationLink(destination: RegistrationView()) {
                        Text("Register")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                Spacer() // Pushes buttons toward the bottom
            }
            .padding()
            //if showAccountView {
               // AccountView()
            //}
        }
    }
    
    struct WelcomeView_Previews: PreviewProvider {
        static var previews: some View {
            WelcomeView()
        }
    }
}

    
