//
//  PostWriteViewModel.swift
//  Textie
//
//  Created by 하정우 on 5/21/25.
//

import Foundation
import SwiftUI

@MainActor
@Observable
class PostWriteViewModel {
    var isLoading: Bool = false
    var showErrorAlert: Bool = false
    var errorMessage: String = ""
    
    func uploadPost(title: String, context: String, token: String) async throws {
        isLoading = true
        
        let (_, _): (Data, URLResponse) = try await sendRequestToServer(toEndpoint: serverURLString + "/posts/?title=\(title)&context=\(context)", httpMethod: "POST", withToken: token)
        
        isLoading = false
    }
    
    func editPost(title: String, context: String, postId: UUID?, token: String) async throws {
        isLoading = true
        
        let (_, _): (Data, URLResponse) = try await sendRequestToServer(toEndpoint: serverURLString + "/posts/\(postId!)/?title=\(title)&context=\(context)", httpMethod: "PUT", withToken: token)
        
        isLoading = false
    }
}
