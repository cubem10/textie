//
//  PaginationViewModel.swift
//  Textie
//
//  Created by 하정우 on 5/23/25.
//

import Foundation
import os

protocol Model: Identifiable, Decodable {
    var id: UUID { get }
}

@Observable
class PaginationViewModel<T: Model> {
    private var pagination: PaginationActor = .init(limit: 10)
    private var logger = Logger()
    
    var isInitialLoading: Bool = false
    var isLoadingMore: Bool = false
    
    var showError: Bool = false
    var errorDetails: String = ""
    
    var token: String = ""
    var uuid: UUID = UUID()
    
    var datas: [T] = []
    
    func loadInitialDatas(id: UUID?, token: String) async {
        self.token = token
        if id != nil {
            self.uuid = id!
        }
        
        guard await pagination.beginInitialLoad() else { return }
        
        isInitialLoading = true
        defer { isInitialLoading = false }
        
        datas.removeAll()
        
        do {
            let newDatas = try await fetchDatas(offset: 0, limit: 10)
            datas.append(contentsOf: newDatas)
            await pagination.finishLoading(newCount: newDatas.count)
        } catch {
            errorDetails = error.localizedDescription
            showError = true
            await pagination.finishLoading(newCount: 0)
        }
    }
    
    func loadMoreIfNeeded(id: UUID) async {
        guard id == datas.last?.id else { return }
        guard let nextOffset = await pagination.beginLoadMore() else { return }
        
        isLoadingMore = true
        defer { isLoadingMore = false }
        
        do {
            let newDatas = try await fetchDatas(offset: nextOffset, limit: 10)
            let existingIDs = Set(datas.map { $0.id })
            let uniqueDatas = newDatas.filter { !existingIDs.contains($0.id) }
            if !uniqueDatas.isEmpty {
                datas.append(contentsOf: uniqueDatas)
            }
            await pagination.finishLoading(newCount: uniqueDatas.count)
        } catch {
            errorDetails = error.localizedDescription
            showError = true
            await pagination.finishLoading(newCount: 0)
        }
    }
    
    internal func fetchDatas(offset: Int, limit: Int) async throws -> [T] {
        return []
    }
}
