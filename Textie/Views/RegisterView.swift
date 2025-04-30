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
    @Binding var credential: Credential
    
    @State private var verifyPassword: String = ""
    @State private var declineRegister: Bool = false
    
    func register() {
        // TODO: implement register API call
        if credential.id == "test" && credential.password == "testtest" {
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
            IdFieldView(id: $credential.id).padding()
            Divider()
            PasswordFieldView(password: $credential.password, placeholder: "Password").padding()
            Divider()
            PasswordFieldView(password: $verifyPassword, placeholder: "Verify Password").padding()
            HStack {
                Button(action: register) {
                    Text("Register")
                        .disabled(credential.id == "" || credential.password.count < 8 || credential.password != verifyPassword)
                        .alert(isPresented: $declineRegister) {
                            Alert(title: Text("Register Failed"), message: Text("placeholder_failedreason"))
                        }
                }
            }
        }.padding()
        
    }
}

#Preview {
    RegisterView(showRegisterView: .constant(true), credential: .constant(Credential(id: "", password: "")))
}
