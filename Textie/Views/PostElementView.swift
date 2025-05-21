//
//  PostElementView.swift
//  Textie
//
//  Created by 하정우 on 4/30/25.
//

import SwiftUI
import os

struct PostElementView: View {
    @State var postData: PostData
    @State private var showComment: Bool = false
    @State private var commentDatas: [CommentData] = []
    @State private var showDialog: Bool = false
    @State private var showDeleteAlert: Bool = false
    @State private var showEditView: Bool = false
    @State private var showProfileView: Bool = false
    @State private var showErrorAlert: Bool = false
    @State private var errorMessage: String = ""
    
    var contentLineLimit: ClosedRange? = 1...3
    
    @Environment(UserStateViewModel.self) var userStateViewModel
    @Environment(\.colorScheme) var colorScheme
    
    private let logger = Logger()
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                ProfileImageView().frame(width: 30, height: 30)
                    .onTapGesture {
                        showProfileView.toggle()
                    }
                Text(postData.name)
                    .lineLimit(1)
                Text("⋅")
                Text(Date.relativeTime(postData.createdAt) + (postData.isEdited ? " " + String(localized: "EDITED_TEXT") : ""))
                    .font(.subheadline)
            }.frame(height: 30)
                .padding(.vertical, 5)
            Text(postData.title)
                .font(.title2)
                .fontWeight(.bold)
                .lineLimit(1)
            if let contentLineLimit = contentLineLimit {
                Text(postData.content)
                    .padding(.bottom)
                    .lineLimit(contentLineLimit)
                
                HStack {
                    Group {
                        if postData.isLiked { Image(systemName: "heart.fill") }
                        else { Image(systemName: "heart") }
                    }
                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                    Text(postData.likes.formatted(.number.notation(.compactName)))
                        .lineLimit(1)
                    Image(systemName: "bubble")
                }
            }
            else {
                Text(postData.content)
                    .padding(.bottom)
                    .lineLimit(nil)
            }
        }
        
    }
}

#Preview {
    PostElementView(postData: PostData(id: UUID(), name: "John Appleseed", title: "Title", createdAt: Date(), userId: UUID(), isEdited: true, isLiked: true, content: "Post content goes here. ", likes: 1234567890)).environment(UserStateViewModel())
}
