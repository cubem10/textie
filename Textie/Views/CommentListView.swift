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
                        .padding(.vertical)
                        .alignmentGuide(.listRowSeparatorLeading, computeValue: { _ in 0 })
                        .task {
                            await viewModel.loadMoreComments(id: commentData.id)
                        }
                    }
                    .listStyle(.plain)
                }
                Spacer()
                HStack {
                    TextField("", text: $newComment)
                        .padding(.vertical, 8)
                        .foregroundStyle(.white)
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
                            do {
                                let (_, _): (Data, URLResponse) = try await sendRequestToServer(toEndpoint: serverURLString + "/posts/\(postId)/comments/?content=\(newComment)", httpMethod: "POST", withToken: userStateViewModel.token)
                            } catch {
                                if (error as? URLError) != nil {
                                    viewModel.failDetail = error.localizedDescription
                                    viewModel.showFailAlert = true
                                }
                            }
                            await viewModel.loadInitialComments(postId: postId, token: userStateViewModel.token)
                        }
                    }) {
                        Image(systemName: "paperplane.fill").padding(.horizontal, 8)
                    }
                }
                .overlay {
                    Capsule().fill(.clear).strokeBorder(colorScheme == .dark ? Color.white : Color.gray.opacity(0.7), lineWidth: 1)
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
    CommentListView(postId: UUID(uuidString: "a2e667da-deab-4e45-844b-61fd4cc5f6a1")!).environment(UserStateViewModel())
}
