//
//  LoginView.swift
//  Textie
//
//  Created by 하정우 on 4/28/25.
//

import SwiftUI
import Combine

struct LoginView: View {
    @State private var id = ""
    @State private var password = ""
    @State private var invaildCredentials = false
    
    func login() {
        // TODO: implement login functionality
        if id == "test" && password == "test" {
            invaildCredentials = true
        }
    }
    
    func register() {
        // TODO: implement register functionality
    }
    
    var body: some View {
        VStack {
            Text("Login to Textie")
                .font(.largeTitle)
                .fontWeight(.bold)
            HStack {
                Image(systemName: "person")
                TextField("Username", text: $id)
                    .autocapitalization(.none)
                    .onReceive(Just(id)) { newValue in
                        let allowedCharacters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_-."
                        let filtered = newValue.filter { allowedCharacters.contains($0) }
                        if filtered != newValue {
                            id = filtered
                        }
                    }
            }.padding()
            Divider()
            HStack {
                Image(systemName: "lock")
                SecureField("Password", text: $password)
            }.padding()
            HStack {
                Button(action: login) {
                    Text("Sign In")
                }.disabled(id == "" || password.count < 8)
                    .alert(isPresented: $invaildCredentials) {
                        Alert(title: Text("Invalid Credential"), message: Text("The username or password you entered is incorrect. Please try again."))
                    }.padding()
                Button(action: register) {
                    Text("Register")
                }
            }
        }.padding()
    }
}

#Preview {
    LoginView()
}
