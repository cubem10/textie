//
//  RegisterView.swift
//  Textie
//
//  Created by 하정우 on 4/28/25.
//

import SwiftUI
import Combine

struct RegisterView: View {
    @Binding var showRegisterView: Bool
    @Binding var id: String
    @Binding var password: String
    
    @State private var verifyPassword: String = ""
    @State private var declineRegister: Bool = false
    
    func register() {
        // TODO: implement register API call
        if id == "test" && password == "testtest" {
            declineRegister = true
            return
        }
        
        showRegisterView = false
    }
    
    var body: some View {
        VStack {
            Text("Register to Textie")
                .font(.largeTitle)
                .fontWeight(.bold)
            HStack {
                Image(systemName: "person")
                TextField("Username", text: $id)
                    .autocapitalization(.none)
                    .autocorrectionDisabled(true)
                    .onReceive(Just(id)) { newValue in
                        let allowedCharacters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_-."
                        let filtered = newValue.filter { allowedCharacters.contains($0) }
                        if filtered != newValue {
                            id = filtered
                        }
                    }
            }.padding()
            Divider()
            PasswordFieldView(password: $password, placeholder: "Password").padding()
            Divider()
            PasswordFieldView(password: $verifyPassword, placeholder: "Verify Password").padding()
            HStack {
                Button(action: register) {
                    Text("Register")
                        .disabled(id == "" || password.count < 8 || password != verifyPassword)
                        .alert(isPresented: $declineRegister) {
                            Alert(title: Text("Register Failed"), message: Text("placeholder_failedreason"))
                        }
                }
            }
        }.padding()
        
    }
}

#Preview {
    RegisterView(showRegisterView: .constant(true), id: .constant(""), password: .constant(""))
}
