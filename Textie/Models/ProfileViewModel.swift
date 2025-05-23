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
    
    @MainActor
    func loadUser(token: String, uuid: UUID) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let (response, _): (Data, URLResponse) = try await sendRequestToServer(toEndpoint: serverURLString + "/user/\(uuid)", httpMethod: "GET", withToken: token)
            
            let decodedResponse: UserProfileDTO = try JSONDecoder().decode(UserProfileDTO.self, from: response)
            
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
