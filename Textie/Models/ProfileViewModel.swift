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
    
    func loadUserPosts(token: String, uuid: UUID) async -> [PostDataDTO] {
        var postDataDTOs: [PostDataDTO] = []
        
        guard let (response, _): (Data, URLResponse) = try? await sendRequestToServer(toEndpoint: serverURLString + "/users/\(uuid)/posts", httpMethod: "GET", withToken: token) else {
            print("An error occurred while fetching posts.")
            return postDataDTOs
        }
        
        guard let decodedResponse: [PostDataDTO] = try? JSONDecoder().decode([PostDataDTO].self, from: response) else {
            print("An error occurred while decoding posts.")
            return postDataDTOs
        }
        
        postDataDTOs = decodedResponse
        return postDataDTOs
    }
    
    @MainActor
    func loadUser(token: String, uuid: UUID) async {
        
        isLoading = true
        
        defer { isLoading = false }
        
        
        guard let (response, _): (Data, URLResponse) = try? await sendRequestToServer(toEndpoint: serverURLString + "/user/\(uuid)", httpMethod: "GET", withToken: token) else {
            print("An error occurred while fetching user info. ")
            return
        }
        
        guard let decodedResponse: UserProfileDTO = try? JSONDecoder().decode(UserProfileDTO.self, from: response) else {
            print("An error occurred while decoding user profile information with uuid: \(uuid).")
            print(String(data: response, encoding: .utf8) ?? "")
            return
        }
        
        let postDTOs = await loadUserPosts(token: token, uuid: decodedResponse.id)
        username = decodedResponse.username
        nickname = decodedResponse.nickname
        
        posts.removeAll()
        
        for post in postDTOs {
            await posts.append(PostData.construct(post: post, token: token))
        }
    }
}
