//
//  MainView.swift
//  Textie
//
//  Created by 하정우 on 5/17/25.
//

import SwiftUI

struct MainView: View {
    @Environment(UserStateViewModel.self) var viewModel
    @State private var timer: Timer?
    
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
        .onAppear {
            timer = Timer.scheduledTimer(withTimeInterval: 900, repeats: true) { _ in
                Task {
                    do {
                        let result = try await viewModel.refreshSession()
                        if !result {
                            print("Token automatic refresh failed.")
                        }
                    } catch {
                        print("Token automatic refresh failed. \(error)")
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
