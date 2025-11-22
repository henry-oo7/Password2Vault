import SwiftUI

extension View {
    func displayError(showError: Binding<Bool>, alertType: ActiveAlert?) -> some View {
        self.alert(isPresented: showError) {
            switch alertType {
            case .loginFailed:
                Alert(title: Text("Login Failed"))
            case .serverRejection:
                Alert(title: Text("Server Rejection"))
            case .hashingFailed:
                Alert(title: Text("Hashing Failed"))
            case .missingSalt:
                Alert(title: Text("missing salt"))
            case nil:
                Alert(title: Text("Unknown Error"))
            }
        }
    }
}
