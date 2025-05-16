//
//  PostElementView.swift
//  Textie
//
//  Created by 하정우 on 4/30/25.
//

import SwiftUI

struct PostElementView: View {
    var postData: PostData
    @State private var showComment: Bool = false
    @State private var liked: Bool = false
    @State private var commentDatas: [CommentData] = []
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                ProfileImageView().frame(width: 30, height: 30)
                Text(postData.name)
                    .lineLimit(1)
                Text("⋅")
                Text(postData.createdAt)
                    .font(.subheadline)
            }.frame(height: 30)
                .padding(.vertical, 5)
            Text(postData.title)
                .font(.title2)
                .fontWeight(.bold)
            Text(postData.content)
                .padding(.bottom)
                .lineLimit(nil)
            HStack {
                Button(action: {
                    liked.toggle()
                }) {
                    if liked { Image(systemName: "heart.fill") }
                    else { Image(systemName: "heart") }
                }
                .foregroundStyle(.black)
                .contentShape(Rectangle())
                .background(Color.red.opacity(0.2))
                Text(postData.likes.formatted(.number.notation(.compactName)))
                    .lineLimit(1)
                Button(action: {
                    showComment.toggle()
                }) {
                    Image(systemName: "bubble")
                }.foregroundStyle(.black)
                    .contentShape(Rectangle())
                    .sheet(isPresented: $showComment) {
                        CommentListView(postId: postData.id)
                    }
            }
        }
        
    }
}

#Preview {
    PostElementView(postData: PostData(id: UUID(), name: "John Appleseed", title: "Title", createdAt: "1시간 전", content: "Post content goes here. ", likes: 1234567890))
}
