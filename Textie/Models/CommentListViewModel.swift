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
    var isMoreLoading: Bool = false
    
    private var offset: Int = 0
    private var limit: Int = 10
    
    private var postId: UUID = UUID()
    private var token: String = ""
    
    private var logger = Logger()
    
    var showFailAlert: Bool = false
    var failDetail: String = ""
    
    var comments: [CommentData] = []
    
    init(offset: Int, limit: Int) {
        self.offset = offset
        self.limit = limit
    }
    
    @MainActor
    func loadInitialComments(postId: UUID, token: String) async {
        self.postId = postId
        self.token = token
        
        comments.removeAll()
        offset = 0
        
        isLoading = true
        defer { isLoading = false }
        
        await loadComments()
    }
    
    @MainActor
    func loadMoreComments(id: UUID) async {
        if comments.last?.id != id {
            return
        }
        
        isMoreLoading = true
        defer { isMoreLoading = false }
        
        await loadComments()
    }
    
    func loadComments() async {
        var buffer: [CommentData] = []
        
        do {
            let (response, _): (Data, URLResponse) = try await sendRequestToServer(toEndpoint: serverURLString + "/posts/\(postId)/comments/?offset=\(offset)&limit=\(limit)", httpMethod: "GET")
            
            let decodedComments: CommentResponseDTO = try JSONDecoder().decode(CommentResponseDTO.self, from: response)
            
            for comment in decodedComments.comments {
                try await buffer.append(CommentData.construct(comment: comment, token: token))
            }
            
            offset += limit
            
            buffer = buffer.filter { newComment in !comments.contains(where: { comment in
                comment.id == newComment.id
            })}
            
            comments.append(contentsOf: buffer)
        } catch {
            if (error as? URLError) != nil {
                failDetail = error.localizedDescription
                showFailAlert = true
            }
        }
    }

}
