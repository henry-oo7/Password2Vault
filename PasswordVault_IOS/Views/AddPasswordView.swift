//
//  AddPasswordView.swift
//  PasswordVault
//
//  Created by henryMac on 11/19/25.
//

import SwiftUI

struct AddPasswordView: View {
    
    @State private var website: String = ""
    @State private var password: String = ""
    @State private var showError: Bool = false
    @Environment(\.presentationMode) var presentationMode
    let username: String
    // A list of common websites in alphabetical order
    let commonWebsites = [
        "amazon.com", "apple.com", "discord.com", "facebook.com",
        "github.com", "google.com", "instagram.com", "linkedin.com",
        "netflix.com", "paypal.com", "reddit.com", "spotify.com",
        "twitch.tv", "X.com", "wikipedia.org", "yahoo.com",
        "youtube.com"
    ]
    
    var body: some View {
        VStack(spacing: 20) { 
            
            Text("Submit Password")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            HStack{
                TextField("Website", text: $website)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none) // Important for usernames!
                    .padding(.horizontal)
                Menu {
                    ForEach(commonWebsites, id: \.self) { site in
                        Button(site) {
                            self.website = site
                        }
                    }
                } label: {
                    Image(systemName: "chevron.down.circle")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
            }.padding(.horizontal)
            
            HStack{
                TextField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                Button(action: {
                    self.password = CryptoManager.shared.generatePassword()
                }) {
                    Image(systemName: "die.face.5")
                        .font(.title2)
                }
            }.padding(.horizontal)
            
            
            Button(action: {
                guard let key = CryptoManager.shared.activeKey else {
                    print("Error: No active key found")
                    DispatchQueue.main.async {
                        self.showError = true
                    }
                    return
                }
                
                let rawString = "\(website):\(password)"
                
                if let cipherText = CryptoManager.shared.encrypt(text: rawString, key: key) {
                    
                    let vaultEntry = VaultEntry(
                        id: nil,
                        encryptedData: cipherText
                    )
                    
                    APIService().addVaultEntry(username: self.username, entry: vaultEntry) {success in
                        if success {
                            DispatchQueue.main.async {
                                presentationMode.wrappedValue.dismiss()
                            }
                        }
                        else {
                            print("Failed to save password")
                            DispatchQueue.main.async {
                                self.showError = true
                            }
                            
                        }
                    }
                }
                }) {
                    Text("Submit")
                        .foregroundColor(.white)
                        .frame(width: 200, height: 50)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                
                Spacer()
            }
                .padding()
                .alert(isPresented: $showError) {
                    Alert(
                        title: Text("Error"),
                        message: Text("Failed to save password"),
                        dismissButton: .default(Text("OK"))
                    )
        }
    }
}
