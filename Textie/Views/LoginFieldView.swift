//
//  LoginFieldView.swift
//  Textie
//
//  Created by 하정우 on 4/28/25.
//

import SwiftUI

struct IdFieldView: View {
    let allowedIdPattern = "^[A-Za-z0-9_.-]*$"
    @Binding var id: String
    
    func isValidID(_ input: String) -> Bool {
        guard let regex = try? Regex(allowedIdPattern) else {
            return false
        }
        
        return input.wholeMatch(of: regex) != nil
    }
    
    var body: some View {
        HStack {
            Image(systemName: "person")
            TextField("USERNAME_PLACEHOLDER", text: $id)
                .textContentType(.username)
                .autocapitalization(.none)
                .autocorrectionDisabled(true)
                .onChange(of: id) { _, newValue in
                    if !isValidID(newValue) {
                        id = String(id.dropLast(1))
                    }
                }
        }
    }
}

struct PasswordFieldView: View {
    @Binding var password: String
    var placeholder: LocalizedStringKey
    
    var body: some View {
        HStack {
            Image(systemName: "lock")
            SecureField(placeholder, text: $password)
                .textContentType(.password)
        }
    }
}

struct NicknameFieldView: View {
    @Binding var nickname: String
    
    var body: some View {
        HStack {
            Image(systemName: "person")
            TextField("NICKNAME_PLACEHOLDER", text: $nickname)
                .textContentType(.username)
                .autocapitalization(.none)
                .autocorrectionDisabled(true)
        }
    }
}

#Preview("IdFieldView") {
    IdFieldView(id: .constant(""))
}

#Preview("PasswordFieldView") {
    PasswordFieldView(password: .constant(""), placeholder: "Password")
}
