//
//  CommentListView.swift
//  Textie
//
//  Created by 하정우 on 5/16/25.
//

import SwiftUI
import os

struct CommentListView: View {
    var postId: UUID
    var logger = Logger()
    
    @State var viewModel: CommentListViewModel = .init(offset: 0, limit: 10)
    @State var newComment: String = ""
    @Environment(UserStateViewModel.self) var userStateViewModel
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        @Bindable var viewModel: CommentListViewModel = viewModel
        VStack(alignment: .leading) {
            HStack {
                TextField("", text: $newComment)
                    .padding(8)
                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                    .background {
                    if newComment.count == 0 {
                        HStack {
                            Text("COMMENT_WRITE_PLACEHOLDER")
                                .padding(.horizontal, 8)
                            Spacer()
                        }
                    }
                }
                Button(action: {
                    Task {
                        await viewModel.addComment(postId: postId, newComment: newComment, token: userStateViewModel.token)
                        await viewModel.loadInitialComments(postId: postId, token: userStateViewModel.token)
                        newComment = ""
                    }
                }) {
                    Image(systemName: "paperplane.fill").padding(.horizontal, 8)
                }
            }
            .overlay {
                RoundedRectangle(cornerRadius: 8).strokeBorder(colorScheme == .dark ? Color.white : Color.gray.opacity(0.7), lineWidth: 1)
            }
            Group {
                if viewModel.isLoading {
                    ProgressView("LOADING_MESSAGE")
                }
                else if viewModel.comments.isEmpty {
                    Text("NO_COMMENTS_MESSAGE")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("LEAVE_FIRST_COMMENT")
                        .font(.subheadline)
                }
                else {
                    List(viewModel.comments) { commentData in
                        CommentElementView(commentData: commentData)
                        .listRowInsets(EdgeInsets())
                        .padding(.vertical)
                        .alignmentGuide(.listRowSeparatorLeading, computeValue: { _ in 0 })
                        .task {
                            await viewModel.loadMoreComments(id: commentData.id)
                        }
                    }
                    .listStyle(.plain)
                }
            }
        }
        .task {
            await viewModel.loadInitialComments(postId: postId, token: userStateViewModel.token)
        }
        .alert("REQUEST_PROCESSING_ERROR", isPresented: $viewModel.showFailAlert) {
            Button("CONFIRM") { }
        } message: {
            Text(viewModel.failDetail)
        }
    }
}

#Preview {
    CommentListView(postId: UUID(uuidString: "c893eccc-5535-48af-9d52-2ee9259bf8c8")!).environment(UserStateViewModel())
}
