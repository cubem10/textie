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

    var postId: UUID?
    
    @Environment(UserStateViewModel.self) var userStateViewModel: UserStateViewModel
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    
    @Binding var selectedTab: Int
    
    var logger = Logger()
    var viewModel: PostWriteViewModel = PostWriteViewModel()
    
    var body: some View {
        @Bindable var viewModel: PostWriteViewModel = viewModel
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
                                try await viewModel.editPost(title: title, context: context, postId: postId!, token: userStateViewModel.token)
                                dismiss()
                            } else {
                                try await viewModel.uploadPost(title: title, context: context, token: userStateViewModel.token)
                                let _ = await userStateViewModel.refreshSession()
                                selectedTab = 0
                            }
                        } catch {
                            if (error as? URLError) != nil {
                                viewModel.errorMessage = error.localizedDescription
                                viewModel.showErrorAlert = true
                                viewModel.isLoading = false
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
            .alert("REQUEST_PROCESSING_ERROR", isPresented: $viewModel.showErrorAlert) {
                Button("CONFIRM") { }
            } message: {
                Text(viewModel.errorMessage)
            }
            .overlay {
                if viewModel.isLoading {
                    ProgressView("POST_UPLOAD_LOADING_MESSAGE")
                }
            }
    }
}

#Preview {
    PostWriteView(title: "", context: "", selectedTab: .constant(1)).environment(UserStateViewModel())
}
