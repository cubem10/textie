//
//  PostListViewModel.swift
//  Textie
//
//  Created by 하정우 on 5/16/25.
//

import Foundation

class PostListViewModel: ObservableObject {
    @Published var isLoading = false
    
    private var offset: Int = 0
    private var limit: Int = 10
    
    var postDatas: [PostData] = []
    
    init(offset: Int, limit: Int) {
        self.offset = offset
        self.limit = limit
        self.postDatas = []
    }
    
    func loadPost() async {
        print("loadPost called")
        
        await MainActor.run {
            isLoading = true
        }
        
        print("fetchPost started")
        
        guard let (postResponseData, _): (Data, URLResponse) = try? await sendRequestToServer(toEndpoint: serverURLString + "/posts/?offset=\(offset)&limit=\(limit)", httpMethod: "GET") else {
            print("An error occurred while fetching posts.")
            return
        }
        
        guard let decodedPostResponse: [PostDataDTO] = try? JSONDecoder().decode([PostDataDTO].self, from: postResponseData) else {
            print("An error occurred while decoding posts data.")
            print(String(data: postResponseData, encoding: .utf8) ?? "")
            return
        }
        
        postDatas.removeAll()
        
        for postDataDTO in decodedPostResponse {
            guard let (likeResponseData, _): (Data, URLResponse) = try? await sendRequestToServer(toEndpoint: serverURLString + "/posts/\(postDataDTO.id)/likes/count", httpMethod: "GET") else {
                print("An error occurred while fetching likes.")
                return
            }
            
            guard let decodedLikesResponse: LikeDataDTO = try? JSONDecoder().decode(LikeDataDTO.self, from: likeResponseData) else {
                print("An error occurred while decoding likes data.")
                return
            }
            
            postDatas.append(PostData.construct(post: postDataDTO, likes: decodedLikesResponse.likeCount))
        }
        
        
        await MainActor.run {
            isLoading = false
        }
    }
}
