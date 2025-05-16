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
    let updatedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case isEdited = "is_edited"
        case title
        case createdAt = "created_at"
        case content = "context"
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

struct CommentResponseDTO: Decodable {
    let postId: UUID
    let comments: [CommentDataDTO]
    
    enum CodingKeys: String, CodingKey {
        case postId = "post_id"
        case comments
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
    
    var content: String
}

extension CommentData {
    static func construct(comment: CommentDataDTO) -> CommentData {
        return CommentData(
            id: comment.id,
            name: comment.userId.uuidString, // MARK: need to implement API that fetches username with UUID
            content: comment.content
        )
    }
}

struct LikeDataDTO: Decodable {
    let postId: UUID
    let likeCount: Int
    
    enum CodingKeys: String, CodingKey {
        case postId = "post_id"
        case likeCount = "like_count"
    }
}

func fetchPost(offset: Int = 0, limit: Int = 10) async -> [PostData] {
    print("fetchPost started")
    var postDatas: [PostData] = []
    
    guard let (postResponseData, _): (Data, URLResponse) = try? await sendRequestToServer(toEndpoint: serverURLString + "/posts/?offset=\(offset)&limit=\(limit)", httpMethod: "GET") else {
        print("An error occurred while fetching posts.")
        return postDatas
    }
    
    guard let decodedPostResponse: [PostDataDTO] = try? JSONDecoder().decode([PostDataDTO].self, from: postResponseData) else {
        print("An error occurred while decoding posts data.")
        print(String(data: postResponseData, encoding: .utf8) ?? "")
        return postDatas
    }
    
    for postDataDTO in decodedPostResponse {
        guard let (likeResponseData, _): (Data, URLResponse) = try? await sendRequestToServer(toEndpoint: serverURLString + "/posts/\(postDataDTO.id)/likes/count", httpMethod: "GET") else {
            print("An error occurred while fetching likes.")
            return postDatas
        }
        
        guard let decodedLikesResponse: LikeDataDTO = try? JSONDecoder().decode(LikeDataDTO.self, from: likeResponseData) else {
            print("An error occurred while decoding likes data.")
            return postDatas
        }
        
        postDatas.append(PostData.construct(post: postDataDTO, likes: decodedLikesResponse.likeCount))
    }
    
    print(postDatas)
    return postDatas
}

func fetchComments(offset: Int, limit: Int, forPostWithId postId: UUID) async -> [CommentData] {
    print("Fetching comments...")
    var comments: [CommentData] = []
    
    guard let (response, _): (Data, URLResponse) = try? await sendRequestToServer(toEndpoint: serverURLString + "/posts/\(postId)/comments/?offset=\(offset)&limit=\(limit)", httpMethod: "GET") else {
        print("An error occurred while fetching comments.")
        return comments
    }
    
    print(String(data: response, encoding: .utf8) ?? "")
    
    guard let decodedComments: CommentResponseDTO = try? JSONDecoder().decode(CommentResponseDTO.self, from: response) else {
        print("An error occurred while decoding comments.")
        return comments
    }
    
    
    for comment in decodedComments.comments {
        comments.append(CommentData.construct(comment: comment))
    }

    print("Comments: \(comments)")
    return comments
}
