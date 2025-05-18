//
//  PostListView.swift
//  Textie
//
//  Created by 하정우 on 5/16/25.
//

import SwiftUI

struct PostListView: View {
    @StateObject private var viewModel: PostListViewModel = .init(offset: 0, limit: 10)
    @Environment(UserStateViewModel.self) var userStateViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            Group {
                if viewModel.isLoading {
                    ProgressView("POST_LOADING_MESSAGE")
                } else if viewModel.postDatas.isEmpty {
                    Text("NO_POST_MESSAGE")
                }
                else {
                    HStack {
                        Text("POST_TITLE")
                            .font(.title)
                            .fontWeight(.bold)
                        Spacer()
                    }
                    
                    let posts = viewModel.postDatas
                    List(posts) { postData in
                        if let token = userStateViewModel.getTokenFromKeychain(key: "access_token") {
                            PostElementView(postData: postData, token: token).padding().listRowInsets(EdgeInsets())
                        }
                    }.listStyle(.plain)
                }
                Spacer()
            }
        }
        .padding()
        .task {
            await viewModel.loadPost(token: userStateViewModel.getTokenFromKeychain(key: "access_token") ?? "")
        }
    }
}

#Preview {
    PostListView().environment(UserStateViewModel())
}
