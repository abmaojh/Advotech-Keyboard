//
//  WelcomeView.swift
//  Keyboard Advotech
//
//  Created by Alhammadi, Abdulrahman (UMKC-Student) on 2/19/24.
//

import Foundation
import SwiftUI

struct WelcomeView: View {
    var body: some View {
        NavigationView { // Enables navigation within app
            VStack(alignment: .center) {
                Text("Advotech Keyboard")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()

                Spacer() // Pushes buttons toward the bottom

                // Login Button
                NavigationLink(destination: AccountView()) {
                    Text("Login")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }

                // Register Button
                NavigationLink(destination: RegistrationView()) {
                    Text("Register")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                Spacer() // Pushes buttons toward the bottom
            }
            .padding()
        }
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}
