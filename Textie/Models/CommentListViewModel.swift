//
//  CommentListViewModel.swift
//  Textie
//
//  Created by 하정우 on 5/16/25.
//

import Foundation

class CommentListViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    
    private var offset: Int = 0
    private var limit: Int = 10
    
    var comments: [CommentData] = []
    
    init(offset: Int, limit: Int) {
        self.offset = offset
        self.limit = limit
    }
    
    func loadComments(postId: UUID, token: String) async {
        await MainActor.run {
            isLoading = true
        }
        
        guard let (response, _): (Data, URLResponse) = try? await sendRequestToServer(toEndpoint: serverURLString + "/posts/\(postId)/comments/?offset=\(offset)&limit=\(limit)", httpMethod: "GET") else {
            return
        }
        
        guard let decodedComments: CommentResponseDTO = try? JSONDecoder().decode(CommentResponseDTO.self, from: response) else {
            return
        }
        
        comments.removeAll()
        
        for comment in decodedComments.comments {
            await comments.append(CommentData.construct(comment: comment, token: token))
        }
        
        await MainActor.run {
            isLoading = false
        }
    }

}
