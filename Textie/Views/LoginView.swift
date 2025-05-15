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

    
    
    var body: some View {
        VStack {
            Text("Login to Textie")
                .font(.largeTitle)
                .fontWeight(.bold)
            IdFieldView(id: $username).padding()
            Divider()
            PasswordFieldView(password: $password, placeholder: "Password").padding()
            HStack {
                Button(action: {
                    Task {
                        do {
                            try await login(username: username, password: password)
                        } catch {
                            loginFailed = true
                        }
                    }
                }) {
                    Text("Sign In")
                }.disabled(username == "" || password.count < 8)
                    .alert(isPresented: $invaildCredentials) {
                        Alert(title: Text("Invalid Credential"), message: Text("The username or password you entered is incorrect. Please try again."))
                    }.padding()
                Button(action: { showRegisterView.toggle() }) {
                    Text("Register")
                }.sheet(isPresented: $showRegisterView) {
                    RegisterView(showRegisterView: $showRegisterView, username: $username, password: $password, nickname: $nickname)
                        .onChange(of: showRegisterView) {
                            Task {
                                do {
                                    try await login(username: username, password: password)
                                } catch {
                                    loginFailed = true
                                }
                            }
                        }
                }
                .alert(isPresented: $loginFailed) {
                    Alert(title: Text("Login Failed"), message: Text("Please try again later."))
                }
            }
        }.padding()
            .onAppear() {
                
            }
    }
}

#Preview {
    LoginView()
}
