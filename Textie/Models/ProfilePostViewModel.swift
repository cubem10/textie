//
//  ProfilePostViewModel.swift
//  Textie
//
//  Created by 하정우 on 5/22/25.
//

import Foundation

@Observable
class ProfilePostViewModel {
    private var pagination: PaginationActor = .init(limit: 10)
    
    var isInitialLoading: Bool = false
    var isLoadingMore: Bool = false
    
    var showError: Bool = false
    var errorDetails: String = ""
    
    var token: String = ""
    var uuid: UUID = UUID()
    
    var posts: [PostData] = []
    
    func loadInitialPosts(token: String, uuid: UUID) async {
        self.token = token
        self.uuid = uuid
        
        guard await pagination.beginInitialLoad() else { return }
        
        isInitialLoading = true
        defer { isInitialLoading = false }
        
        do {
            let newPosts = try await fetchPosts(offset: 0, limit: 10)
            posts.append(contentsOf: newPosts)
            await pagination.finishLoading(newCount: newPosts.count)
        } catch {
            errorDetails = error.localizedDescription
            showError = true
            print("loadInitialPosts error: \(errorDetails)")
            await pagination.finishLoading(newCount: 0)
        }
    }
    
    func loadMoreIfNeeded(id: UUID) async {
        guard id == posts.last?.id else { return }
        guard let nextOffset = await pagination.beginLoadMore() else { return }
        
        isLoadingMore = true
        defer { isLoadingMore = false }
        
        do {
            let newPosts = try await fetchPosts(offset: nextOffset, limit: 10)
            posts.append(contentsOf: newPosts)
            await pagination.finishLoading(newCount: newPosts.count)
        } catch {
            errorDetails = error.localizedDescription
            showError = true
            print("loadMoreIfNeeded error: \(errorDetails)")
            await pagination.finishLoading(newCount: 0)
        }
    }
    
    private func fetchPosts(offset: Int, limit: Int) async throws -> [PostData] {
        var posts: [PostData] = []
        
        let (response, _): (Data, URLResponse) = try await sendRequestToServer(toEndpoint: serverURLString + "/users/\(uuid)/posts/?offset=\(offset)&limit=\(limit)", httpMethod: "GET", withToken: token)
        let decodedResponse = try JSONDecoder().decode([PostDataDTO].self, from: response)
        
        print("decodedResponse: \(decodedResponse)")
        
        for postDataDTO in decodedResponse {
            let (likeResponse, _): (Data, URLResponse) = try await sendRequestToServer(toEndpoint: serverURLString + "/posts/\(postDataDTO.id)/likes/count", httpMethod: "GET")
            let decodedLikeResponse = try JSONDecoder().decode(LikeDataDTO.self, from: likeResponse)
            
            try await posts.append(PostData.construct(post: postDataDTO, likes: decodedLikeResponse.likeCount, token: token))
        }
        
        return posts
    }
}
