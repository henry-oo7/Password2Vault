import SwiftUI

struct RegisterView: View {
    @Binding var currentPage: Page
    @State private var username = ""
    @State private var password = ""
    @State private var showError = false
    @Binding public var activeAlert: ActiveAlert?
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Create Account")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            TextField("Username", text: $username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
                .padding(.horizontal)
            
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            Button(action: {
                // TODO: Fill in the registration logic here!
                // 1. Generate a random salt
                let salt = CryptoManager.shared.makeSalt()
                // 2. Generate the Argon2 hash
                let authHash = CryptoManager.shared.generateArgon2Hash(password: password, salt: salt)
                // 3. Create a User object
                let user = User(username: username,salt: salt, authHash: authHash)
                // 4. Call APIService to register
                if authHash != nil {
                    APIService().register(user: user) { success in
                        if success {
                            print("Registration successful!")
                            self.currentPage = .welcome
                        }
                        else {
                            DispatchQueue.main.async {
                                self.showError = true
                                self.activeAlert = .serverRejection
                            }
                        }
                    }
                }
                else{
                    DispatchQueue.main.async {
                        self.showError = true
                        self.activeAlert = .hashingFailed
                    }
                }
                
            }) {
                Text("Register")
                    .foregroundColor(.white)
                    .frame(width: 200, height: 50)
                    .background(Color.green) // Green for "Go"!
                    .cornerRadius(10)
            }
            
            Button(action: {
                DispatchQueue.main.async {
                    self.currentPage = .welcome
                }
            }) {
                Text("Go back")
                    .foregroundColor(.white)
                    .frame(width: 200, height: 50)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            
            Spacer()
        }
        .padding()
        .displayError(showError: $showError, alertType: activeAlert)
    }
}
