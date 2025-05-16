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

struct UserProfileDTO: Identifiable, Decodable {
    let id: UUID
    let username: String
    let nickname: String
}
