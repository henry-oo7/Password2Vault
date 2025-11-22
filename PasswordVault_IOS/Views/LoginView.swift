//
//  LoginView.swift
//  PasswordVault
//
//  Created by henryMac on 11/20/25.
//
import SwiftUI

struct LoginView: View {
    
    @Binding public var activeAlert: ActiveAlert? 
    @Binding public var username: String
    @State private var password: String = ""
    @State private var showError: Bool = false
    @Binding public var currentPage: Page
    
    var body: some View {
        
        VStack(spacing: 20) { 
            
            Text("Password Vault")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            // Input Field 1
            TextField("Username", text: $username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none) // Important for usernames!
                .padding(.horizontal)
            
            // Input Field 2 (SecureField hides the text for passwords)
            SecureField("Master Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            // The Login Button
            Button(action: {
                
                APIService().getSalt(username: username) {salt in
                    if let salt = salt {
                        print("We got the salt: \(salt)")
                        
                        let realHash = CryptoManager.shared.generateArgon2Hash(password: password, salt: salt)
                        print("REAL ARGON2HASH: \(realHash ?? "ERROR")")
                        
                        let userToLogin = User (
                            username: username,
                            salt: salt,
                            authHash: realHash
                        )
                        
                        APIService().login(user: userToLogin) {success in
                            if success {
                                if let hash = realHash, let key = CryptoManager.shared.getKey(from: hash) {
                                    CryptoManager.shared.activeKey = key
                                    
                                    SharedStorage.shared.saveKey(key)
                                    SharedStorage.shared.saveUsername(username)
                                    
                                }
                                DispatchQueue.main.async {
                                    self.currentPage = .vault
                                }
                            }
                            else {
                                DispatchQueue.main.async {
                                    self.showError = true
                                    self.activeAlert = .loginFailed
                                }
                            }
                        }
                    }
                    else {
                        DispatchQueue.main.async {
                            self.showError = true
                            self.activeAlert = .missingSalt
                        }
                    }
                }
            }) {
                Text("Login")
                    .foregroundColor(.white)
                    .frame(width: 200, height: 50)
                    .background(Color.blue)
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
            Spacer() // Pushes everything to the top
        }
        .padding()
        .displayError(showError: $showError, alertType: activeAlert)
    }
}
