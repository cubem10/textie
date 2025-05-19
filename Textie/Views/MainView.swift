//
//  MainView.swift
//  Textie
//
//  Created by 하정우 on 5/17/25.
//

import SwiftUI
import os

struct MainView: View {
    @Environment(UserStateViewModel.self) var viewModel
    @State private var timer: Timer?
    @SceneStorage("selectedTab") private var selection: Int = 0
    
    private let logger = Logger()
    
    var body: some View {
        TabView(selection: $selection) {
            Tab("POST_TITLE", systemImage: "newspaper.fill", value: 0) {
                PostListView()
            }
            
            Tab("POST_WRITE_TITLE", systemImage: "square.and.pencil", value: 1) {
                PostWriteView(title: "", context: "", selectedTab: $selection)
            }
            
            Tab("PROFILE_TITLE", systemImage: "person.crop.circle.fill", value: 2) {
                ProfileView(uuid: viewModel.uuid)
            }
            
        }
        .onAppear {
            timer = Timer.scheduledTimer(withTimeInterval: 900, repeats: true) { _ in
                Task {
                    do {
                        let result = try await viewModel.refreshSession()
                        if !result {
                            logger.debug("Token automatic refresh failed.")
                            // TODO: error handling
                        }
                    } catch {
                        logger.debug("Token automatic refresh failed. \(error)")
                        // TODO: error handling
                    }
                }
            }
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
}

#Preview {
    MainView().environment(UserStateViewModel())
}
