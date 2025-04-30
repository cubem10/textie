//
//  ContentView.swift
//  Textie
//
//  Created by 하정우 on 4/28/25.
//

import SwiftUI

struct ContentView: View {
    func login() throws {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                            kSecAttrService as String: "Textie",
                                            kSecMatchLimit as String: kSecMatchLimitOne,
                                            kSecReturnAttributes as String: true,
                                            kSecReturnData as String: true]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status != errSecItemNotFound else {
            throw KeyChainError.noPassword
        }
        guard status == errSecSuccess else {
            throw KeyChainError.unhandledError(status: status)
        }
    }
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
