//
//  ProfileEditView.swift
//  Textie
//
//  Created by 하정우 on 5/17/25.
//

import SwiftUI

struct ProfileEditView: View {
    @Environment(UserStateViewModel.self) private var viewModel
    @Environment(\.dismiss) private var dismiss
    @State var newNickname: String
    
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
                            // TODO: error handling
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
        }
    }
}

#Preview {
    ProfileEditView(newNickname: "Nick Name").environment(UserStateViewModel())
}
