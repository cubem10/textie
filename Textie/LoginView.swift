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
        
    func login() {
        // TODO: implement login API call
        if credential.id == "test" && credential.password == "testtest" {
            invaildCredentials = true
        }
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
                Button(action: login) {
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
                            login()
                        }
                }
            }
        }.padding()
    }
}

#Preview {
    LoginView()
}
