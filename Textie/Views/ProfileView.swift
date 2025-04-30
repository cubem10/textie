//
//  ProfileView.swift
//  Textie
//
//  Created by 하정우 on 4/30/25.
//

import SwiftUI

struct ProfileView: View {
    var profile: UserProfile
    
    @State private var postDatas: [PostData] = []
    
    var body: some View {
        VStack {
            HStack {
                AsyncImage(url: profile.profileImageURL) { image in
                    image.resizable()
                } placeholder: {
                    Image(systemName: "person.circle.fill").resizable()
                }.clipShape(Circle())
                .frame(width: 100, height: 100)
                .padding(.trailing)
                VStack(alignment: .leading) {
                    Text(profile.name)
                        .font(.title)
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
                    if let bio = profile.bio {
                        Text(bio)
                            .font(.body)
                            .foregroundColor(.black)
                    }
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
    ProfileView(profile: UserProfile(name: "John Appleseed", userId: "johnappleseed", bio: "This is my profile. ", profileImageURL: nil, birthDate: Date(timeIntervalSince1970: 0)))
}
