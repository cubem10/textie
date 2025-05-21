//
//  ProfilePostView.swift
//  Textie
//
//  Created by 하정우 on 5/22/25.
//

import SwiftUI

struct ProfilePostView: View {
    @State var viewModel: ProfilePostViewModel = .init()
    var token: String
    var uuid: UUID
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.posts.isEmpty {
                    Text("NO_POST_MESSAGE")
                }
                else {
                    List(viewModel.posts) { postData in
                        PostElementView(postData: postData)
                            .padding(.bottom)
                            .alignmentGuide(.listRowSeparatorLeading, computeValue: { _ in 0 })
                            .background(
                                NavigationLink("", destination: PostDetailView(postData: postData).padding()).opacity(0)
                            )
                            .task(id: postData.id) {
                                await viewModel.loadMoreIfNeeded(id: postData.id)
                            }
                    }.listStyle(.plain)
                }
            }
    }.task {
        await viewModel.loadInitialPosts(token: token, uuid: uuid)
    }
    .navigationTitle(Text("POST_DETAIL_VIEW_TITLE"))
    .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    ProfilePostView(token: "", uuid: UUID())
}
