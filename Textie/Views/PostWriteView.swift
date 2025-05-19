//
//  PostWriteView.swift
//  Textie
//
//  Created by 하정우 on 5/16/25.
//

import SwiftUI
import os

struct PostWriteView: View {
    @State var title: String
    @State var context: String
    @State var showErrorAlert: Bool = false

    var postId: UUID?
    
    @Environment(UserStateViewModel.self) var userStateViewModel
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    
    var logger = Logger()
    
    var body: some View {
        let isEditing: Bool = postId != nil
        VStack(alignment: .leading) {
            Text(isEditing ? "EDIT_POST" : "POST_WRITE_TITLE")
                .font(.title)
                .fontWeight(.bold)
            HStack {
                if isEditing {
                    Button(action: { dismiss() }) { Text("CLOSE") }
                }
                Spacer()
                Button(action: {
                    Task {
                        do {
                            if isEditing {
                                let (_, _): (Data, URLResponse) = try await sendRequestToServer(toEndpoint: serverURLString + "/posts/\(postId!)/?title=\(title)&context=\(context)", httpMethod: "PUT", withToken: userStateViewModel.token)
                                let _ = try await userStateViewModel.refreshSession()
                                dismiss()
                            } else {
                                let (_, _): (Data, URLResponse) = try await sendRequestToServer(toEndpoint: serverURLString + "/posts/?title=\(title)&context=\(context)", httpMethod: "POST", withToken: userStateViewModel.token)
                            }
                        } catch {
                            if let error = error as? BackendError, case .invalidResponse(let statusCode) = error {
                                logger.debug("/posts endpoint returned status code: \(statusCode)")
                                showErrorAlert = true
                            }
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
            .alert("REQUEST_PROCESSING_ERROR", isPresented: $showErrorAlert) {
                Button("CONFIRM") { }
            } message: {
                Text("REQUEST_PROCESSING_ERROR_DETAILS")
            }
    }
}

#Preview {
    PostWriteView(title: "", context: "").environment(UserStateViewModel())
}
