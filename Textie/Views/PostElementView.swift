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
            }.frame(height: 30)
                .padding(.vertical, 5)
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
                Text(postData.likes.formatted(.number.notation(.compactName)))
                    .lineLimit(1)
                Button(action: {
                    showComment.toggle()
                }) {
                    Image(systemName: "bubble")
                }.foregroundStyle(.black)
                    .contentShape(Rectangle())
                    .sheet(isPresented: $showComment) {
                        VStack {
                            Text("Comments")
                                .font(.title)
                                .fontWeight(.bold)
                            Divider()
                            List(commentDatas) { commentData in
                                CommentElementView(commentData: commentData)
                                    .listRowInsets(EdgeInsets())
                            }
                            .listStyle(.plain)
                            .task {
                                commentDatas = await fetchComments(forPostWithId: postData.id)
                            }
                            
                        }.padding()
                    }
            }
        }
        
    }
}

#Preview {
    PostElementView(postData: PostData(id: UUID(), name: "John Appleseed", content: "Post content goes here. ", likes: 1234567890))
}
