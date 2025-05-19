//
//  PostWriteView.swift
//  Textie
//
//  Created by 하정우 on 5/16/25.
//

import SwiftUI

struct PostWriteView: View {
    @State var title: String
    @State var context: String

    var postId: UUID?
    
    @Environment(UserStateViewModel.self) var userStateViewModel
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: {
                    Task {
                        do {
                            if let postId = postId {
                                let (_, _): (Data, URLResponse) = try await sendRequestToServer(toEndpoint: serverURLString + "/posts/\(postId)/?title=\(title)&context=\(context)", httpMethod: "PUT", withToken: userStateViewModel.token)
                                let _ = try await userStateViewModel.refreshSession()
                                dismiss()
                            } else {
                                let (_, _): (Data, URLResponse) = try await sendRequestToServer(toEndpoint: serverURLString + "/posts/?title=\(title)&context=\(context)", httpMethod: "POST", withToken: userStateViewModel.token)
                            }
                        } catch {
                            // TODO: error handling
                        }
                    }
                }) {
                    Text("POST_WRITE_SUBMIT")
                }
            }
            ZStack {
                TextField(String(""), text: $title)
                    .padding(EdgeInsets())
                    .overlay {
                        RoundedRectangle(cornerRadius: 4).stroke(colorScheme == .dark ? Color.white : Color.black, lineWidth: 1)
                    }
                if title.isEmpty {
                    Text("POST_WRITE_TITLE_PLACEHOLDER").foregroundStyle(Color.gray)
                }
            }
        Spacer()
        ZStack {
            TextEditor(text: $context).padding(EdgeInsets())

            if context.isEmpty {
                Text("POST_WRITE_PLACEHOLDER")
                    .foregroundColor(Color.gray)
            }
        }
        .overlay {
                RoundedRectangle(cornerRadius: 8).stroke(colorScheme == .dark ? Color.white : Color.black, lineWidth: 1)
        }
        Spacer()
        }.padding()
    }
}

#Preview {
    PostWriteView(title: "", context: "").environment(UserStateViewModel())
}
