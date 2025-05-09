//
//  ProfileImageView.swift
//  Textie
//
//  Created by 하정우 on 5/9/25.
//

import SwiftUI

struct ProfileImageView: View {
    var body: some View {
        Image(systemName: "person.circle.fill").resizable().foregroundStyle(.black).clipShape(Circle())
    }
}

#Preview {
    ProfileImageView()
}
