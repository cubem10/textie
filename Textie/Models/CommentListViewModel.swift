//
//  CommentListViewModel.swift
//  Textie
//
//  Created by 하정우 on 5/16/25.
//

import Foundation

class CommentListViewModel: APICaller, ObservableObject {
    @Published var isLoading: Bool = false
    
    private var offset: Int = 0
    private var limit: Int = 10
    
    var comments: [CommentData] = []
    
    init(offset: Int, limit: Int) {
        self.offset = offset
        self.limit = limit
        
        super.init()
    }
    
    func loadComments(postId: UUID) async {
        print("Loading comments...")
        await MainActor.run {
            isLoading = true
        }
        
        self.comments = await fetchComments(offset: 0, limit: 10, forPostWithId: postId)
        
        await MainActor.run {
            isLoading = false
        }
    }
}
