//
//  UserProfile.swift
//  Textie
//
//  Created by 하정우 on 4/30/25.
//

import Foundation

struct UserProfile {
    var name: String
    var userId: String

    var bio: String
    var profileImageURL: URL?
    var birthDate: Date
}

@Observable
class ProfileManager {
    var profile: UserProfile?
    
    func loadProfile(_ userSession: UserSession) {
        // TODO: implement profile loading API call
    }
}
