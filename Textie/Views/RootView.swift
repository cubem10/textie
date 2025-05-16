//
//  RootView.swift
//  Textie
//
//  Created by 하정우 on 5/16/25.
//

import SwiftUI

struct RootView: View {
    @Environment(UserStateViewModel.self) var userStateViewModel
    
    var body: some View {
        Group {
            if userStateViewModel.isLoading {
                ProgressView("LOGIN_LOADING_MESSAGE")
            }
            else if userStateViewModel.isLoggedIn {
                MainView()
            } else {
                LoginView()
            }
        }
    }
}

#Preview {
    RootView()
}
