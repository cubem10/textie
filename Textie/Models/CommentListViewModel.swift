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
        print("Loading comments...")
        await MainActor.run {
            isLoading = true
        }
        
        guard let (response, _): (Data, URLResponse) = try? await sendRequestToServer(toEndpoint: serverURLString + "/posts/\(postId)/comments/?offset=\(offset)&limit=\(limit)", httpMethod: "GET") else {
            print("An error occurred while fetching comments.")
            return
        }
        
        print(String(data: response, encoding: .utf8) ?? "")
        
        guard let decodedComments: CommentResponseDTO = try? JSONDecoder().decode(CommentResponseDTO.self, from: response) else {
            print("An error occurred while decoding comments.")
            return
        }
        
        comments.removeAll()
        
        for comment in decodedComments.comments {
            await comments.append(CommentData.construct(comment: comment, token: token))
        }

        print("Comments: \(comments)")
        
        await MainActor.run {
            isLoading = false
        }
    }
    
    func addComment(postId: UUID, token: String, content: String) async {
        do {
            let (_, _): (Data, URLResponse) = try await sendRequestToServer(toEndpoint: serverURLString + "/posts/\(postId)/comments/?content=\(content)", httpMethod: "POST", withToken: token)
        } catch {
            print("An error occurred while posting comments: \(error)")
        }
    }
}
