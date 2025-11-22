import Foundation
import Argon2Swift
import CryptoKit
import AuthenticationServices

class CryptoManager {
    
    static let shared = CryptoManager()
    var activeKey: SymmetricKey?
    private init() {}
    
    func generateArgon2Hash(password: String, salt: String) -> String? {
        // 1. Convert Salt String to Data
        guard let saltData = salt.data(using: .utf8) else {
            print("Error: Could not convert salt to data")
            return nil
        }
        
        // 2. Wrap it in the library's 'Salt' type
        let saltObject = Salt(bytes: saltData)
        
        // 3. Perform the Hash
        do {
            let result = try Argon2Swift.hashPasswordString(
                password: password,
                salt: saltObject,
                iterations: 3,
                memory: 65536,
                parallelism: 1,
                length: 32,
                type: .id,
                version: .V13
            )
            
            // 4. Return the Hex String
            return result.hexString()
            
        } catch {
            print("Hashing Failed: \(error)")
            return nil
        }
    }
    
    func getKey(from hash: String) -> SymmetricKey? {
        guard let data = hash.data(using: .utf8) else {
            return nil
        }
        
        let digest = SHA256.hash(data: data)
        
        return SymmetricKey(data: digest)
    }
    
    func encrypt(text: String, key: SymmetricKey) -> String? {
        guard let textData = text.data(using: .utf8) else {
            print("Error: could not convert to data")
            return nil
        }
        guard let sealedBox = try? AES.GCM.seal(textData, using: key) else {
            print("Error: could not seal")
            return nil}
        return sealedBox.combined?.base64EncodedString()
    }
    
    func decrypt(encryptedText: String, key: SymmetricKey) -> String? {
            // 1. Decode Base64
            guard let combinedData = Data(base64Encoded: encryptedText) else {
                print("Error: could not decode base64")
                return nil
            }
            
            do {
                let box = try AES.GCM.SealedBox(combined: combinedData)
                let decryptedData = try AES.GCM.open(box, using: key)
                
                // 3. Convert Data -> String
                // TODO: Return the String using String(data: ..., encoding: ...)
                return String(data: decryptedData, encoding: .utf8)
                
            } catch {
                print("Error: decryption failed - \(error)")
                return nil
            }
        }
    
    func makeSalt(length: Int = 32) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
    func generatePassword(length: Int = 16) -> String {
        let characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ!@#$%^&*()_+"
        return String((0..<length).map{_ in characters.randomElement()!})
    }
    
    func fetchPassword(for credentialIdentity: ASPasswordCredentialIdentity) -> String? {
        // Ensure we have a key to decrypt
        guard let key = activeKey else {
            print("CryptoManager.fetchPassword: missing activeKey")
            return nil
        }

        let storageKey: String
        if let recordId = credentialIdentity.recordIdentifier, !recordId.isEmpty {
            storageKey = recordId
        } else {
            storageKey = credentialIdentity.serviceIdentifier.identifier + "::" + credentialIdentity.user
        }
        
        guard let encrypted = SharedStorage.shared.getEncryptedPassword(for: storageKey) else {
            print("CryptoManager.fetchPassword: no encrypted password for key \(storageKey)")
            return nil
        }

        // Decrypt using the active key
        return decrypt(encryptedText: encrypted, key: key)
    }
}
