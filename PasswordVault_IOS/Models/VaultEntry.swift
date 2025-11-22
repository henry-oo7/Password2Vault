//
//  VaultEntry.swift
//  PasswordVault
//
//  Created by henryMac on 11/19/25.
//

import Foundation

public struct VaultEntry: Codable {
    public var id: Int?
    public var encryptedData: String
}
