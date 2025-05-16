//
//  ProfileImageView.swift
//  Textie
//
//  Created by 하정우 on 5/9/25.
//

import SwiftUI

struct ProfileImageView: View {
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        Image(systemName: "person.circle.fill").resizable().foregroundStyle(colorScheme == .dark ? .white : .black).clipShape(Circle())
    }
}

#Preview {
    ProfileImageView()
}
