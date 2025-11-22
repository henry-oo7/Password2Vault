import SwiftUI

struct VaultView: View {
    @State private var vaultEntries = [VaultEntry]()
    @State private var showAddSheet = false
    let username: String
    @Binding public var currentPage: Page
    @State private var showCopyMessage: Bool = false
    
    // Helper function to fetch data
    func loadData() {
        print("Fetching latest vault data...")
        APIService().getVault(username: self.username) { result in
            if let result = result {
                DispatchQueue.main.async {
                    self.vaultEntries = result
                }
            }
        }
    }
    
    func deleteEntry(at offset: IndexSet) {
        for index in offset {
            let entryToDelete = vaultEntries[index]
            
            if let id = entryToDelete.id {
                APIService().deleteVaultEntry(username: username, id: id) {sucess in
                    if sucess {
                        loadData()
                    }
                    else {
                        print("Error: failed to delete entry")
                    }
                }
            }
        }
    }
    
    func getDecryptedData(entry: VaultEntry) -> (site: String, password: String)? {
        guard let key = CryptoManager.shared.activeKey else {
            return nil
        }
        
        guard let decryptedData = CryptoManager.shared.decrypt(encryptedText: entry.encryptedData, key: key) else {
            return nil
        }
        
        let components = decryptedData.split(separator: ":", maxSplits: 1)
        if components.count == 2 {
            return (site: String(components[0]), password: String(components[1]))
        }
        return nil
    }
    
    
    var body: some View {
        NavigationStack {
            List{
                ForEach(vaultEntries, id: \.id) {entry in
                    VStack(alignment: .leading) {
                        if let data = getDecryptedData(entry: entry) {
                            VaultRow(site: data.site, password: data.password) {
                                withAnimation {
                                    self.showCopyMessage = true
                                }
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                    withAnimation {
                                        self.showCopyMessage = false
                                    }
                                }
                            }
                        }
                        else {
                            Text("Entry ID: \(entry.id ?? 0)")
                                .font(.headline)
                            Text(entry.encryptedData)
                                .font(.caption)
                                .lineLimit(1)
                        }
                    }
                }
                .onDelete(perform: deleteEntry)
            }
            .onAppear {
                loadData() // Call the helper function
            }
            .onChange(of: showAddSheet) { oldValue, newValue in
                if !newValue {
                    loadData()
                }
            }
            .toolbar {
                // Fixed Button Syntax
                Button(action: {
                    showAddSheet = true
                }) {
                    Image(systemName: "plus")
                }
            }
            .navigationTitle("\(username)'s Vault")
            .overlay {
                if showCopyMessage {
                    Text("Copied to Clipboard")
                        .padding()
                        .background(Color.black.opacity(0.6))
                        .foregroundColor(Color.white)
                        .cornerRadius(10)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .animation(.easeInOut, value: showCopyMessage)
                }
            }
        }
        
        Button(action: {
            DispatchQueue.main.async {
                self.currentPage = .welcome
            }
        }) {
            Text("Log out")
                .foregroundColor(.white)
                .frame(width: 200, height: 50)
                .background(Color.blue)
                .cornerRadius(10)
        }
        .sheet(isPresented: $showAddSheet) {
            AddPasswordView(username: self.username)
        }
    }
}

struct VaultRow: View {
    let site: String
    let password: String
    let onCopy: () -> Void 
    
    @State private var isSecured: Bool = true
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(site)
                .font(.headline)
            
            HStack {
                if isSecured {
                    Text("••••••••")
                        .onTapGesture {
                            // 1. Copy to Clipboard here
                            UIPasteboard.general.string = password
                            
                            // 2. Tell the Parent to show the message
                            onCopy()
                        }
                } else {
                    Text(password)
                        .font(.body) // Make it look clickable
                        .foregroundColor(.blue)
                        .onTapGesture {
                            // 1. Copy to Clipboard here
                            UIPasteboard.general.string = password
                            
                            // 2. Tell the Parent to show the message
                            onCopy()
                        }
                }
                
                Spacer()
                
                Button(action: {
                    isSecured.toggle()
                }) {
                    Image(systemName: isSecured ? "eye" : "eye.slash")
                        .foregroundColor(.gray)
                }
                .buttonStyle(BorderedButtonStyle())
            }
            .font(.caption)
        }
        .padding(.vertical, 4) // Add a little breathing room
    }
}
