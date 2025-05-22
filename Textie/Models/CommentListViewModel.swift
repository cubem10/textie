//
//  CommentListViewModel.swift
//  Textie
//
//  Created by 하정우 on 5/16/25.
//

import Foundation

@Observable
class CommentListViewModel {
    private var pagination: PaginationActor = .init(limit: 10)
    
    var isInitialLoading: Bool = false
    var isLoadingMore: Bool = false
    
    var showError: Bool = false
    var errorDetails: String = ""
    
    var token: String = ""
    var uuid: UUID = UUID()
    
    var comments: [CommentData] = []
    
    func loadInitialComments(postId: UUID, token: String) async {
        self.token = token
        self.uuid = postId
        
        guard await pagination.beginInitialLoad() else { return }
        
        isInitialLoading = true
        defer { isInitialLoading = false }
        
        comments.removeAll()
        
        do {
            let newComments = try await fetchComments(offset: 0, limit: 10)
            comments.append(contentsOf: newComments)
            await pagination.finishLoading(newCount: newComments.count)
        } catch {
            errorDetails = error.localizedDescription
            showError = true
            await pagination.finishLoading(newCount: 0)
        }
    }
    
    func loadMoreIfNeeded(id: UUID) async {
        guard id == comments.last?.id else { return }
        guard let nextOffset = await pagination.beginLoadMore() else { return }
        
        isLoadingMore = true
        defer { isLoadingMore = false }
        
        do {
            let newPosts = try await fetchComments(offset: nextOffset, limit: 10)
            let existingIDs = Set(comments.map { $0.id })
            let uniquePosts = newPosts.filter { !existingIDs.contains($0.id) }
            if !uniquePosts.isEmpty {
                comments.append(contentsOf: uniquePosts)
            }
            await pagination.finishLoading(newCount: uniquePosts.count)
        } catch {
            errorDetails = error.localizedDescription
            showError = true
            await pagination.finishLoading(newCount: 0)
        }
    }
    
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
    
    private func fetchComments(offset: Int, limit: Int) async throws -> [CommentData] {
        var comments: [CommentData] = []
        
        let (response, _): (Data, URLResponse) = try await sendRequestToServer(toEndpoint: serverURLString + "/posts/\(uuid)/comments/?offset=\(offset)&limit=\(limit)", httpMethod: "GET", withToken: token)
        
        let decodedResponse = try JSONDecoder().decode(CommentResponseDTO.self, from: response)
        
        for comment in decodedResponse.comments {
            try await comments.append(CommentData.construct(comment: comment, token: token))
        }
        
        return comments
    }
}
