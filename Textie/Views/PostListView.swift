//
//  PostListView.swift
//  Textie
//
//  Created by 하정우 on 5/16/25.
//

import SwiftUI

struct PostListView: View {
    @State private var viewModel: PostListViewModel = .init()
    @Environment(UserStateViewModel.self) var userStateViewModel
    
    var body: some View {
        @Bindable var viewModel: PostListViewModel = viewModel
        Group {
            if viewModel.isInitialLoading {
                ProgressView("POST_LOADING_MESSAGE")
            } else if viewModel.postDatas.isEmpty {
                Text("NO_POST_MESSAGE")
            }
            else {
                NavigationStack {
                    VStack(alignment: .leading){
                        HStack {
                            Text("POST_TITLE")
                                .font(.title)
                                .fontWeight(.bold)
                                .padding()
                            Spacer()
                        }
                        
                        List(viewModel.postDatas) { postData in
                            PostElementView(postData: postData)
                                .padding(.bottom)
                                .task {
                                    await viewModel.loadMoreIfNeeded(currentItemID: postData.id)
                                }
                                .alignmentGuide(.listRowSeparatorLeading, computeValue: { _ in 0 })
                                .background(
                                    NavigationLink("", destination: PostDetailView(postData: postData).padding()).opacity(0)
                                )
                        }.listStyle(.plain)
                        
                    }
                }.navigationTitle(Text("POST_DETAIL_VIEW_TITLE"))
                    .navigationBarTitleDisplayMode(.inline)
            }
        }
        .task {
            await viewModel.loadInitialPosts(token: userStateViewModel.token)
        }
        .refreshable {
            Task {
                await viewModel.loadInitialPosts(token: userStateViewModel.token)
            }
        }
        .alert("NETWORK_ERROR", isPresented: $viewModel.showFailAlert, actions: { }, message: {
            Text(viewModel.failDetail)
        })
    }
}

#Preview {
    PostListView().environment(UserStateViewModel())
}
