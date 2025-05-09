//
//  UserProfile.swift
//  Textie
//
//  Created by 하정우 on 4/30/25.
//

import Foundation

struct UserProfile: Identifiable {
    let id: UUID
    var name: String
    var userId: String
}

@Observable
class ProfileManager {
    var profile: UserProfile?
    
    func loadProfile(_ userSession: UserSession) {
        // TODO: implement profile loading API call
    }
}
