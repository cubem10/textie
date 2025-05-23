//
//  ProfilePostViewModel.swift
//  Textie
//
//  Created by 하정우 on 5/22/25.
//

import Foundation

@Observable
class ProfilePostViewModel: PaginationViewModel<PostData> {
    override internal func fetchDatas(offset: Int, limit: Int) async throws -> [PostData] {
        var posts: [PostData] = []
        
        let (response, _): (Data, URLResponse) = try await sendRequestToServer(toEndpoint: serverURLString + "/users/\(uuid)/posts/?offset=\(offset)&limit=\(limit)", httpMethod: "GET", withToken: token)
        let decodedResponse = try JSONDecoder().decode([PostDataDTO].self, from: response)
                
        for postDataDTO in decodedResponse {
            let (likeResponse, _): (Data, URLResponse) = try await sendRequestToServer(toEndpoint: serverURLString + "/posts/\(postDataDTO.id)/likes/count", httpMethod: "GET")
            let decodedLikeResponse = try JSONDecoder().decode(LikeDataDTO.self, from: likeResponse)
            
            try await posts.append(PostData.construct(post: postDataDTO, likes: decodedLikeResponse.likeCount, token: token))
        }
        
        return posts
    }
}
