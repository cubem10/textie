//
//  ProfileView.swift
//  Textie
//
//  Created by 하정우 on 4/30/25.
//

import SwiftUI

struct ProfileView: View {
    @Environment(UserStateViewModel.self) var userStateViewModel
        
    @State private var viewModel: ProfileViewModel = .init()
        
    var body: some View {
        VStack(alignment: .leading) {
            Group {
                if viewModel.isLoading {
                    ProgressView("PROFILE_LOADING_MESSAGE")
                }
                else {
                    HStack {
                        ProfileImageView()
                        .frame(width: 100, height: 100)
                        .padding(.trailing)
                        VStack(alignment: .leading) {
                            HStack {
                                Text(viewModel.nickname)
                                    .font(.title)
                            }
                            Button(action: {
                                UIPasteboard.general.string = "@" + viewModel.username
                            }) {
                                HStack {
                                    Text("@" + viewModel.username)
                                        .font(.subheadline)
                                    Image(systemName: "document.on.document.fill").scaleEffect(0.7)
                                }
                            }.foregroundStyle(.black)
                            Spacer()
                        }
                    }
                    .frame(height: 75)
                    .padding()
                    List(viewModel.posts, id: \.id) { post in
                        PostElementView(postData: post).listRowInsets(EdgeInsets())
                            .padding()

                    }
                }
            }
        }
        .task {
            await viewModel.loadUser(token: userStateViewModel.getTokenFromKeychain(key: "access_token") ?? "")
        }
    }
}

#Preview {
    ProfileView()
}
