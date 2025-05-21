//
//  PostListView.swift
//  Textie
//
//  Created by 하정우 on 5/16/25.
//

import SwiftUI

struct PostListView: View {
    @State private var viewModel: PostListViewModel = .init(offset: 0, limit: 10)
    @Environment(UserStateViewModel.self) var userStateViewModel
    
    private var offset: Int = 0
    private let limit: Int = 10
    
    var body: some View {
        @Bindable var viewModel: PostListViewModel = viewModel
        Group {
            if viewModel.isLoading {
                ProgressView("POST_LOADING_MESSAGE")
            } else if viewModel.postDatas.isEmpty {
                Text("NO_POST_MESSAGE")
            }
            else {
                NavigationStack {
                    VStack(alignment: .leading ){
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
                                    await viewModel.loadMorePost(id: postData.id)
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
            await viewModel.loadInitialPost(token: userStateViewModel.token)
        }
        .refreshable {
            Task {
                await viewModel.loadInitialPost(token: userStateViewModel.token)
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
