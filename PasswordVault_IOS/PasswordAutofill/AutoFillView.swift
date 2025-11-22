import SwiftUI

struct AutoFillView: View {
    @State private var vaultEntries = [VaultEntry]()
    let username: String
    let filterDomain: String?
    
    // This closure sends the selected User/Pass back to the Controller
    var selectionHandler: ((String, String) -> Void)
    
    func loadData() {
        APIService().getVault(username: username) { result in
            if let result = result {
                DispatchQueue.main.async {
                    self.vaultEntries = result
                }
            }
        }
    }
    
    func getDecryptedData(entry: VaultEntry) -> (site: String, pass: String)? {
        guard let key = CryptoManager.shared.activeKey else { return nil }
        guard let decryptedString = CryptoManager.shared.decrypt(encryptedText: entry.encryptedData, key: key) else { return nil }
        
        let components = decryptedString.split(separator: ":", maxSplits: 1).map { String($0) }
        if components.count == 2 {
            let site = components[0].trimmingCharacters(in: .whitespacesAndNewlines)
            let pass = components[1].trimmingCharacters(in: .whitespacesAndNewlines)
            return (site: site, pass: pass)
        }
        return nil
    }
    
    var body: some View {
        Group {
            if vaultEntries.isEmpty {
                VStack(spacing: 12) {
                    ProgressView()
                    Text("Loading credentials…")
                        .foregroundColor(.secondary)
                        .font(.footnote)
                }
            } else {
                List(vaultEntries, id: \.id) { entry in
                    if let data = getDecryptedData(entry: entry) {
                        if filterDomain == nil || data.site.localizedCaseInsensitiveContains(filterDomain!) {
                            Button(action: {
                                selectionHandler(data.site, data.pass)
                            }) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(data.site)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    Text("Tap to fill")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
        .onAppear { loadData() }
    }
}
