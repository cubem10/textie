//
//  PostListViewModel.swift
//  Textie
//
//  Created by 하정우 on 5/16/25.
//

import Foundation

@Observable
class PostListViewModel {
    var isLoading = false
    
    var postDatas: [PostData] = []
    var token: String = ""
    var offset: Int = 0
    var limit: Int = 10
    
    init(offset: Int, limit: Int) {
        self.postDatas = []
    }
    
    func loadMorePost(id: UUID) async {
        if id == postDatas.last?.id {
            print("Loading more...")
            do {
                try await loadPost(token: token)
                offset += limit
            } catch {
                print("An error occurred while loading more posts: \(error), current offset: \(offset)")
            }
        }
    }
    
    func loadPost(token: String) async throws {
        var buffer: [PostData] = []
        
        let (postResponseData, _): (Data, URLResponse) = try await sendRequestToServer(toEndpoint: serverURLString + "/posts/?offset=\(offset)&limit=\(limit)", httpMethod: "GET")
        
        let decodedPostResponse: [PostDataDTO] = try JSONDecoder().decode([PostDataDTO].self, from: postResponseData)
                
        for postDataDTO in decodedPostResponse {
            let (likeResponseData, _): (Data, URLResponse) = try await sendRequestToServer(toEndpoint: serverURLString + "/posts/\(postDataDTO.id)/likes/count", httpMethod: "GET")
            
            let decodedLikesResponse: LikeDataDTO = try JSONDecoder().decode(LikeDataDTO.self, from: likeResponseData)
            
            await buffer.append(PostData.construct(post: postDataDTO, likes: decodedLikesResponse.likeCount, token: token))
        }
        
        buffer = buffer.filter { newItem in !postDatas.contains(where: { post in post.id == newItem.id}) }
        
        postDatas = postDatas + buffer
    }
    
    func loadInitialPost(token: String) async {
        self.token = token
        
        guard !isLoading else { return }

        isLoading = true
        defer { isLoading = false }
        
        do {
            try await loadPost(token: token)
        } catch {
            print("An error occurred while fetching posts: \(error), current offset: \(offset)")
        }
    }
}
