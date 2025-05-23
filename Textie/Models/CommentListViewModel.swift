//
//  CommentListViewModel.swift
//  Textie
//
//  Created by 하정우 on 5/16/25.
//

import Foundation

@Observable
class CommentListViewModel: PaginationViewModel<CommentData> {
    func addComment(postId: UUID, newComment: String, token: String) async {
        do {
            let (_, _): (Data, URLResponse) = try await sendRequestToServer(toEndpoint: serverURLString + "/posts/\(postId)/comments/?content=\(newComment)", httpMethod: "POST", withToken: token)
        } catch {
            if (error as? URLError) != nil {
                errorDetails = error.localizedDescription
                showError = true
            }
        }
    }
    
    override internal func fetchDatas(offset: Int, limit: Int) async throws -> [CommentData] {
        var comments: [CommentData] = []
        
        let (response, _): (Data, URLResponse) = try await sendRequestToServer(toEndpoint: serverURLString + "/posts/\(uuid)/comments/?offset=\(offset)&limit=\(limit)", httpMethod: "GET", withToken: token)
        
        let decodedResponse = try JSONDecoder().decode(CommentResponseDTO.self, from: response)
        
        for comment in decodedResponse.comments {
            try await comments.append(CommentData.construct(comment: comment, token: token))
        }
        
        return comments
    }
}
