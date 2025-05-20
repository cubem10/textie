//
//  LoginView.swift
//  Textie
//
//  Created by 하정우 on 4/28/25.
//

import SwiftUI
import Combine
import os

struct LoginView: View {
    @State private var username = ""
    @State private var password = ""
    @State private var nickname = ""
    
    @State private var showRegisterView = false

    @State private var alertMessage: String = ""
    
    @State private var showAlert: Bool = false

    private var logger = Logger()
    
    @Environment(UserStateViewModel.self) var userStateViewModel
    
    var body: some View {
        VStack {
            Text("LOGIN_MAIN_TEXT")
                .font(.largeTitle)
                .fontWeight(.bold)
            IdFieldView(id: $username).padding()
            Divider()
            PasswordFieldView(password: $password, placeholder: "PASSWORD_PLACEHOLDER").padding()
            HStack {
                Button(action: {
                    Task {
                        await login(username: username, password: password)
                    }
                }) {
                    Text("SIGNIN_BUTTON")
                }.padding().disabled(username == "" || password.count < 8)
                Button(action: { showRegisterView.toggle() }) {
                    Text("REGISTER_BUTTON")
                }.sheet(isPresented: $showRegisterView) {
                    RegisterView(showRegisterView: $showRegisterView, username: $username, password: $password, nickname: $nickname)
                        .onChange(of: showRegisterView) {
                            Task {
                                await login(username: username, password: password)
                            }
                        }
                }
            }
            if userStateViewModel.isLoading {
                ProgressView("LOGIN_LOADING_MESSAGE")
            }
        }.padding()
            .alert("LOGIN_FAIL", isPresented: $showAlert, actions: { }, message: {
                Text(alertMessage)
            })
    }
    
    private func login(username: String, password: String) async {
        do {
            try await userStateViewModel.login(username: username, password: password)
        } catch {
            if let error = error as? BackendError {
                if case .invalidResponse(let statusCode) = error, statusCode == 400 {
                    logger.debug("/signin endpoint returned status code \(statusCode)")
                    alertMessage = String(localized: "INVALID_CREDENTIAL_DETAILS")
                }
            } else {
                alertMessage = error.localizedDescription
            }
            showAlert = true
        }
    }
}

#Preview {
    LoginView().environment(UserStateViewModel())
}
