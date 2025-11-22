//
//  APIService.swift
//  PasswordVault
//
//  Created by henryMac on 11/19/25.
//

import Foundation

public class APIService {
    
    let baseURL = "http://localhost:8080"
    
    func register(user: User, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(baseURL)/users/register") else { return }
        

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = try? JSONEncoder().encode(user)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("Status code: \(httpResponse.statusCode)")
                
                if httpResponse.statusCode == 200 {
                    completion(true)
                    print("Successfully registered")
                }
                else {
                    completion(false)
                    print("Failure: Server rejected registration")
                }
            }
        }.resume() 
    }
    
    func login(user: User, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(baseURL)/users/login") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = try? JSONEncoder().encode(user)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            if let error = error {
                print("Error: \(error.localizedDescription)")
                completion(false)
                
            }
            
            if let data = data, let httpResponse = response as? HTTPURLResponse {
                print("Status code: \(httpResponse.statusCode)")
                
                if httpResponse.statusCode == 200 {
                    completion(true)
                }
                else {
                    completion(false)
                }
            }
        }.resume()
    }
    
    func getSalt(username: String, completion: @escaping (String?) -> Void) {
        guard let url = URL(string: "\(baseURL)/users/\(username)/salt") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            if let error = error {
                print("Error: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            if let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 {
                let saltString = String(data: data, encoding: .utf8)
                completion(saltString)
            }
            else {
                print("Failure: Salt not found")
                completion(nil)
            }
        }.resume()
    }
    
    func getVault(username: String, completion: @escaping (([VaultEntry]?) -> Void)) {
        guard let url = URL(string: "\(baseURL)/vault/\(username)") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            if let error = error {
                
                print("Error: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            if let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 {
                let vaultEntries = try? JSONDecoder().decode([VaultEntry].self, from: data)
                completion(vaultEntries)
            }
            else {
                print("Failure: Vault entries not found")
                completion(nil)
            }
        }.resume()
    }
    
    func addVaultEntry(username: String, entry: VaultEntry, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(baseURL)/vault/\(username)") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = try? JSONEncoder().encode(entry)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            if let error = error {
                print("Error: \(error.localizedDescription)")
                completion(false)
                return
            }
            if let response = response as? HTTPURLResponse, response.statusCode == 200 {
                completion(true)
            }
            else {
                print("Failure: Failed to add vault entry")
                completion(false)
            }
        }.resume()
    }
    
    func deleteVaultEntry(username: String, id: Int, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(baseURL)/vault/\(username)/\(id)") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            if let error = error {
                print("Error: \(error.localizedDescription)")
                completion(false)
                return
            }
            if let response = response as? HTTPURLResponse, response.statusCode == 200 {
                completion(true)
            }
            else {
                print("Failure: Failed to delete vault entry")
                completion(false)
            }
        }.resume()
    }
}
