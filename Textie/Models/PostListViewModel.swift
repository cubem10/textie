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
    var isLastPage = false
    
    var postDatas: [PostData] = []
    var token: String = ""
    
    var page: Int = 0
    let limit: Int = 10
    
    var showFailAlert: Bool = false
    var failDetail: String = ""
    
    @MainActor
    func loadPost(token: String) async {
        isLoading = true
        defer { isLoading = false }
        
        postDatas.removeAll()
        let offset: Int = page * limit
        do {
            let (postResponseData, _): (Data, URLResponse) = try await sendRequestToServer(toEndpoint: serverURLString + "/posts/?offset=\(offset)&limit=\(limit)", httpMethod: "GET", withToken: token)
            
            let decodedPostResponse: [PostDataDTO] = try JSONDecoder().decode([PostDataDTO].self, from: postResponseData)
            
            if decodedPostResponse.count < 10 {
                isLastPage = true
            }
            
            else if try JSONDecoder().decode([PostDataDTO].self, from: try await sendRequestToServer(toEndpoint: serverURLString + "/posts/?offset=\(offset + limit)&limit=\(limit)", httpMethod: "GET", withToken: token).0).isEmpty {
                isLastPage = true
            }
            
            else {
                isLastPage = false
            }
                    
            for postDataDTO in decodedPostResponse {
                let (likeResponseData, _): (Data, URLResponse) = try await sendRequestToServer(toEndpoint: serverURLString + "/posts/\(postDataDTO.id)/likes/count", httpMethod: "GET")
                
                let decodedLikesResponse: LikeDataDTO = try JSONDecoder().decode(LikeDataDTO.self, from: likeResponseData)
                
                try await postDatas.append(PostData.construct(post: postDataDTO, likes: decodedLikesResponse.likeCount, token: token))
            }
        } catch {
            if (error as? URLError) != nil {
                failDetail = error.localizedDescription
                showFailAlert = true
            }
        }
    }
}
