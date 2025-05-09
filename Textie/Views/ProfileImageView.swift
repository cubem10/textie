//
//  ProfileImageView.swift
//  Textie
//
//  Created by 하정우 on 5/9/25.
//

import SwiftUI

struct ProfileImageView: View {
    var imageURL: URL?
    
    var body: some View {
        AsyncImage(url: imageURL) { image in
            image.resizable()
        } placeholder: {
            Image(systemName: "person.circle.fill").resizable().foregroundStyle(.black)
        }.clipShape(Circle())
    }
}

#Preview {
    ProfileImageView()
}
