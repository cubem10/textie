//
//  PostListView.swift
//  Textie
//
//  Created by 하정우 on 5/16/25.
//

import SwiftUI

struct PostListView: View {
    @StateObject private var viewModel: PostListViewModel = .init(offset: 0, limit: 10)
    
    var body: some View {
        var postDatas: [PostData] = []
        
        VStack(alignment: .leading) {
            Button(action: {
                let isAccessTokenRemoved: Bool = saveTokenToKeychain(token: "", key: "access_token")
                let isRefreshTokenRemoved: Bool = saveTokenToKeychain(token: "", key: "refresh_token")
                
                if isAccessTokenRemoved && isRefreshTokenRemoved {
                    print("Logged out successfully")
                }
            }) {
                Text("Log out")
            }
            
            Text("Posts")
                .font(.title)
                .fontWeight(.bold)
            
            Group {
                if viewModel.isLoading {
                    ProgressView("Loading...")
                } else {
                    let posts = viewModel.postDatas
                    ForEach(posts) { postData in
                        PostElementView(postData: postData).listRowInsets(EdgeInsets()).padding()
                    }
                }
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
