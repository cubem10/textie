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

enum LoginError: Error {
    case badURL
    case badEncoding
    case invaildResponse
    case invalidCredential
    case existingUserRegistration
}

func saveTokenToKeychain(token: String, key: String) -> Bool {
    let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                kSecAttrService as String: "Textie",
                                kSecAttrAccount as String: key,
                                kSecValueData as String: token.data(using: .utf8)!]

    SecItemDelete(query as CFDictionary)

    let status = SecItemAdd(query as CFDictionary, nil)
    return status == errSecSuccess
}

func getTokenFromKeychain(key: String) -> String? {
    let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                kSecAttrService as String: "Textie",
                                kSecAttrAccount as String: key,
                                kSecMatchLimit as String: kSecMatchLimitOne,
                                kSecReturnData as String: kCFBooleanTrue!]
    
    var result: AnyObject?
    let status = SecItemCopyMatching(query as CFDictionary, &result)
    
    if status == errSecSuccess, let data = result as? Data, let token = String(data: data, encoding: .utf8) {
        return token
    }
    
    return nil
}

func parseTokenResponse(encodedResponse data: Data) {
    print(String(data: data, encoding: .utf8) ?? "")
    
    var accessToken: String = ""
    var refreshToken: String = ""
    
    do {
        let decodedResponse = try JSONDecoder().decode(LoginResponse.self, from: data)
        accessToken = decodedResponse.access_token
        refreshToken = decodedResponse.refresh_token
        print("Token successfully obtained")
        
        let isAccessTokenSaved = saveTokenToKeychain(token: accessToken, key: "access_token")
        let isRefreshTokenSaved = saveTokenToKeychain(token: refreshToken, key: "refresh_token")
        
        if isAccessTokenSaved && isRefreshTokenSaved {
            print("Token saved successfully")
        } else {
            print("Failed to save tokens")
        }
    } catch {
        print("Failed to decode JSON: \(error)")
    }
}

func login(username: String, password: String) throws {
    guard let url = URL(string: serverURLString + "/signin?username=\(username)&password=\(password)") else {
        throw LoginError.badURL
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "accept")
    
    URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            print("Error: \(error.localizedDescription)")
            return
        }
        
        if let httpResponse = response as? HTTPURLResponse {
            print("Response status code: \(httpResponse.statusCode)")
        }
        
        if let data = data {
            print(String(data: data, encoding: .utf8) ?? "")
            parseTokenResponse(encodedResponse: data)
        }
    }.resume()
    
}

func register(username: String, password: String, nickname: String) throws {
    print("signup?username=\(username)&password=\(password)&nickname=\(nickname)")
    
    guard let url = URL(string: serverURLString + "/signup?username=\(username)&password=\(password)&nickname=\(nickname)") else {
        print("register: bad URL string")
        throw LoginError.badURL
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "accept")
    
    URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            print("Error: \(error.localizedDescription)")
            return
        }
        
        if let httpResponse = response as? HTTPURLResponse {
            // TODO: 500 error when user exists
            print("Response status code: \(httpResponse.statusCode)")
        }
        
        if let data = data {
            parseTokenResponse(encodedResponse: data)
        }
    }.resume()
    
    
}

func refreshSession() throws {
    var accessToken: String = ""
    
    
    guard let refreshToken = getTokenFromKeychain(key: "refresh_token") else {
        throw LoginError.invalidCredential
    }
    
    guard let url = URL(string: serverURLString + "/refresh-token?refresh_token=\(refreshToken)") else {
        throw LoginError.badURL
    }
    
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "accept")
    
    URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            print("Error: \(error.localizedDescription)")
            return
        }
        
        if let httpResponse = response as? HTTPURLResponse {
            print("Response status code: \(httpResponse.statusCode)")
        }
        
        if let data = data {
            do {
                let decodedResponse = try JSONDecoder().decode([String: String].self, from: data)
                accessToken = decodedResponse["access_token"] ?? ""
                
                
                if accessToken != "" && saveTokenToKeychain(token: accessToken, key: "access_token"){
                    print("Access Token saved successfully")
                } else {
                    print("An error occured while saving access token")
                }
            } catch {
                print("Failed to decode JSON: \(error)")
            }
        }
    }.resume()
    
}

