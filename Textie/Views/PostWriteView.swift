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
    @State var errorMessage: String = ""

    var postId: UUID?
    
    @Environment(UserStateViewModel.self) var userStateViewModel
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    
    @Binding var selectedTab: Int
    
    var logger = Logger()
    
    var body: some View {
        let isEditing: Bool = postId != nil
        VStack(alignment: .leading) {
            Text(isEditing ? "EDIT_POST" : "POST_WRITE_TITLE")
                .font(.title)
                .fontWeight(.bold)
                .padding(.bottom)
                .listRowInsets(EdgeInsets())
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
                                let _ = await userStateViewModel.refreshSession()
                                dismiss()
                            } else {
                                let (_, _): (Data, URLResponse) = try await sendRequestToServer(toEndpoint: serverURLString + "/posts/?title=\(title)&context=\(context)", httpMethod: "POST", withToken: userStateViewModel.token)
                                selectedTab = 0
                            }
                        } catch {
                            if (error as? URLError) != nil {
                                errorMessage = error.localizedDescription
                                showErrorAlert.toggle()
                            }
                        }
                    }
                }) {
                    Text("POST_WRITE_SUBMIT")
                }
            }.padding(.bottom)
            .listRowInsets(EdgeInsets())
            ZStack(alignment: .topLeading) {
                TextField(String(""), text: $title).padding(EdgeInsets()).fontWeight(.bold)
                if title.isEmpty {
                    Text("POST_WRITE_TITLE_PLACEHOLDER").foregroundStyle(Color.gray).fontWeight(.bold)
                }
            }
            Divider()
            ZStack(alignment: .topLeading) {
                TextEditor(text: $context).contentMargins(.horizontal, -4)
                if context.isEmpty {
                    Text("POST_WRITE_PLACEHOLDER")
                        .foregroundColor(Color.gray)
                        .padding(.top, 8)
                }
            }
            Divider()
            HStack {
                Spacer()
                ZStack(alignment: .topTrailing) {
                    Text(context.count.description)
                        .font(.subheadline)
                }
            }
        Spacer()
        }.padding()
            .alert("REQUEST_PROCESSING_ERROR", isPresented: $showErrorAlert) {
                Button("CONFIRM") { }
            } message: {
                Text(errorMessage)
            }
    }
}

#Preview {
    PostWriteView(title: "", context: "", selectedTab: .constant(1)).environment(UserStateViewModel())
}
