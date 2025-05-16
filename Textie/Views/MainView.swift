//
//  MainView.swift
//  Textie
//
//  Created by 하정우 on 5/17/25.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        TabView {
            Tab("POST_TITLE", systemImage: "newspaper.fill") {
                PostListView()
            }
            
            Tab("POST_WRITE_TITLE", systemImage: "square.and.pencil") {
                PostWriteView()
            }
            
            Tab("PROFILE_TITLE", systemImage: "person.crop.circle.fill") {
                ProfileView()
            }
        }
    }
}

#Preview {
    MainView().environment(UserStateViewModel())
}
