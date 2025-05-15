//
//  TextieApp.swift
//  Textie
//
//  Created by 하정우 on 4/28/25.
//

import SwiftUI

@main
struct TextieApp: App {
    
    var body: some Scene {
        WindowGroup {
            if let accessToken = getTokenFromKeychain(key: "access_token"), accessToken != "" {
                PostListView()
            } else {
                LoginView()
            }
        }
    }
}
