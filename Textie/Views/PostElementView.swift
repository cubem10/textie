//
//  PostElementView.swift
//  Textie
//
//  Created by 하정우 on 4/30/25.
//

import SwiftUI

struct PostElementView: View {
    var name: String
    var profileImageURL: URL?
    
    var content: String
    var likes: Int
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                AsyncImage(url: profileImageURL) { image in
                    image.resizable()
                } placeholder: {
                    Image(systemName: "person.circle.fill").resizable()
                }.frame(width: 30, height: 30)
                Text(name)
            }.frame(height: 30)
            Text(content)
                .padding(.bottom)
            HStack {
                Image(systemName: "heart")
                Text(likes.formatted(.number.notation(.compactName)))
            }
        }.frame(height: 300)
        
    }
}

#Preview {
    PostElementView(name: "John Appleseed", profileImageURL: URL(string: "http://example.com/profile.jpg"), content: "Post content goes here. ", likes: 1234567890)
}
