//
//  UserStateViewModel.swift
//  Textie
//
//  Created by 하정우 on 5/16/25.
//

import Foundation
import os

@Observable
class UserStateViewModel {
    var isLoggedIn: Bool = false
    var isLoading: Bool = false
    var isRetrievingUUID: Bool = false
    var showFailAlert: Bool = false
    var failDetail: String = ""
    
    var uuid: UUID = UUID()
    var token: String = ""
    
    private let logger = Logger()
    
    init() {
        Task {
            do {
                let refreshResult: Bool = await refreshSession()
                if refreshResult {
                    isLoggedIn = true
                }
                uuid = try await getUUID()
            } catch {
                logger.debug("An error occurred while initializing the app: \(error), access token found: \(self.token != "")")
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
            
            token = accessToken
            
            Task {
                uuid = try await getUUID()
            }
            
            return isAccessTokenSaved && isRefreshTokenSaved
        } catch {
            return false
        }
    }

    @MainActor
    func login(username: String, password: String) async throws {
        isLoading = true
        defer { isLoading = false }
        
        let (data, _): (Data, URLResponse) = try await sendRequestToServer(toEndpoint: serverURLString + "/signin?username=\(username)&password=\(password)", httpMethod: "POST")
        isLoggedIn = parseTokenResponse(encodedResponse: data)
        
    }

    @MainActor
    func register(username: String, password: String, nickname: String) async throws {
        isLoading = true
        defer { isLoading = false }
        
        let (data, _): (Data, URLResponse) = try await sendRequestToServer(toEndpoint: serverURLString + "/signup?username=\(username)&password=\(password)&nickname=\(nickname)", httpMethod: "POST")
        isLoggedIn = parseTokenResponse(encodedResponse: data)
        
    }

    @MainActor
    func refreshSession() async -> Bool {
        isLoading = true
        defer { isLoading = false }
        
        guard let refreshedToken: String = getTokenFromKeychain(key: "refresh_token") else {
            return false
        }
        
        do {
            let (data, _): (Data, URLResponse) = try await sendRequestToServer(toEndpoint: serverURLString + "/refresh-token?refresh_token=\(refreshedToken)", httpMethod: "POST")
            return parseTokenResponse(encodedResponse: data)
        } catch {
            failDetail = error.localizedDescription
            showFailAlert = true
            return false
        }
    }
    
    func logout() async -> Bool {
        isLoading = true
        defer { isLoading = false }
        
        let accessTokenQuery: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrService as String: "Textie",
                                    kSecAttrAccount as String: "access_token",
                                    kSecReturnData as String: kCFBooleanTrue!]
        
        let accessTokenStatus = SecItemDelete(accessTokenQuery as CFDictionary)
        
        let refreshTokenQuery: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrService as String: "Textie",
                                    kSecAttrAccount as String: "refresh_token",
                                    kSecReturnData as String: kCFBooleanTrue!]
        
        let refreshTokenStatus = SecItemDelete(refreshTokenQuery as CFDictionary)
        
        isLoggedIn = false
        
        return accessTokenStatus == errSecSuccess && refreshTokenStatus == errSecSuccess
    }
    
    @MainActor
    func getUUID() async throws -> UUID {
        isRetrievingUUID = true
        defer { isRetrievingUUID = false }
        
        guard let accessToken = getTokenFromKeychain(key: "access_token") else {
            throw BackendError.invalidCredential
        }
        
        do {
            let (response, _): (Data, URLResponse) = try await sendRequestToServer(toEndpoint: serverURLString + "/user", httpMethod: "GET", withToken: accessToken)
            let decodedResponse = try JSONDecoder().decode(UserProfileDTO.self, from: response)
            return decodedResponse.id
        }
        catch {
            if ((error as? URLError) != nil) {
                failDetail = error.localizedDescription
                showFailAlert = true
            }
            throw BackendError.invalidCredential
        }
            
        
    }
}
