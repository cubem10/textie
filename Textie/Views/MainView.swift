//
//  MainView.swift
//  Textie
//
//  Created by 하정우 on 5/17/25.
//

import SwiftUI

struct MainView: View {
    @Environment(UserStateViewModel.self) var viewModel
    
    var body: some View {
        TabView {
            Tab("POST_TITLE", systemImage: "newspaper.fill") {
                PostListView()
            }
            
            Tab("POST_WRITE_TITLE", systemImage: "square.and.pencil") {
                PostWriteView()
            }
            
            Tab("PROFILE_TITLE", systemImage: "person.crop.circle.fill") {
                ProfileView(uuid: viewModel.uuid)
            }
            
        }
    }
}

#Preview {
    MainView().environment(UserStateViewModel())
}
