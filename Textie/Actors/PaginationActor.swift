//
//  PaginationActor.swift
//  Textie
//
//  Created by 하정우 on 5/22/25.
//

import Foundation

actor PaginationActor {
    private var offset: Int = 0
    private let limit: Int
    private var hasMore: Bool = true
    private var state = State.idle
    
    enum State {
        case idle
        case initialLoading
        case loadingMore
    }
    
    init(limit: Int = 10) {
        self.limit = limit
    }
    
    func beginInitialLoad() -> Bool {
        guard state == .idle else { return false }
        
        offset = 0
        hasMore = true
        state = .initialLoading
        return true
    }
    
    func beginLoadMore() -> Int? {
        guard state == .idle && hasMore else { return nil }
        state = .loadingMore
        return offset
    }
    
    func finishLoading(newCount: Int) {
        if newCount < limit {
            hasMore = false
        }
        offset += newCount
        state = .idle
    }
    
    func canLoadMore() -> Bool {
        return hasMore && state == .idle
    }
}
