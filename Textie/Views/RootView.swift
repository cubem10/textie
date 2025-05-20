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
        @Bindable var userStateViewModel: UserStateViewModel = userStateViewModel
        
        Group {
            if userStateViewModel.isRetrievingUUID {
                ProgressView("LOGIN_LOADING_MESSAGE")
            }
            else if userStateViewModel.isLoggedIn {
                MainView()
            } else {
                LoginView()
            }
        }.alert("NETWORK_ERROR_TITLE", isPresented: $userStateViewModel.showFailAlert, actions: { }, message: {
            Text(userStateViewModel.failDetail)
        })
    }
}

#Preview {
    RootView().environment(UserStateViewModel())
}
