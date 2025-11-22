import AuthenticationServices
import SwiftUI

@objc(CredentialProviderViewController)
class CredentialProviderViewController: ASCredentialProviderViewController {
    
    private var currentServiceIdentifiers: [ASCredentialServiceIdentifier] = []
    private var currentCredentialIdentity: ASPasswordCredentialIdentity?

    private var loggedInUsername: String?
    private var hasActiveKey: Bool = false

    private var hostingController: UIHostingController<AutoFillView>?

    private func cancel(_ code: ASExtensionError.Code = .failed) {
        let nsError = NSError(domain: ASExtensionErrorDomain,
                              code: code.rawValue,
                              userInfo: nil)
        self.extensionContext.cancelRequest(withError: nsError)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let key = SharedStorage.shared.getKey(),
              let username = SharedStorage.shared.getUsername() else {
            print("Error: Not logged in")
            cancel(.userCanceled)
            return
        }
        self.loggedInUsername = username
        self.hasActiveKey = true
        
        let matchedDomain = currentServiceIdentifiers.first(where: { $0.type == .domain })?.identifier
        let autoFillView = AutoFillView(username: username, filterDomain: matchedDomain) { (site, password) in
            guard let user = self.loggedInUsername else {
                self.cancel(.failed)
                return
            }

            let credential = ASPasswordCredential(user: user, password: password)
            self.extensionContext.completeRequest(withSelectedCredential: credential, completionHandler: nil)
        }


        if hostingController == nil {
            let host = UIHostingController(rootView: autoFillView)
            hostingController = host
            addChild(host)
            view.addSubview(host.view)

            host.view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                host.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                host.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                host.view.topAnchor.constraint(equalTo: view.topAnchor),
                host.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])

            host.didMove(toParent: self)
        } else {
            hostingController?.rootView = autoFillView
        }
        

        CryptoManager.shared.activeKey = key
    }
    

    override func prepareCredentialList(for serviceIdentifiers: [ASCredentialServiceIdentifier]) {

        currentServiceIdentifiers = serviceIdentifiers

        
        let matchedDomain = serviceIdentifiers.first(where: { $0.type == .domain })?.identifier
        if let user = loggedInUsername {
            let newRoot = AutoFillView(username: user, filterDomain: matchedDomain) { (site, password) in
                let credential = ASPasswordCredential(user: user, password: password)
                self.extensionContext.completeRequest(withSelectedCredential: credential, completionHandler: nil)
            }
            hostingController?.rootView = newRoot
        }
    }

    override func provideCredentialWithoutUserInteraction(for credentialIdentity: ASPasswordCredentialIdentity) {

        currentCredentialIdentity = credentialIdentity

        guard let username = loggedInUsername, hasActiveKey else {
            cancel(.userCanceled)
            return
        }


        let password = CryptoManager.shared.fetchPassword(for: credentialIdentity)

        if let password = password {
            let credential = ASPasswordCredential(user: username, password: password)
            self.extensionContext.completeRequest(withSelectedCredential: credential, completionHandler: nil)
        } else {

            cancel(.failed)
        }
    }

    override func prepareInterfaceToProvideCredential(for credentialIdentity: ASPasswordCredentialIdentity) {

        currentCredentialIdentity = credentialIdentity

    }
    
}
