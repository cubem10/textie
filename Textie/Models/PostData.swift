//
//  PostData.swift
//  Textie
//
//  Created by 하정우 on 4/30/25.
//

import Foundation

struct PostDataDTO: Identifiable, Decodable {
    let isEdited: Bool
    let title: String
    let createdAt: String
    let content: String
    let id: UUID
    let userId: UUID
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case isEdited = "is_edited"
        case title
        case createdAt = "created_at"
        case content
        case id
        case userId = "user_id"
        case updatedAt = "updated_at"
    }
}

struct PostData: Identifiable, Decodable {
    let id: UUID
    let name: String
    
    var content: String
    var likes: Int
}

extension PostData {
    static func construct(post: PostDataDTO, likes: Int = 0) -> PostData {
        return PostData(
            id: post.id,
            name: post.userId.uuidString, // MARK: need to implement API that fetches username with UUID
            content: post.content,
            likes: likes
        )
    }
}

struct CommentDataDTO: Identifiable, Decodable {
    let createdAt: String
    let postId: UUID
    let id: UUID
    let content: String
    let userId: UUID
    
    enum CodingKeys: String, CodingKey {
        case createdAt = "created_at"
        case postId = "post_id"
        case id
        case content
        case userId = "user_id"
    }
}

struct CommentData: Identifiable, Decodable {
    let id: UUID
    let name: String
    let profileImageURL: URL?
    
    var content: String
}

struct LikeDataDTO {
    let postId: UUID
    let likeCount: Int
    
    enum CodingKeys: String, CodingKey {
        case postId = "post_id"
        case likeCount = "like_count"
    }
}

func fetchPost() async -> [PostData] {
    // TODO: implement API call
    
    return [
        PostData(id: UUID(), name: "John Appleseed", content: "Lorem ipsum dolor sit amet.", likes: 100),
        PostData(id: UUID(), name: "John Appleseed", content: "Lorem ipsum dolor sit amet.Lorem ipsum dolor sit amet.Lorem ipsum dolor sit amet.Lorem ipsum dolor sit amet.Lorem ipsum dolor sit amet.Lorem ipsum dolor sit amet.Lorem ipsum dolor sit amet.Lorem ipsum dolor sit amet.Lorem ipsum dolor sit amet.Lorem ipsum dolor sit amet.Lorem ipsum dolor sit amet.Lorem ipsum dolor sit amet.Lorem ipsum dolor sit amet.Lorem ipsum dolor sit amet.Lorem ipsum dolor sit amet.Lorem ipsum dolor sit amet.Lorem ipsum dolor sit amet.Lorem ipsum dolor sit amet.Lorem ipsum dolor sit amet.Lorem ipsum dolor sit amet.Lorem ipsum dolor sit amet.Lorem ipsum dolor sit amet.Lorem ipsum dolor sit amet.", likes: 1234)
    ]
}

func fetchComments(forPostWithId postId: UUID) async -> [CommentData] {
    // TODO: implement API call
    
    return [
        CommentData(id: UUID(), name: "Jane Doe", profileImageURL: URL(string: "https://example.com/john.jpg")!, content: "Hello!"),
        CommentData(id: UUID(), name: "John Doe", profileImageURL: URL(string: "https://example.com/john.jpg")!, content: "Hi!"),
    ]
}
