//


import SwiftUI

struct ContentView: View {

    @State private var username = ""
    @State private var currentPage: Page = .welcome
    @State private var activeAlert: ActiveAlert?
    

    var body: some View {
        switch currentPage {
            
        case .welcome:
            WelcomeView(currentPage: $currentPage)
        
        case .login:
            LoginView(activeAlert: $activeAlert, username: $username,currentPage: $currentPage)
            
        case .register:
            RegisterView(currentPage: $currentPage, activeAlert: $activeAlert)
            
        case .vault:
            VaultView(username: username, currentPage: $currentPage)
        }
    }
}
