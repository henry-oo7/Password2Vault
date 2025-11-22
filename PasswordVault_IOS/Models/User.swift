//
//  User.swift
//  PasswordVault
//
//  Created by henryMac on 11/19/25.
//

import Foundation

public struct User: Codable {
    public var username: String
    public var salt: String?
    public var authHash: String?
}
