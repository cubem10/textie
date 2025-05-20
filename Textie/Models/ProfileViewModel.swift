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
    var showFailAlert: Bool = false
    var failDetail: String = ""
    
    private var offset: Int = 0
    private var limit: Int = 10
    
    var username: String = ""
    var nickname: String = ""
    var posts: [PostData] = []
    
    func loadUserPosts(token: String, uuid: UUID) async {
        posts.removeAll()
        
        do {
            let (response, _): (Data, URLResponse) = try await sendRequestToServer(toEndpoint: serverURLString + "/users/\(uuid)/posts", httpMethod: "GET", withToken: token)
            
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
                
                try await posts.append(PostData.construct(post: postDataDTO, likes: decodedLikesResponse.likeCount, token: token))
            }
        } catch {
            if (error as? URLError) != nil {
                failDetail = error.localizedDescription
                showFailAlert = true
            }
        }
    }
    
    @MainActor
    func loadUser(token: String, uuid: UUID) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let (response, _): (Data, URLResponse) = try await sendRequestToServer(toEndpoint: serverURLString + "/user/\(uuid)", httpMethod: "GET", withToken: token)
            
            guard let decodedResponse: UserProfileDTO = try? JSONDecoder().decode(UserProfileDTO.self, from: response) else {
                return
            }
            
            await loadUserPosts(token: token, uuid: decodedResponse.id)
            username = decodedResponse.username
            nickname = decodedResponse.nickname
        } catch {
            if (error as? URLError) != nil {
                failDetail = error.localizedDescription
                showFailAlert = true
            }
        }
    }
}
