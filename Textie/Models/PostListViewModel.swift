//
//  PostListViewModel.swift
//  Textie
//
//  Created by 하정우 on 5/16/25.
//

import Foundation
import os

@Observable
class PostListViewModel {
    private let logger = Logger()
    
    var isInitialLoading: Bool = false
    var isLoadingMore: Bool = false
    private let paginator: PaginationActor = .init(limit: 10)
    
    var postDatas: [PostData] = []
    var token: String = ""
    
    var showFailAlert: Bool = false
    var failDetail: String = ""
    
    func loadInitialPosts(token: String) async {
        self.token = token
        
        guard await paginator.beginInitialLoad() else { return }
        isInitialLoading = true
        defer { isInitialLoading = false}
        
        postDatas.removeAll()
        
        do {
            let newPosts = try await loadPosts(offset: 0)
            postDatas.append(contentsOf: newPosts)
            await paginator.finishLoading(newCount: newPosts.count)
        } catch {
            failDetail = error.localizedDescription
            showFailAlert = true
            await paginator.finishLoading(newCount: 0)
        }
    }
    
    func loadMoreIfNeeded(currentItemID id: UUID) async {
        guard id == postDatas.last?.id else { return }
        guard let nextOffset = await paginator.beginLoadMore() else { return }
        
        isLoadingMore = true
        defer { isLoadingMore = false }
        
        do {
            let newPosts = try await loadPosts(offset: nextOffset)
            let existingIDs = Set(postDatas.map { $0.id })
            let uniquePosts = newPosts.filter { !existingIDs.contains($0.id) }
            if !uniquePosts.isEmpty {
                postDatas.append(contentsOf: uniquePosts)
            }
            await paginator.finishLoading(newCount: uniquePosts.count)
        } catch {
            failDetail = error.localizedDescription
            showFailAlert = true
            await paginator.finishLoading(newCount: 0)
        }
    }
    
    private func loadPosts(offset: Int, limit: Int = 10) async throws -> [PostData] {
        var posts: [PostData] = []
        
        let (response, _): (Data, URLResponse) = try await sendRequestToServer(toEndpoint: serverURLString + "/posts/?offset=\(offset)&limit=\(limit)", httpMethod: "GET", withToken: token)
        let decodedResponse = try JSONDecoder().decode([PostDataDTO].self, from: response)
        for postData in decodedResponse {
            let (likeResponse, _): (Data, URLResponse) = try await sendRequestToServer(toEndpoint: serverURLString + "/posts/\(postData.id)/likes/count/", httpMethod: "GET")
            let decodedLikeResponse = try JSONDecoder().decode(LikeDataDTO.self, from: likeResponse)
            
            try await posts.append(PostData.construct(post: postData, likes: decodedLikeResponse.likeCount, token: token))
        }
        
        return posts
    }
    
}
