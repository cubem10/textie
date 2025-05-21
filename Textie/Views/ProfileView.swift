//
//  ProfileView.swift
//  Textie
//
//  Created by 하정우 on 4/30/25.
//

import SwiftUI
import os

struct ProfileView: View {
    @Environment(UserStateViewModel.self) var userStateViewModel
    @Environment(\.colorScheme) var colorScheme
    @State private var viewModel: ProfileViewModel = .init()
    @State private var editingProfile: Bool = false
    var uuid: UUID
    private let logger = Logger()
    
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
                                    .fontWeight(.bold)
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
                            if isMyProfile {
                                HStack {
                                    Button(action: {
                                        editingProfile.toggle()
                                    }) {
                                        Text("EDIT_PROFILE")
                                    }.padding(.trailing)
                                    Button(action: {
                                        Task {
                                            let logoutStatus: Bool = await userStateViewModel.logout()
                                            logger.debug("logoutStatus: \(logoutStatus)")
                                        }
                                    }) {
                                        Text("LOGOUT")
                                    }
                                }
                            }
                        }
                    }
                    .frame(height: 100)
                    .padding(.bottom)
                    Divider()
                    ProfilePostView(token: userStateViewModel.token, uuid: userStateViewModel.uuid)
                }
            }
        }
        .task {
            await viewModel.loadUser(token: userStateViewModel.token, uuid: uuid)
        }
        .sheet(isPresented: $editingProfile) {
            ProfileEditView(newNickname: viewModel.nickname)
        }
        .padding()
    }
}

#Preview {
    ProfileView(uuid: UUID()).environment(UserStateViewModel())
}
