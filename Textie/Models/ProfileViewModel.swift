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
    var isLastPage: Bool = false
    
    var showFailAlert: Bool = false
    var failDetail: String = ""
    
    var page: Int = 0
    private let limit: Int = 10
    
    var username: String = ""
    var nickname: String = ""
    var posts: [PostData] = []
    
    @MainActor
    func loadUserPosts(token: String, uuid: UUID) async {
        isLoading = true
        defer { isLoading = false }
        
        posts.removeAll()
        let offset: Int = page * limit

        do {
            let (response, _): (Data, URLResponse) = try await sendRequestToServer(toEndpoint: serverURLString + "/users/\(uuid)/posts/?offset=\(offset)&limit=\(limit)", httpMethod: "GET", withToken: token)
            
            let decodedResponse: [PostDataDTO] = try JSONDecoder().decode([PostDataDTO].self, from: response)
            
            if decodedResponse.count < 10 {
                isLastPage = true
            }
            
            else if try JSONDecoder().decode([PostDataDTO].self, from: try await sendRequestToServer(toEndpoint: serverURLString + "/users/\(uuid)/posts/?offset=\(offset + limit)&limit=\(limit)", httpMethod: "GET", withToken: token).0).isEmpty {
                isLastPage = true
            }
            
            else {
                isLastPage = false
            }
            
            for postDataDTO in decodedResponse {
                let (likeResponseData, _): (Data, URLResponse) = try await sendRequestToServer(toEndpoint: serverURLString + "/posts/\(postDataDTO.id)/likes/count", httpMethod: "GET")
                
                let decodedLikesResponse: LikeDataDTO = try JSONDecoder().decode(LikeDataDTO.self, from: likeResponseData)
                
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
