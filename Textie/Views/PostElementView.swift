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
    @Environment(\.colorScheme) var colorScheme
    @State private var showDialog: Bool = false
    @State private var showDeleteAlert: Bool = false
    @State private var showEditView: Bool = false

    @Environment(UserStateViewModel.self) var userStateViewModel
    
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                ProfileImageView().frame(width: 30, height: 30)
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
                            if let token = userStateViewModel.getTokenFromKeychain(key: "access_token") {
                                let (_, _) = try await sendRequestToServer(toEndpoint: serverURLString + "/posts/\(postData.id)/likes/", httpMethod: liked ? "DELETE" : "POST", withToken: token)
                            }
                            liked.toggle()
                        } catch {
                            print("An error occurred while liking post: \(error)")
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
                            if let token = userStateViewModel.getTokenFromKeychain(key: "access_token") {
                                let (_, _) = try await sendRequestToServer(toEndpoint: serverURLString + "/posts/\(postData.id)/", httpMethod: "DELETE", withToken: token)
                            }
                            let _ = try await userStateViewModel.refreshSession()
                        } catch {
                            print("An error occurred while deleting post: \(error)")
                        }
                    }
                },
                      secondaryButton: .cancel())
            }
            .sheet(isPresented: $showComment) {
                CommentListView(postId: postData.id)
            }
            .sheet(isPresented: $showEditView) {
                PostWriteView(title: postData.title, context: postData.content, postId: postData.id)
            }
        
    }
}

#Preview {
    PostElementView(postData: PostData(id: UUID(), name: "John Appleseed", title: "Title", createdAt: "1시간 전", userId: UUID(), isEdited: true, content: "Post content goes here. ", likes: 1234567890))
}
