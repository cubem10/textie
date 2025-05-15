//
//  PostElementViewModel.swift
//  Textie
//
//  Created by 하정우 on 5/16/25.
//

import Foundation

class PostElementViewModel: APICaller, ObservableObject {
    @Published private var postDatas: [PostData]
    private var offset: Int = 0
    private var limit: Int = 10
    
    init(offset: Int, limit: Int) {
        self.offset = offset
        self.limit = limit
        self.postDatas = []
        
        super.init()
    }
    
    func fetchPostData(postId: Int) async throws {
        if let data = try? await sendRequestToServer(toEndpoint: serverURLString + "/posts/?offset=\(offset)&limit=\(limit)", httpMethod: "GET") {
            self.postDatas = try JSONDecoder().decode([PostData].self, from: data)
        } else {
            throw BackendError.invaildResponse
        }
    }
}
