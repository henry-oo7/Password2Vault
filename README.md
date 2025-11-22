#Zero-Knowledge Password Vault 🔐
A self-hosted, full-stack password manager designed with a Zero-Knowledge Architecture. This project ensures that the server never sees the user's master password or decrypted data. All encryption and decryption happen strictly on the client side (iOS), utilizing military-grade cryptography.

#🏗 Architecture
This project uses a "blind" server model. The backend acts as a secure storage locker, while the client (iOS) holds the keys.

Client (iOS): Handles user input, Argon2 key derivation, and AES-256-GCM encryption.

Server (Java Spring Boot): REST API that stores user metadata (Salts) and encrypted data blobs.

Database (MySQL): Relational storage running in a Docker container on a NAS.

#🛠 Tech Stack
iOS Client
Language: Swift 5.9

Framework: SwiftUI

Cryptography: CryptoKit (AES-GCM) + Argon2Swift (Key Derivation)

Architecture: MVVM-style with Service Layer pattern.

Backend API
Language: Java 24

Framework: Spring Boot 3 (Web, Security, Data JPA)

Build Tool: Gradle

Database: MySQL 9.5 (Dockerized)

#🛡 Security Implementation
The core philosophy is Zero-Knowledge. Here is the cryptographic flow:

Registration:

Device generates a random 32-byte Salt.

Device runs Argon2id (Memory-hard KDF) on (Master Password + Salt) to generate the Auth Hash and Encryption Key.

Device sends only the Salt and Auth Hash to the server. The Encryption Key stays in RAM.

Login:

Device requests Salt for the username.

Device re-calculates the Auth Hash.

Server validates the hash. If correct, it returns the encrypted vault.

Data Storage:

All passwords are encrypted using AES-256-GCM before leaving the device.

The database only stores Base64 encoded ciphertext.

#✨ Features
Secure Authentication: Custom challenge-response login using Argon2id.

Vault Management: View, Add, and Delete passwords securely.

Local Decryption: Data is decrypted on-the-fly using the session key.

Password Generator: Built-in tool to generate strong, random alphanumeric passwords.

Clipboard Integration: Tap-to-copy functionality with auto-clearing security (UI fade).

Privacy Mode: Passwords are masked by default; toggle visibility with a secure eye icon.

#🚀 Getting Started
1. Backend Setup
The backend requires a MySQL database running (preferably via Docker).

Bash

Run MySQL Container
docker run --name password-db -e MYSQL_ROOT_PASSWORD=secret -e MYSQL_DATABASE=password_vault -p 3306:3306 -d mysql:latest
Configure src/main/resources/application.properties:

Properties

spring.datasource.url=jdbc:mysql://localhost:3306/password_vault
spring.datasource.username=root
spring.datasource.password=secret
Run the server:

Bash

./gradlew bootRun
2. iOS Client Setup
Open PasswordVault.xcodeproj in Xcode.

Ensure the Argon2Swift package dependency is installed.

Open Services/APIService.swift.

Update let baseURL to point to your backend IP (e.g., http://localhost:8080 or your NAS IP).

Build and Run on Simulator or Device.

#🔮 Future Roadmap
Chrome Extension: JavaScript client for desktop access.

Biometrics: FaceID integration to unlock the encryption key from the Keychain.

Offline Support: Caching encrypted blobs using CoreData/UserDefaults.

Data Sync: WebSocket implementation for real-time vault updates across devices.

Scalable features: NA

#⚖️ License
This project is for educational purposes.
