//
//  CommentListView.swift
//  Textie
//
//  Created by 하정우 on 5/16/25.
//

import SwiftUI

struct CommentListView: View {
    var postId: UUID
    @StateObject var viewModel: CommentListViewModel = .init(offset: 0, limit: 10)
    @State var newComment: String = ""
    var body: some View {
        VStack {
            Text("COMMENTS")
                .font(.title)
                .fontWeight(.bold)
            Divider()
            Group {
                if viewModel.isLoading {
                    ProgressView("LOADING_MESSAGE")
                }
                else if viewModel.comments.isEmpty {
                    Text("NO_COMMENTS_MESSAGE")
                }
                else {
                    List(viewModel.comments) { commentData in
                        CommentElementView(commentData: commentData)
                            .listRowInsets(EdgeInsets())
                    }
                    .listStyle(.plain)
                }
                Spacer()
            }
        }.padding()
        .task {
            await viewModel.loadComments(postId: postId)
        }
    }
}

#Preview {
    CommentListView(postId: UUID())
}
