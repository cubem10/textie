//
//  LoginView.swift
//  Textie
//
//  Created by 하정우 on 4/28/25.
//

import SwiftUI
import Combine

struct LoginView: View {
    @State private var credential = Credential(id: "", password: "")
    @State private var invaildCredentials = false
    @State private var showRegisterView = false
    @State private var loginFailed: Bool = false
        
    func login() throws {
        // TODO: implement login API call
        if credential.id == "test" && credential.password == "testtest" {
            invaildCredentials = true
            return
        }
        
        let account = credential.id
        let password = credential.password.data(using: String.Encoding.utf8)!
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrService as String: "Textie",
                                    kSecAttrAccount as String: account,
                                    kSecValueData as String: password]
        
        let deleteStatus = SecItemDelete(query as CFDictionary)
        guard deleteStatus == errSecSuccess || deleteStatus == errSecItemNotFound else {
            throw KeyChainError.unhandledError(status: deleteStatus)
        }
        
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeyChainError.unhandledError(status: status)
        }
    }
    
    func loadSavedCredential() {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrService as String: "Textie",
                                    kSecMatchLimit as String: kSecMatchLimitOne,
                                    kSecReturnAttributes as String: true,
                                    kSecReturnData as String: true]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        if status == errSecItemNotFound || status != errSecSuccess {
            return
        }
        
        guard let existingItem = item as? [String: Any], let passwordData = existingItem[kSecValueData as String] as? Data, let password = String(data: passwordData, encoding: String.Encoding.utf8), let account = existingItem[kSecAttrAccount as String] as? String
        else {
            return
        }
        
        credential.id = account
        credential.password = password
    }
    
    var body: some View {
        VStack {
            Text("Login to Textie")
                .font(.largeTitle)
                .fontWeight(.bold)
            IdFieldView(id: $credential.id).padding()
            Divider()
            PasswordFieldView(password: $credential.password, placeholder: "Password").padding()
            HStack {
                Button(action: {
                    do {
                        try login()
                    } catch {
                        loginFailed = true
                    }
                }) {
                    Text("Sign In")
                }.disabled(credential.id == "" || credential.password.count < 8)
                    .alert(isPresented: $invaildCredentials) {
                        Alert(title: Text("Invalid Credential"), message: Text("The username or password you entered is incorrect. Please try again."))
                    }.padding()
                Button(action: { showRegisterView.toggle() }) {
                    Text("Register")
                }.sheet(isPresented: $showRegisterView) {
                    RegisterView(showRegisterView: $showRegisterView, credential: $credential)
                        .onChange(of: showRegisterView) {
                            do {
                                try login()
                            } catch {
                                loginFailed = true
                            }
                        }
                }
                .alert(isPresented: $loginFailed) {
                    Alert(title: Text("Login Failed"), message: Text("Please try again later."))
                }
            }
        }.padding()
            .onAppear {
                loadSavedCredential()
            }
    }
}

#Preview {
    LoginView()
}
