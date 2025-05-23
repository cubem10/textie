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
            } else if viewModel.datas.isEmpty {
                Text("NO_POST_MESSAGE")
            }
            else {
                VStack(alignment: .leading){
                    HStack {
                        Text("POST_TITLE")
                            .font(.title)
                            .fontWeight(.bold)
                            .padding()
                        Spacer()
                    }
                    
                    List(viewModel.datas) { postData in
                        PostElementView(postData: postData)
                            .padding(.bottom)
                            .task {
                                await viewModel.loadMoreIfNeeded(id: postData.id)
                            }
                            .alignmentGuide(.listRowSeparatorLeading, computeValue: { _ in 0 })
                            
                    }.listStyle(.plain)
                }
            }
        }
        .task {
            await viewModel.loadInitialDatas(id: nil, token: userStateViewModel.token)
        }
        .refreshable {
            Task {
                await viewModel.loadInitialDatas(id: nil, token: userStateViewModel.token)
            }
        }
        .alert("NETWORK_ERROR", isPresented: $viewModel.showError, actions: { }, message: {
            Text(viewModel.errorDetails)
        })
    }
}

#Preview {
    PostListView().environment(UserStateViewModel())
}
