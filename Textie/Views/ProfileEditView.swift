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
    @State var errorMessage: String = ""
    
    var onNicknameEdit: () -> Void
    
    var logger = Logger()
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: {
                    Task {
                        defer {
                            dismiss()
                        }
                        do {
                            let (_, _): (Data, URLResponse) = try await sendRequestToServer(toEndpoint: serverURLString + "/user?nickname=\(newNickname)", httpMethod: "PATCH", withToken: viewModel.token)
                            onNicknameEdit()
                        } catch {
                            if (error as? URLError) != nil {
                                errorMessage = error.localizedDescription
                                showErrorAlert.toggle()
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
            Text(errorMessage)
        }
    }
}

#Preview {
    ProfileEditView(newNickname: "Nick Name", onNicknameEdit: { }).environment(UserStateViewModel())
}
