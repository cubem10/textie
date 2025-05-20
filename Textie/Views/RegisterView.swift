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
    
    @State private var registerFailDetail: String = ""
    @State private var showAlert: Bool = false
    
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
                CriteriaRow(criteria: "CONTAINS_SPECIAL_CHARACTERS", satisfied: password.rangeOfCharacter(from: CharacterSet(charactersIn:"!@#$%^&*()-_=+[{]}\\|;:'\",<.>/?`~")) != nil).padding(.bottom, 4)
                CriteriaRow(criteria: "MATCHES_PASSWORD", satisfied: password == verifyPassword && password.count >= 8).padding(.bottom, 4)
            }
            Button(action: {
                Task {
                    do {
                        try await userStateViewModel.register(username: username, password: password, nickname: nickname)
                    } catch {
                        if let error = error as? BackendError {
                            registerFailDetail = error.localizedDescription
                            if case .invalidResponse(let statusCode) = error, statusCode == 500 {
                                registerFailDetail = String(localized: "EXISTING_USER_DETAIL")
                            }
                            else {
                                registerFailDetail = error.localizedDescription
                            }
                            showAlert = true
                        }
                    }
                }
            }) {
                Text("REGISTER_BUTTON")
                    .disabled(username == "" || password.count < 8 || password != verifyPassword || nickname == "" || password.rangeOfCharacter(from: CharacterSet.decimalDigits) == nil || password.rangeOfCharacter(from: CharacterSet(charactersIn:"!@#$%^&*()-_=+[{]}\\|;:'\",<.>/?`~")) == nil)
            }
            if userStateViewModel.isLoading {
                ProgressView("REGISTER_LOADING_TEXT")
            }
        }.padding()
            .alert("REGISTER_FAIL_TITLE", isPresented: $showAlert, actions: { }, message: {
                Text(registerFailDetail)
            })
        
    }
}

#Preview {
    RegisterView(showRegisterView: .constant(true), username: .constant(""), password: .constant(""), nickname: .constant("")).environment(UserStateViewModel())
}
