//
//  PostElementView.swift
//  Textie
//
//  Created by 하정우 on 4/30/25.
//

import SwiftUI

struct PostElementView: View {
    var postData: PostData
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                AsyncImage(url: postData.profileImageURL) { image in
                    image.resizable()
                } placeholder: {
                    Image(systemName: "person.circle.fill").resizable()
                }.frame(width: 30, height: 30)
                Text(postData.name)
                    .lineLimit(1)
            }.frame(height: 30)
                .padding(.vertical, 5)
            Text(postData.content)
                .padding(.bottom)
                .lineLimit(nil)
            HStack {
                Image(systemName: "heart")
                Text(postData.likes.formatted(.number.notation(.compactName)))
                    .lineLimit(1)
            }
        }
        
    }
}

#Preview {
    PostElementView(postData: PostData(id: UUID(), name: "John Appleseed", profileImageURL: URL(string: "http://example.com/profile.jpg"), content: "Post content goes here. ", likes: 1234567890))
}
