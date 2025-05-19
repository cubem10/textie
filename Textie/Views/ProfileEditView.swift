//
//  ProfileEditView.swift
//  Textie
//
//  Created by 하정우 on 5/17/25.
//

import SwiftUI
import os

struct ProfileEditView: View {
    @Environment(UserStateViewModel.self) private var viewModel
    @Environment(\.dismiss) private var dismiss
    @State var newNickname: String
    @State var showErrorAlert: Bool = false
    
    var logger = Logger()
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: {
                    Task {
                        defer { dismiss() }
                        do {
                            let (_, _): (Data, URLResponse) = try await sendRequestToServer(toEndpoint: serverURLString + "/user?nickname=\(newNickname)", httpMethod: "PATCH", withToken: viewModel.token)
                            let _ = try await viewModel.refreshSession()
                        } catch {
                            if let error = error as? BackendError, case .invalidResponse(let statusCode) = error {
                                logger.debug("/user endpoint returned status code \(statusCode)")
                                showErrorAlert = true
                            }
                        }
                    }
                }) {
                    Text("EDIT_DONE")
                }
            }.padding()
            List {
                HStack {
                    Text("NICKNAME")
                    Spacer()
                    TextField("NICKNAME", text: $newNickname)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.trailing)
                }
            }
        }.alert("REQUEST_PROCESSING_ERROR", isPresented: $showErrorAlert) {
            Button("CONFIRM") { }
        } message: {
            Text("REQUEST_PROCESSING_ERROR_DETAILS")
        }
    }
}

#Preview {
    ProfileEditView(newNickname: "Nick Name").environment(UserStateViewModel())
}
