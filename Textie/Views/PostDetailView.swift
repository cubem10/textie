//
//  PostDetailView.swift
//  Textie
//
//  Created by 하정우 on 5/22/25.
//

import SwiftUI

struct PostDetailView: View {
    @State var postData: PostData
    @State private var showErrorAlert: Bool = false
    @State private var errorMessage: String = ""
    @State private var showDialog: Bool = false
    @State private var showDeleteAlert: Bool = false
    @State private var showEditView: Bool = false
    @State private var showProfileView: Bool = false
    @State private var showComment: Bool = false

    @Environment(\.colorScheme) var colorScheme
    @Environment(UserStateViewModel.self) var userStateViewModel
    
    var body: some View {
        let isMyPost: Bool = postData.userId == userStateViewModel.uuid
        
        ScrollView {
            VStack(alignment: .leading) {
                PostElementView(postData: postData, contentLineLimit: nil)
                HStack {
                    Group {
                        if postData.isLiked { Image(systemName: "heart.fill") }
                        else { Image(systemName: "heart") }
                    }.onTapGesture {
                        Task {
                            if isMyPost {
                                errorMessage = String(localized: "SELF_LIKE_NOT_AVAILABLE")
                                showErrorAlert.toggle()
                                return
                            }
                            do {
                                let (_, _) = try await sendRequestToServer(toEndpoint: serverURLString + "/posts/\(postData.id)/likes/", httpMethod: postData.isLiked ? "DELETE" : "POST", withToken: userStateViewModel.token)
                                postData.isLiked.toggle()
                                postData.likes += postData.isLiked ? 1 : -1
                            } catch {
                                    if (error as? URLError) != nil {
                                        errorMessage = error.localizedDescription
                                        showErrorAlert.toggle()
                                    }
                            }
                        }
                    }
                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                    .contentShape(Rectangle())
                    
                    Text(postData.likes.formatted(.number.notation(.compactName)))
                        .lineLimit(1)
                    
                    if isMyPost {
                        Image(systemName: "ellipsis")
                            .onTapGesture {
                                showDialog.toggle()
                            }
                    }
                }
                Divider()
                HStack(alignment: .center) {
                    Image(systemName: "bubble")
                    Text("COMMENTS_TITLE")
                }
                CommentListView(postId: postData.id)
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
                            let _ = await userStateViewModel.refreshSession()
                        } catch {
                            if (error as? URLError) != nil {
                                errorMessage = error.localizedDescription
                                showErrorAlert.toggle()
                            }
                        }
                    }
                },
                      secondaryButton: .cancel())
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
            .sheet(isPresented: $showEditView) {
                PostWriteView(title: postData.title, context: postData.content, postId: postData.id, selectedTab: .constant(0))
            }
            .alert("REQUEST_PROCESSING_ERROR", isPresented: $showErrorAlert) {
                Button("CONFIRM") { }
            } message: {
                Text(errorMessage)
            }
        }
    }
}

#Preview {
    PostDetailView(postData: PostData(id: UUID(), name: "John Appleseed", title: "Title", createdAt: Date(), userId: UUID(), isEdited: true, isLiked: true, content: "Post content goes here. ", likes: 1234567890)).environment(UserStateViewModel())
}
