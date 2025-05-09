//
//  ProfileView.swift
//  Textie
//
//  Created by 하정우 on 4/30/25.
//

import SwiftUI

struct ProfileView: View {
    @State private var profile: UserProfile = UserProfile(id: UUID(), name: "John Appleseed", userId: "johnappleseed", bio: "This is my profile. ", profileImageURL: nil, birthDate: Date(timeIntervalSince1970: 0))
    
    @State private var postDatas: [PostData] = []
    @State private var ismyProfile: Bool = true // TODO: implement user credential comparison
        
    var body: some View {
        VStack {
            HStack {
                ProfileImageView(imageURL: profile.profileImageURL)
                .frame(width: 100, height: 100)
                .padding(.trailing)
                VStack(alignment: .leading) {
                    HStack {
                        Text(profile.name)
                            .font(.title)
                    }
                    Button(action: {
                        UIPasteboard.general.string = profile.userId
                    }) {
                        HStack {
                            Text("@\(profile.userId)")
                                .font(.subheadline)
                            Image(systemName: "document.on.document.fill").scaleEffect(0.7)
                        }
                    }.foregroundStyle(.black)
                    Spacer()
                    Text(profile.bio)
                        .font(.body)
                        .foregroundColor(.black)
                }
            }
            .frame(height: 75)
            .padding()
            List(postDatas) { post in
                PostElementView(postData: post).listRowInsets(EdgeInsets())
                    .padding()

            }.task {
                postDatas = await fetchPost()
            }
        }
        
    }
}

#Preview {
    ProfileView()
}
