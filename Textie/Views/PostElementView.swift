//
//  PostElementView.swift
//  Textie
//
//  Created by 하정우 on 4/30/25.
//

import SwiftUI
import os

struct PostElementView: View {
    var postData: PostData
    @State private var showComment: Bool = false
    @State private var liked: Bool = false
    @State private var commentDatas: [CommentData] = []
    @State private var showDialog: Bool = false
    @State private var showDeleteAlert: Bool = false
    @State private var showEditView: Bool = false
    @State private var showProfileView: Bool = false
    @State private var showErrorAlert: Bool = false
    
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
                Text(postData.createdAt + (postData.isEdited ? " " + String(localized: "EDITED_TEXT") : ""))
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
                Group {
                    if liked { Image(systemName: "heart.fill") }
                    else { Image(systemName: "heart") }
                }.onTapGesture {
                    Task {
                        do {
                            let (_, _) = try await sendRequestToServer(toEndpoint: serverURLString + "/posts/\(postData.id)/likes/", httpMethod: liked ? "DELETE" : "POST", withToken: userStateViewModel.token)
                            liked.toggle()
                        } catch {
                                if let error = error as? BackendError, case .invalidResponse(let statusCode) = error {
                                    logger.debug("/like \(liked ? "DELETE" : "POST") response status code: \(statusCode)")
                                    showErrorAlert.toggle()
                                }
                        }
                    }
                }
                .foregroundStyle(colorScheme == .dark ? .white : .black)
                .contentShape(Rectangle())
                
                Text(postData.likes.formatted(.number.notation(.compactName)))
                    .lineLimit(1)
                Image(systemName: "bubble")
                    .onTapGesture {
                        showComment.toggle()
                    }
                if postData.userId == userStateViewModel.uuid {
                    Image(systemName: "ellipsis")
                        .onTapGesture {
                            showDialog.toggle()
                        }
                }
            }
        }
        .confirmationDialog("POST_MENU", isPresented: $showDialog) {
                Button(action: {
                    showEditView.toggle()
                }) {
                    Text("EDIT_POST")
                }
                Button(action: {
                    showDeleteAlert.toggle()
                }) {
                    Text("REMOVE_POST")
                }
                Button("CANCEL", role: .cancel) {
                    
                }
        }
            .alert(isPresented: $showDeleteAlert) {
                Alert(title: Text("REMOVE_POST_CONFIRMATION_TITLE"), message: Text("REMOVE_POST_CONFIRMATION_MESSAGE"), primaryButton: .destructive(Text("DELETE")) {
                    Task {
                        do {
                            let (_, _) = try await sendRequestToServer(toEndpoint: serverURLString + "/posts/\(postData.id)/", httpMethod: "DELETE", withToken: userStateViewModel.token)
                            let _ = try await userStateViewModel.refreshSession()
                        } catch {
                            if let error = error as? BackendError, case .invalidResponse(let statusCode) = error {
                                logger.debug("/post DELETE response status code: \(statusCode)")
                                showErrorAlert.toggle()
                            }
                        }
                    }
                },
                      secondaryButton: .cancel())
            }
            .sheet(isPresented: $showComment) {
                VStack(alignment: .trailing) {
                    Button(action: {
                        showComment.toggle()
                    }) {
                        Text("CLOSE")
                    }
                    CommentListView(postId: postData.id)
                }.padding()
            }
            .sheet(isPresented: $showEditView) {
                PostWriteView(title: postData.title, context: postData.content, postId: postData.id, selectedTab: .constant(1))
            }
            .sheet(isPresented: $showProfileView) {
                VStack(alignment: .trailing) {
                    Button(action: {
                        showProfileView.toggle()
                    }) {
                        Text("CLOSE")
                    }
                    ProfileView(uuid: postData.userId)
                }.padding()
            }
            .alert("REQUEST_PROCESSING_ERROR", isPresented: $showErrorAlert) {
                Button("CONFIRM") { }
            } message: {
                Text("REQUEST_PROCESSING_ERROR_DETAILS")
            }
        
    }
}

#Preview {
    PostElementView(postData: PostData(id: UUID(), name: "John Appleseed", title: "Title", createdAt: "1시간 전", userId: UUID(), isEdited: true, content: "Post content goes here. ", likes: 1234567890)).environment(UserStateViewModel())
}
