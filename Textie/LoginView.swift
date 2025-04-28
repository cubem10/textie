//
//  LoginView.swift
//  Textie
//
//  Created by 하정우 on 4/28/25.
//

import SwiftUI
import Combine

struct Credentials {
    var id: String
    var password: String
}



struct LoginView: View {
    @State private var id = ""
    @State private var password = ""
    @State private var invaildCredentials = false
    @State private var showRegisterView = false
        
    func login() {
        // TODO: implement login API call
        if id == "test" && password == "testtest" {
            invaildCredentials = true
        }
    }
    
    var body: some View {
        VStack {
            Text("Login to Textie")
                .font(.largeTitle)
                .fontWeight(.bold)
            IdFieldView(id: $id).padding()
            Divider()
            PasswordFieldView(password: $password, placeholder: "Password").padding()
            HStack {
                Button(action: login) {
                    Text("Sign In")
                }.disabled(id == "" || password.count < 8)
                    .alert(isPresented: $invaildCredentials) {
                        Alert(title: Text("Invalid Credential"), message: Text("The username or password you entered is incorrect. Please try again."))
                    }.padding()
                Button(action: { showRegisterView.toggle() }) {
                    Text("Register")
                }.sheet(isPresented: $showRegisterView) {
                    RegisterView(showRegisterView: $showRegisterView, id: $id, password: $password)
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
