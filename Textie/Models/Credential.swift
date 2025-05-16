//
//  Credential.swift
//  Textie
//
//  Created by 하정우 on 4/28/25.
//

import Foundation
import SwiftUI

let serverURLString = "http://210.117.237.78:8001"

@Observable
class UserSession {
    var username: String = ""
    var token: String = ""
}

struct Credential: Codable {
    var username: String
    var password: String
}

struct LoginResponse: Codable {
    var access_token: String
    var refresh_token: String
}

enum KeyChainError: Error {
    case noPassword
    case unexpectedPasswordData
    case unhandledError(status: OSStatus)
}

enum BackendError: Error {
    case badURL
    case badEncoding
    case invaildResponse
    case invalidCredential
    case existingUserRegistration
}
