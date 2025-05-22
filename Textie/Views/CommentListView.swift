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
    
    @State var viewModel: CommentListViewModel = .init()
    @State var newComment: String = ""
    @Environment(UserStateViewModel.self) var userStateViewModel
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        @Bindable var viewModel: CommentListViewModel = viewModel
        VStack() {
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
                if viewModel.isInitialLoading {
                    ProgressView("LOADING_MESSAGE")
                        .padding()
                }
                else if viewModel.comments.isEmpty {
                    Text("NO_COMMENTS_MESSAGE")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.top)
                    Text("LEAVE_FIRST_COMMENT")
                        .font(.subheadline)
                        .padding(.bottom)
                }
                else {
                    ScrollView {
                        ForEach(viewModel.comments) {
                            commentData in
                            HStack {
                                CommentElementView(commentData: commentData)
                                .listRowInsets(EdgeInsets())
                                .padding(.vertical)
                                .alignmentGuide(.listRowSeparatorLeading, computeValue: { _ in 0 })
                                .task {
                                    await viewModel.loadMoreIfNeeded(id: commentData.id)
                                }
                                Spacer()
                            }
                            Divider()
                        }
                    }
                }
            }
        }
        .task {
            await viewModel.loadInitialComments(postId: postId, token: userStateViewModel.token)
        }
        .alert("REQUEST_PROCESSING_ERROR", isPresented: $viewModel.showError) {
            Button("CONFIRM") { }
        } message: {
            Text(viewModel.errorDetails)
        }
    }
}

#Preview {
    CommentListView(postId: UUID(uuidString: "c893eccc-5535-48af-9d52-2ee9259bf8c8")!).environment(UserStateViewModel())
}
