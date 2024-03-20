import SwiftUI
import Firebase
import FirebaseAuth

struct WelcomeView: View {
    @State private var isLoggedIn = false // Track login state

    var body: some View {
        NavigationView {
            VStack(alignment: .center) {
                Text("Advotech Keyboard")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()

                Spacer()

                if isLoggedIn {
                    UserView(isLoggedIn: $isLoggedIn) // Show UserView when logged in
                } else {
                    // Login Button
                    Button("Login") {
                        isLoggedIn = true // Set isLoggedIn to true to show UserView
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

                Spacer()
            }
            .padding()
        }
    }
}
    
