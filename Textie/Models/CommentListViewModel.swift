//
//  CommentListViewModel.swift
//  Textie
//
//  Created by 하정우 on 5/16/25.
//

import Foundation
import os

@Observable
class CommentListViewModel {
    var isLoading: Bool = false
    var isLastPage: Bool = false
    
    var page: Int = 0
    private let limit: Int = 10
    
    private var postId: UUID = UUID()
    private var token: String = ""
    
    private var logger = Logger()
    
    var showFailAlert: Bool = false
    var failDetail: String = ""
    
    var comments: [CommentData] = []
    
    @MainActor
    func loadComments(token: String, postId: UUID) async {
        self.token = token
        self.postId = postId
        
        isLoading = true
        defer { isLoading = false }
        
        comments.removeAll()
        let offset: Int = page * limit
        
        do {
            let (response, _): (Data, URLResponse) = try await sendRequestToServer(toEndpoint: serverURLString + "/posts/\(postId)/comments/?offset=\(offset)&limit=\(limit)", httpMethod: "GET")
            
            let decodedComments: CommentResponseDTO = try JSONDecoder().decode(CommentResponseDTO.self, from: response)
            
            if decodedComments.comments.count < 10 {
                isLastPage = true
            }
            
            else if try JSONDecoder().decode(CommentResponseDTO.self, from: try await sendRequestToServer(toEndpoint: serverURLString + "/posts/\(postId)/comments/?offset=\(offset + limit)&limit=\(limit)", httpMethod: "GET", withToken: token).0).comments.isEmpty {
                isLastPage = true
            }
            
            else {
                isLastPage = false
            }
            
            for comment in decodedComments.comments {
                try await comments.append(CommentData.construct(comment: comment, token: token))
            }
        } catch {
            if (error as? URLError) != nil {
                failDetail = error.localizedDescription
                showFailAlert = true
            }
        }
    }

    func addComment(postId: UUID, newComment: String, token: String) async {
        do {
            let (_, _): (Data, URLResponse) = try await sendRequestToServer(toEndpoint: serverURLString + "/posts/\(postId)/comments/?content=\(newComment)", httpMethod: "POST", withToken: token)
        } catch {
            if (error as? URLError) != nil {
                failDetail = error.localizedDescription
                showFailAlert = true
            }
        }
    }
}
