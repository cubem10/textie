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
    @Binding var username: String
    @Binding var password: String
    @Binding var nickname: String
    
    @State private var verifyPassword: String = ""
    @State private var declineRegister: Bool = false
    
    var body: some View {
        VStack {
            Text("Register to Textie")
                .font(.largeTitle)
                .fontWeight(.bold)
            IdFieldView(id: $username).padding()
            Divider()
            PasswordFieldView(password: $password, placeholder: "Password").padding()
            Divider()
            PasswordFieldView(password: $verifyPassword, placeholder: "Verify Password").padding()
            Divider()
            NicknameFieldView(nickname: $nickname).padding()
            HStack {
                Button(action: { Task { try? await register(username: username, password: password, nickname: nickname) } }) {
                    Text("Register")
                        .disabled(username == "" || password.count < 8 || password != verifyPassword || nickname == "")
                        .alert(isPresented: $declineRegister) {
                            Alert(title: Text("Register Failed"), message: Text("placeholder_failedreason"))
                        }
                }
            }
        }.padding()
        
    }
}

#Preview {
    RegisterView(showRegisterView: .constant(true), username: .constant(""), password: .constant(""), nickname: .constant(""))
}
