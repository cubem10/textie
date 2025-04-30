//
//  PostData.swift
//  Textie
//
//  Created by 하정우 on 4/30/25.
//

import Foundation

struct PostData: Identifiable {
    let id: UUID
    let name: String
    let profileImageURL: URL?
    
    var content: String
    var likes: Int
}

func fetchPost() async -> [PostData] {
    // TODO: implement API call
    
    return [
        PostData(id: UUID(), name: "John Appleseed", profileImageURL: URL(string: "https://example.com/john.jpg")!, content: "Lorem ipsum dolor sit amet.", likes: 100),
        PostData(id: UUID(), name: "John Appleseed", profileImageURL: URL(string: "https://example.com/john.jpg")!, content: "Lorem ipsum dolor sit amet.Lorem ipsum dolor sit amet.Lorem ipsum dolor sit amet.Lorem ipsum dolor sit amet.Lorem ipsum dolor sit amet.Lorem ipsum dolor sit amet.Lorem ipsum dolor sit amet.Lorem ipsum dolor sit amet.Lorem ipsum dolor sit amet.Lorem ipsum dolor sit amet.Lorem ipsum dolor sit amet.Lorem ipsum dolor sit amet.Lorem ipsum dolor sit amet.Lorem ipsum dolor sit amet.Lorem ipsum dolor sit amet.Lorem ipsum dolor sit amet.Lorem ipsum dolor sit amet.Lorem ipsum dolor sit amet.Lorem ipsum dolor sit amet.Lorem ipsum dolor sit amet.Lorem ipsum dolor sit amet.Lorem ipsum dolor sit amet.Lorem ipsum dolor sit amet.", likes: 1234)
    ]
}
