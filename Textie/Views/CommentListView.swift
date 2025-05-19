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
    @State var showErrorAlert: Bool = false
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
                                if let error = error as? BackendError, case .invalidResponse(let statusCode) = error {
                                    logger.debug("/comment POST request failed with status code: \(statusCode)")
                                    showErrorAlert = true
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
        .alert("REQUEST_PROCESSING_ERROR", isPresented: $showErrorAlert) {
            Button("CONFIRM") { }
        } message: {
            Text("REQUEST_PROCESSING_ERROR_DETAILS")
        }
    }
}

#Preview {
    CommentListView(postId: UUID(uuidString: "a2e667da-deab-4e45-844b-61fd4cc5f6a1")!).environment(UserStateViewModel())
}
