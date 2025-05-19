//
//  LoginView.swift
//  Textie
//
//  Created by 하정우 on 4/28/25.
//

import SwiftUI
import Combine

struct LoginView: View {
    @State private var username = ""
    @State private var password = ""
    @State private var nickname = ""
    
    @State private var invaildCredentials = false
    @State private var showRegisterView = false
    @State private var loginFailed: Bool = false

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
                        do {
                            try await userStateViewModel.login(username: username, password: password)
                        } catch {
                            loginFailed = true
                        }
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
                                do {
                                    try await userStateViewModel.login(username: username, password: password)
                                } catch {
                                    loginFailed = true
                                }
                            }
                        }
                }
                .alert(isPresented: $loginFailed) {
                    Alert(title: Text("LOGIN_FAIL"), message: Text("LOGIN_FAIL_DETAIL"))
                }
                .alert(isPresented: $invaildCredentials) {
                    Alert(title: Text("INVALID_CREDENTIAL"), message: Text("INVAILD_CREDENTIAL_DETAILS"))
                }
            }
        }.padding()
            .onAppear() {
                
            }
    }
}

#Preview {
    LoginView().environment(UserStateViewModel())
}
