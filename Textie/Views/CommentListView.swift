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
    
    @StateObject var viewModel: CommentListViewModel = .init(offset: 0, limit: 10)
    @State var newComment: String = ""
    @Environment(UserStateViewModel.self) var userStateViewModel
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
                    }
                    .listStyle(.plain)
                }
                Spacer()
                HStack {
                    TextField("COMMENT_WRITE_PLACEHOLDER", text: $newComment)
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
                            await viewModel.loadComments(postId: postId, token: userStateViewModel.token)
                        }
                    }) {
                        Image(systemName: "paperplane.fill")
                    }
                }
            }
        }.padding()
        .task {
            await viewModel.loadComments(postId: postId, token: userStateViewModel.token)
        }
        .alert("REQUEST_PROCESSING_ERROR", isPresented: $showErrorAlert) {
            Button("CONFIRM") { }
        } message: {
            Text("REQUEST_PROCESSING_ERROR_DETAILS")
        }
    }
}

#Preview {
    CommentListView(postId: UUID()).environment(UserStateViewModel())
}
