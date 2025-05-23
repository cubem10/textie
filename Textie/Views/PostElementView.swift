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
    @State private var showEditView: Bool = false
    @State private var showProfileView: Bool = false
    @State private var alertCause: AlertCause? = nil
    @State private var showMore: Bool = false
    @State private var isLoading: Bool = false
    
    let onPostDeleted: () -> Void
    
    @Environment(UserStateViewModel.self) var userStateViewModel
    @Environment(\.colorScheme) var colorScheme
    
    private let logger = Logger()
    
    enum AlertCause {
        case deleteConfirmation
        case showError(String)
    }
    
    func alertText(cause: AlertCause?) -> String {
        switch cause {
        case .deleteConfirmation:
            return String(localized: "REMOVE_POST_CONFIRMATION_TITLE")
        case .showError(_):
            return String(localized: "REQUEST_PROCESSING_ERROR")
        default:
            return ""
        }
    }
    
    func deletePost() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let (_, _) = try await sendRequestToServer(toEndpoint: serverURLString + "/posts/\(postData.id)/", httpMethod: "DELETE", withToken: userStateViewModel.token)
        } catch {
            if (error as? URLError) != nil {
                alertCause = .showError(error.localizedDescription)
            }
        }
    }
    
    private var showAlert: Binding<Bool> {
        Binding<Bool>(
            get: {
                alertCause != nil
            },
            set: {
                if !$0 {
                    alertCause = nil
                }
            }
        )
    }
    
    var body: some View {
        let isMyPost: Bool = postData.userId == userStateViewModel.uuid
        let isClipped: Bool = postData.content.count > 140
        
        Group {
            if !isLoading {
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
                    Group {
                        if isClipped {
                            if showMore == false {
                                Text("\(postData.content.prefix(140))...")
                                Text("SEE_MORE")
                                    .font(.subheadline)
                                    .onTapGesture {
                                        showMore.toggle()
                                    }
                            }
                            else {
                                Text(postData.content)
                                Text("SEE_LESS")
                                    .font(.subheadline)
                                    .onTapGesture {
                                        showMore.toggle()
                                    }
                            }
                        } else {
                            Text(postData.content)
                        }
                    }
                    .padding(.bottom)
                    HStack {
                        Group {
                            if postData.isLiked { Image(systemName: "heart.fill") }
                            else { Image(systemName: "heart") }
                        }.onTapGesture {
                            Task {
                                if isMyPost {
                                    alertCause = .showError(String(localized: "SELF_LIKE_NOT_AVAILABLE"))
                                    return
                                }
                                do {
                                    let (_, _) = try await sendRequestToServer(toEndpoint: serverURLString + "/posts/\(postData.id)/likes/", httpMethod: postData.isLiked ? "DELETE" : "POST", withToken: userStateViewModel.token)
                                    postData.isLiked.toggle()
                                    postData.likes += postData.isLiked ? 1 : -1
                                } catch {
                                        if (error as? URLError) != nil {
                                            alertCause = .showError(error.localizedDescription)
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
                        
                        if isMyPost {
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
                        alertCause = .deleteConfirmation
                    }) {
                        Text("REMOVE_POST")
                    }
                    Button("CANCEL", role: .cancel) {
                        
                    }
                }
            }
            else {
                ProgressView().padding()
            }
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
        .sheet(isPresented: $showComment) {
            HStack(alignment: .center) {
                Image(systemName: "bubble")
                Text("COMMENTS_TITLE")
            }.padding()
            CommentListView(postId: postData.id).padding(.horizontal)
            Spacer()
        }
        .alert(alertText(cause: alertCause), isPresented: showAlert, presenting: alertCause) { alert in
            switch alert {
            case .showError(_):
                Button("CONFIRM", role: .cancel) {
                    alertCause = nil
                }
            case .deleteConfirmation:
                Button("CANCEL", role: .cancel) {
                    alertCause = nil
                }
                Button("DELETE", role: .destructive) {
                    Task {
                        await deletePost()
                    }
                }
            }
        } message: { alert in
            switch alert {
            case .deleteConfirmation:
                Text("REMOVE_POST_CONFIRMATION_MESSAGE")
            case .showError(let message):
                Text(message)
            }
        }
    }
}

#Preview {
    PostElementView(postData: PostData(id: UUID(), name: "John Appleseed", title: "Title", createdAt: Date(), userId: UUID(), isEdited: true, isLiked: true, content: "Post content goes here. ", likes: 1234567890), onPostDeleted: { }).environment(UserStateViewModel())
}
