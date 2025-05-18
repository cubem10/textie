//
//  ProfileView.swift
//  Textie
//
//  Created by 하정우 on 4/30/25.
//

import SwiftUI

struct ProfileView: View {
    @Environment(UserStateViewModel.self) var userStateViewModel
    @Environment(\.colorScheme) var colorScheme
    @State private var viewModel: ProfileViewModel = .init()
    @State private var editingProfile: Bool = false
    var uuid: UUID
    
    var body: some View {
        let isMyProfile: Bool = uuid == userStateViewModel.uuid
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
                            }.foregroundStyle(colorScheme == .dark ? .white : .black)
                        }
                        Spacer()
                        if isMyProfile {
                            VStack {
                                Button(action: {
                                    Task {
                                        let logoutStatus: Bool = await userStateViewModel.logout()
                                        print("logoutStatus: \(logoutStatus)")
                                    }
                                }) {
                                    Text("LOGOUT")
                                }
                                .padding()
                                Button(action: {
                                    editingProfile.toggle()
                                }) {
                                    Text("EDIT_PROFILE")
                                }
                            }
                        }
                    }
                    .frame(height: 75)
                    .padding()
                    List(viewModel.posts, id: \.id) { post in
                        if let token = userStateViewModel.getTokenFromKeychain(key: "access_token") {
                            PostElementView(postData: post, token: token).padding().listRowInsets(EdgeInsets())
                        }
                    }.listStyle(.plain)
                        .padding()
                }
            }
        }
        .task {
            await viewModel.loadUser(token: userStateViewModel.getTokenFromKeychain(key: "access_token") ?? "", uuid: uuid)
        }
        .sheet(isPresented: $editingProfile) {
            ProfileEditView(newNickname: viewModel.nickname)
        }
    }
}

#Preview {
    ProfileView(uuid: UUID()).environment(UserStateViewModel())
}
