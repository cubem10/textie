//
//  UserStateViewModel.swift
//  Textie
//
//  Created by 하정우 on 5/16/25.
//

import Foundation

@Observable
class UserStateViewModel {
    var isLoggedIn: Bool = false
    var isLoading: Bool = false
    
    init() {
        Task {
            isLoading = true
            defer { isLoading = false }
            
            do {
                let refreshResult: Bool = try await refreshSession()
                if refreshResult {
                    isLoggedIn = true
                    print("Session refreshed, user is logged in. isLoggined: \(isLoggedIn)")
                }
            } catch {
                print("An error occurred while refreshing session: \(error)")
            }
        }
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

    private func parseTokenResponse(encodedResponse data: Data) {
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

    func login(username: String, password: String) async throws {
        do {
            parseTokenResponse(encodedResponse: try await sendRequestToServer(toEndpoint: serverURLString + "/signin?username=\(username)&password=\(password)", httpMethod: "POST").0)
            await MainActor.run {
                isLoading = true
                defer { isLoading = false }
                
                isLoggedIn = true
            }
        } catch {
            print("Failed to send login request to server: \(error)")
        }
    }

    func register(username: String, password: String, nickname: String, onError: @escaping (Error) -> Void) async throws {
        do {
            let response: (Data, URLResponse) = try await sendRequestToServer(toEndpoint: serverURLString + "/signup?username=\(username)&password=\(password)&nickname=\(nickname)", httpMethod: "POST")
            
            if let response = response.1 as? HTTPURLResponse, response.statusCode == 500 {
                print("User already exists with this username, response code \(response.statusCode)")
                throw BackendError.existingUserRegistration
            }
            
            parseTokenResponse(encodedResponse: response.0)
            
            await MainActor.run {
                isLoading = true
                defer { isLoading = false }
                
                isLoggedIn = true
            }
        } catch {
            onError(error)
        }
        
    }

    func refreshSession() async throws -> Bool {
        var accessToken: String = ""
        
        guard let refreshToken = getTokenFromKeychain(key: "refresh_token") else {
            throw BackendError.invalidCredential
        }
        
        if let data = try? await sendRequestToServer(toEndpoint: serverURLString + "/refresh-token?refresh_token=\(refreshToken)", httpMethod: "POST").0 {
            do {
                let decodedResponse = try JSONDecoder().decode([String: String].self, from: data)
                accessToken = decodedResponse["access_token"] ?? ""
                
                if accessToken != "" && saveTokenToKeychain(token: accessToken, key: "access_token") {
                    print("Access Token saved successfully")
                    return true
                } else {
                    print("An error occurred while saving access token")
                    return false
                }
            } catch {
                print("Failed to decode refresh token response: \(error)")
                return false
            }
        } else {
            throw BackendError.invaildResponse
        }
        
    }
    
    func logout() async -> Bool {
        let accessTokenQuery: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrService as String: "Textie",
                                    kSecAttrAccount as String: "access_token",
                                    kSecMatchLimit as String: kSecMatchLimitOne,
                                    kSecReturnData as String: kCFBooleanTrue!]
        
        let accessTokenStatus = SecItemCopyMatching(accessTokenQuery as CFDictionary, nil)
        
        let refreshTokenQuery: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrService as String: "Textie",
                                    kSecAttrAccount as String: "refresh_token",
                                    kSecMatchLimit as String: kSecMatchLimitOne,
                                    kSecReturnData as String: kCFBooleanTrue!]
        
        let refreshTokenStatus = SecItemCopyMatching(refreshTokenQuery as CFDictionary, nil)
        
        await MainActor.run {
            isLoading = true
            defer { isLoading = false }
            
            isLoggedIn = false
        }
        
        return accessTokenStatus == errSecSuccess && refreshTokenStatus == errSecSuccess
    }
}
