//
//  AppEnums.swift
//  PasswordVault
//
//  Created by henryMac on 11/20/25.
//

enum ActiveAlert {
    case missingSalt
    case loginFailed
    case hashingFailed
    case serverRejection
}

enum Page {
    case welcome, login, register, vault
}

