//
//  PostListViewModel.swift
//  Textie
//
//  Created by 하정우 on 5/16/25.
//

import Foundation

class PostListViewModel: ObservableObject {
    @Published var isLoading = false
    
    var postDatas: [PostData] = []
    
    init(offset: Int, limit: Int) {
        self.postDatas = []
    }
    
    func loadPost(token: String, offset: Int, limit: Int) async {
        await MainActor.run {
            isLoading = true
        }
        
        guard let (postResponseData, _): (Data, URLResponse) = try? await sendRequestToServer(toEndpoint: serverURLString + "/posts/?offset=\(offset)&limit=\(limit)", httpMethod: "GET") else {
            return
        }
        
        guard let decodedPostResponse: [PostDataDTO] = try? JSONDecoder().decode([PostDataDTO].self, from: postResponseData) else {
            return
        }
        
        postDatas.removeAll()
        
        for postDataDTO in decodedPostResponse {
            guard let (likeResponseData, _): (Data, URLResponse) = try? await sendRequestToServer(toEndpoint: serverURLString + "/posts/\(postDataDTO.id)/likes/count", httpMethod: "GET") else {
                return
            }
            
            guard let decodedLikesResponse: LikeDataDTO = try? JSONDecoder().decode(LikeDataDTO.self, from: likeResponseData) else {
                return
            }
            
            await postDatas.append(PostData.construct(post: postDataDTO, likes: decodedLikesResponse.likeCount, token: token))
        }
        
        
        await MainActor.run {
            isLoading = false
        }
    }
}
