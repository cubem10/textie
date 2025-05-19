//
//  ProfileViewModel.swift
//  Textie
//
//  Created by 하정우 on 5/17/25.
//

import Foundation

@Observable
class ProfileViewModel {
    var isLoading: Bool = false
    
    private var offset: Int = 0
    private var limit: Int = 10
    
    var username: String = ""
    var nickname: String = ""
    var posts: [PostData] = []
    
    func loadUserPosts(token: String, uuid: UUID) async {
        posts.removeAll()

        guard let (response, _): (Data, URLResponse) = try? await sendRequestToServer(toEndpoint: serverURLString + "/users/\(uuid)/posts", httpMethod: "GET", withToken: token) else {
            return
        }
        
        guard let decodedResponse: [PostDataDTO] = try? JSONDecoder().decode([PostDataDTO].self, from: response) else {
            return
        }
        
        for postDataDTO in decodedResponse {
            guard let (likeResponseData, _): (Data, URLResponse) = try? await sendRequestToServer(toEndpoint: serverURLString + "/posts/\(postDataDTO.id)/likes/count", httpMethod: "GET") else {
                return
            }
            
            guard let decodedLikesResponse: LikeDataDTO = try? JSONDecoder().decode(LikeDataDTO.self, from: likeResponseData) else {
                return
            }
            
            await posts.append(PostData.construct(post: postDataDTO, likes: decodedLikesResponse.likeCount, token: token))
        }
    }
    
    @MainActor
    func loadUser(token: String, uuid: UUID) async {
        
        isLoading = true
        defer { isLoading = false }
        
        
        guard let (response, _): (Data, URLResponse) = try? await sendRequestToServer(toEndpoint: serverURLString + "/user/\(uuid)", httpMethod: "GET", withToken: token) else {
            return
        }
        
        guard let decodedResponse: UserProfileDTO = try? JSONDecoder().decode(UserProfileDTO.self, from: response) else {
            return
        }
        
        await loadUserPosts(token: token, uuid: decodedResponse.id)
        username = decodedResponse.username
        nickname = decodedResponse.nickname
        
    }
}
