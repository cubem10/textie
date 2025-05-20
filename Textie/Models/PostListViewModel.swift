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
    
    var isLoading = false
    
    var postDatas: [PostData] = []
    var token: String = ""
    var offset: Int = 0
    var limit: Int = 10
    
    var showFailAlert: Bool = false
    var failDetail: String = ""
    
    init(offset: Int, limit: Int) {
        self.postDatas = []
    }
    
    func loadMorePost(id: UUID) async {
        if id == postDatas.last?.id {
            await loadPost(token: token)
        }
    }
    
    func loadPost(token: String) async {
        var buffer: [PostData] = []
        do {
            let (postResponseData, _): (Data, URLResponse) = try await sendRequestToServer(toEndpoint: serverURLString + "/posts/?offset=\(offset)&limit=\(limit)", httpMethod: "GET", withToken: token)
            
            let decodedPostResponse: [PostDataDTO] = try JSONDecoder().decode([PostDataDTO].self, from: postResponseData)
                    
            for postDataDTO in decodedPostResponse {
                let (likeResponseData, _): (Data, URLResponse) = try await sendRequestToServer(toEndpoint: serverURLString + "/posts/\(postDataDTO.id)/likes/count", httpMethod: "GET")
                
                let decodedLikesResponse: LikeDataDTO = try JSONDecoder().decode(LikeDataDTO.self, from: likeResponseData)
                
                try await buffer.append(PostData.construct(post: postDataDTO, likes: decodedLikesResponse.likeCount, token: token))
            }
        } catch {
            if (error as? URLError) != nil {
                failDetail = error.localizedDescription
                showFailAlert = true
            }
        }
        
        buffer = buffer.filter { newItem in !postDatas.contains(where: { post in post.id == newItem.id}) }
        
        postDatas = postDatas + buffer
    }
    
    func loadInitialPost(token: String) async {
        self.token = token
        
        guard !isLoading else { return }

        postDatas.removeAll()
        
        isLoading = true
        defer { isLoading = false }
        offset = 0
        
        await loadPost(token: token)
    }
}
