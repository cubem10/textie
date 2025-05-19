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
    
    var uuid: UUID = UUID()
    var token: String = ""
    
    init() {
        Task {
            do {
                uuid = try await getUUID()
                guard let accessToken = getTokenFromKeychain(key: "access_token") else {
                    throw BackendError.invalidCredential
                }
                token = accessToken
                let refreshResult: Bool = try await refreshSession()
                if refreshResult {
                    isLoggedIn = true
                }
            } catch {
                // TODO: error handling
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

    private func getTokenFromKeychain(key: String) -> String? {
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

    private func parseTokenResponse(encodedResponse data: Data) -> Bool {
        var accessToken: String = ""
        var refreshToken: String = ""
        do {
            let decodedResponse = try JSONDecoder().decode(LoginResponse.self, from: data)
            accessToken = decodedResponse.access_token
            refreshToken = decodedResponse.refresh_token
            
            let isAccessTokenSaved = saveTokenToKeychain(token: accessToken, key: "access_token")
            let isRefreshTokenSaved = saveTokenToKeychain(token: refreshToken, key: "refresh_token")
            
            return isAccessTokenSaved && isRefreshTokenSaved
        } catch {
            return false
        }
    }

    @MainActor
    func login(username: String, password: String) async throws {
        isLoading = true
        defer { isLoading = false }
        
        isLoggedIn = parseTokenResponse(encodedResponse: try await sendRequestToServer(toEndpoint: serverURLString + "/signin?username=\(username)&password=\(password)", httpMethod: "POST").0)
    }

    @MainActor
    func register(username: String, password: String, nickname: String, onError: @escaping (Error) -> Void) async throws {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let response: (Data, URLResponse) = try await sendRequestToServer(toEndpoint: serverURLString + "/signup?username=\(username)&password=\(password)&nickname=\(nickname)", httpMethod: "POST")
            
            if let response = response.1 as? HTTPURLResponse, response.statusCode == 500 {
                throw BackendError.existingUserRegistration
            }
            
            isLoggedIn = parseTokenResponse(encodedResponse: response.0)
        } catch {
            onError(error)
        }
        
    }

    @MainActor
    func refreshSession() async throws -> Bool {
        isLoading = true
        defer { isLoading = false }
        
        guard let refreshToken: String = getTokenFromKeychain(key: "refresh_token") else {
            return false
        }
        
        token = refreshToken
        
        return parseTokenResponse(encodedResponse: try await sendRequestToServer(toEndpoint: serverURLString + "/refresh-token?refresh_token=\(refreshToken)", httpMethod: "POST").0)
    }
    
    func logout() async -> Bool {
        isLoading = true
        defer { isLoading = false }
        
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
        
        isLoggedIn = false
        
        return accessTokenStatus == errSecSuccess && refreshTokenStatus == errSecSuccess
    }
    
    @MainActor
    func getUUID() async throws -> UUID {
        isLoading = true
        defer { isLoading = false }
        
        guard let accessToken = getTokenFromKeychain(key: "access_token") else {
            throw BackendError.invalidCredential
        }
        
        do {
            let (response, _): (Data, URLResponse) = try await sendRequestToServer(toEndpoint: serverURLString + "/user", httpMethod: "GET", withToken: accessToken)
            let decodedResponse = try JSONDecoder().decode(UserProfileDTO.self, from: response)
            return decodedResponse.id
        }
        catch {
            throw BackendError.invalidCredential
        }
            
        
    }
}
