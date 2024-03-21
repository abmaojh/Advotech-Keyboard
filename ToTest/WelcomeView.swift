import SwiftUI

struct WelcomeView: View {

    var body: some View {
        NavigationView {
            VStack(alignment: .center) {
                Text("Advotech Keyboard")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()

                Spacer()

                // Login Button (navigates to LoginView)
                NavigationLink(destination: LoginView()) {
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

                Spacer()
            }
            .padding()
        }
    }
}
