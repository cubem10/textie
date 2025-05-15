//
//  PostElementViewModel.swift
//  Textie
//
//  Created by 하정우 on 5/16/25.
//

import Foundation

class PostListViewModel: APICaller, ObservableObject {
    @Published var isLoading = false
    
    private var offset: Int = 0
    private var limit: Int = 10
    
    var postDatas: [PostData] = []
    
    init(offset: Int, limit: Int) {
        self.offset = offset
        self.limit = limit
        self.postDatas = []
        
        super.init()
    }
    
    func loadPost() async {
        print("loadPost called")
        
        await MainActor.run {
            isLoading = true
        }
        
        self.postDatas = await fetchPost()
        await MainActor.run {
            isLoading = false
        }
    }
}
