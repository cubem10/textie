//
//  CommentElementView.swift
//  Textie
//
//  Created by 하정우 on 5/9/25.
//

import SwiftUI

struct CommentElementView: View {
    var commentData: CommentData
    
    var body: some View {
        HStack {
            ProfileImageView()
                .frame(width: 44, height: 44)
            VStack(alignment: .leading) {
                Text(commentData.name)
                    .font(.headline)
                Text(commentData.content)
                    .font(.body)
            }
            Spacer()
        }.padding()
    }
}

#Preview {
    CommentElementView(commentData: CommentData(id: UUID(), name: "John", profileImageURL: URL(string: "https://example.com/john.jpg")!, content: "placeholder text"))
}
