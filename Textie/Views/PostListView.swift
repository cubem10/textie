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
                        Button(action: {
                            Task {
                                let logoutStatus: Bool = await userStateViewModel.logout()
                                print("logoutStatus: \(logoutStatus)")
                            }
                        }) {
                            Text("LOGOUT")
                        }
                    }
                    
                    let posts = viewModel.postDatas
                    List(posts) { postData in
                        PostElementView(postData: postData).padding().listRowInsets(EdgeInsets())
                    }.listStyle(.plain)
                }
                Spacer()
            }
        }
        .padding()
        .task {
            await viewModel.loadPost()
        }
    }
}

#Preview {
    PostListView()
}
