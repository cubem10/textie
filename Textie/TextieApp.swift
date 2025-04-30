//
//  TextieApp.swift
//  Textie
//
//  Created by 하정우 on 4/28/25.
//

import SwiftUI

@main
struct TextieApp: App {
    @State private var userSession = UserSession()
    
    var body: some Scene {
        WindowGroup {
//            LoginView()
//                .environment(userSession)
            ProfileView()
        }
    }
}
