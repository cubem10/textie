//
//  ProfileEditView.swift
//  Textie
//
//  Created by 하정우 on 4/30/25.
//

import SwiftUI

struct ProfileEditView: View {
    @Binding var profile: UserProfile
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        Button("Dismiss") {
            dismiss()
        }
    }
}

#Preview {
    @Previewable @State var profile = UserProfile(name: "John Appleseed", userId: "johnappleseed", bio: "This is my profile. ", profileImageURL: nil, birthDate: Date(timeIntervalSince1970: 0))
    
    ProfileEditView(profile: $profile)
}
