import Foundation
import CryptoKit


//irrelevant without apple developer kit to test autofill features
class SharedStorage {
    
    static let shared = SharedStorage()
    
    private let appGroupId = "group.com.henry.PasswordVault"
    
    private init() {}
    
    // 1. The Shared Box
    private var sharedDefaults: UserDefaults? {
        return UserDefaults(suiteName: appGroupId)
    }
    
    // 2. Save/Load Username
    func saveUsername(_ username: String) {
        sharedDefaults?.set(username, forKey: "shared_username")
    }
    
    func getUsername() -> String? {
        return sharedDefaults?.string(forKey: "shared_username")
    }
    
    func saveKey(_ key: SymmetricKey) {
        let data = key.withUnsafeBytes { Data($0) }
        sharedDefaults?.set(data, forKey: "shared_key")
    }
    
    func getKey() -> SymmetricKey? {
        guard let data = sharedDefaults?.data(forKey: "shared_key") else { return nil }
        return SymmetricKey(data: data)
    }
    
    func saveEncryptedPassword(_ encrypted: String, for key: String) {
        sharedDefaults?.set(encrypted, forKey: "pw_" + key)
    }

    func getEncryptedPassword(for key: String) -> String? {
        return sharedDefaults?.string(forKey: "pw_" + key)
    }

    func removeEncryptedPassword(for key: String) {
        sharedDefaults?.removeObject(forKey: "pw_" + key)
    }
}
