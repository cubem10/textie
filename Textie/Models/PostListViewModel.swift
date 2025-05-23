//
//  PostListViewModel.swift
//  Textie
//
//  Created by 하정우 on 5/16/25.
//

import Foundation
import os

@Observable
class PostListViewModel: PaginationViewModel<PostData> {
    override internal func fetchDatas(offset: Int, limit: Int = 10) async throws -> [PostData] {
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
