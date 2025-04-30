//
//  Credential.swift
//  Textie
//
//  Created by 하정우 on 4/28/25.
//

import Foundation
import SwiftUI

@Observable
class UserSession {
    var id: String = ""
    var token: String = ""
}

struct Credential {
    var id: String
    var password: String
}

enum KeyChainError: Error {
    case noPassword
    case unexpectedPasswordData
    case unhandledError(status: OSStatus)
}

extension Binding where Value == Credential {
    var id: Binding<String> {
        Binding<String>(
            get: { self.wrappedValue.id },
            set: { self.wrappedValue.id = $0}
        )
    }
    var password: Binding<String> {
        Binding<String>(
            get: { self.wrappedValue.password },
            set: { self.wrappedValue.password = $0}
        )
    }
}
