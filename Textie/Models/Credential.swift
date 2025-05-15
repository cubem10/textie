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

func sendRequestToServer(toEndpoint endpoint: String, httpMethod method: String, withCredential credential: Credential = Credential(username: "", password: "")) async throws -> Data {
    guard let url = URL(string: endpoint) else {
        throw BackendError.badURL
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = method
    
    do {
        let (responseData, _): (Data, URLResponse) = try await URLSession.shared.data(for: request)
        return responseData
    } catch {
        print("An error occurred while processing the request: \(error)")
    }
    
    return Data()
}

func parseTokenResponse(encodedResponse data: Data) {
    print(String(data: data, encoding: .utf8) ?? "")
    
    var accessToken: String = ""
    var refreshToken: String = ""
    
    print("raw token response: \(String(data: data, encoding: .utf8) ?? "")")
    
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

func login(username: String, password: String) async throws {
    do {
        parseTokenResponse(encodedResponse: try await sendRequestToServer(toEndpoint: serverURLString + "/signin?username=\(username)&password=\(password)", httpMethod: "POST"))
    } catch {
        print("Failed to send login request to server: \(error)")
    }
}

func register(username: String, password: String, nickname: String) async throws {
    do {
        parseTokenResponse(encodedResponse: try await sendRequestToServer(toEndpoint: serverURLString + "/signup?username=\(username)&password=\(password)&nickname=\(nickname)", httpMethod: "POST"))
    } catch {
        print("Error parsing response: \(error)")
    }
    
}

func refreshSession() async throws {
    var accessToken: String = ""
    
    guard let refreshToken = getTokenFromKeychain(key: "refresh_token") else {
        throw BackendError.invalidCredential
    }
    
    if let data = try? await sendRequestToServer(toEndpoint: serverURLString + "/refresh-token?refresh_token=\(refreshToken)", httpMethod: "POST") {
        do {
            let decodedResponse = try JSONDecoder().decode([String: String].self, from: data)
            accessToken = decodedResponse["access_token"] ?? ""
            
            if accessToken != "" && saveTokenToKeychain(token: accessToken, key: "access_token") {
                print("Access Token saved successfully")
            } else {
                print("An error occurred while saving access token")
            }
        } catch {
            print("Failed to decode refresh token response: \(error)")
        }
    } else {
        throw BackendError.invaildResponse
    }
    
}

class APICaller {
    private var accessToken: String = ""
    
    init() {
        guard let token = getTokenFromKeychain(key: "access_token") else {
            return
        }
        
        accessToken = token
    }
}
