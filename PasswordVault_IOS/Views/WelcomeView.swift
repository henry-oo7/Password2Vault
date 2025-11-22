//
//  WelcomeView.swift
//  PasswordVault
//
//  Created by henryMac on 11/20/25.
//

import SwiftUI

struct WelcomeView: View {
    
    @Binding public var currentPage: Page
    
    var body: some View {
        VStack {
            Text("Password2Vault")
                .font(.largeTitle)
                .padding()
        
        
            Button(action: {
                DispatchQueue.main.async {
                    self.currentPage = .login
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
                    self.currentPage = .register
                }
            }) {
                Text("Register")
                    .foregroundColor(.white)
                    .frame(width: 200, height: 50)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }
    }
}
