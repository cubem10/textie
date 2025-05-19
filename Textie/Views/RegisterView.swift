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
    
    @Environment(UserStateViewModel.self) var userStateViewModel
    
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
            VStack {
                CriteriaRow(criteria: "MORE_THAN_EIGHT_CHARACTERS", satisfied: password.count >= 8).padding(.bottom, 4)
                CriteriaRow(criteria: "CONTAINS_NUMBERS", satisfied: password.rangeOfCharacter(from: CharacterSet.decimalDigits) != nil).padding(.bottom, 4)
                CriteriaRow(criteria: "CONTAINS_SPECIAL_CHARACTERS", satisfied: password.range(of: ".*[A-Za-z0-9].*", options: .regularExpression) != nil).padding(.bottom, 4)
                CriteriaRow(criteria: "MATCHES_PASSWORD", satisfied: password == verifyPassword && password.count >= 8).padding(.bottom, 4)
            }
            Button(action: { Task { try? await userStateViewModel.register(username: username, password: password, nickname: nickname, onError: { error in
                if case BackendError.existingUserRegistration = error {
                    existingUser = true
                }
            }) } }) {
                Text("REGISTER_BUTTON")
                    .disabled(username == "" || password.count < 8 || password != verifyPassword || nickname == "" || password.rangeOfCharacter(from: CharacterSet.decimalDigits) == nil || password.range(of: ".*[A-Za-z0-9].*", options: .regularExpression) == nil)
                    .alert(isPresented: $existingUser) {
                        Alert(title: Text("REGISTER_FAIL_TITLE"), message: Text("REGISTER_FAIL_DETAIL"))
                    }
            }
            
        }.padding()
        
    }
}

#Preview {
    RegisterView(showRegisterView: .constant(true), username: .constant(""), password: .constant(""), nickname: .constant("")).environment(UserStateViewModel())
}
