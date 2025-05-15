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
    @State private var existingUser: Bool = false
    
    var body: some View {
        VStack {
            Text("REGISTER_MAIN_TEXT")
                .font(.largeTitle)
                .fontWeight(.bold)
            IdFieldView(id: $username).padding()
            Divider()
            PasswordFieldView(password: $password, placeholder: "PASSWORD_PLACEHOLDER").padding()
            Divider()
            PasswordFieldView(password: $verifyPassword, placeholder: "PASSWORD_VERIFY_PLACEHOLDER").padding()
            Divider()
            NicknameFieldView(nickname: $nickname).padding()
            HStack {
                Button(action: { Task { try? await register(username: username, password: password, nickname: nickname, onError: { error in
                    if case BackendError.existingUserRegistration = error {
                        existingUser = true
                    }
                }) } }) {
                    Text("REGISTER_BUTTON")
                        .disabled(username == "" || password.count < 8 || password != verifyPassword || nickname == "")
                        .alert(isPresented: $existingUser) {
                            Alert(title: Text("REGISTER_FAIL_TITLE"), message: Text("REGISTER_FAIL_DETAIL"))
                        }
                }
            }
        }.padding()
        
    }
}

#Preview {
    RegisterView(showRegisterView: .constant(true), username: .constant(""), password: .constant(""), nickname: .constant(""))
}
