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
    let liked: Bool
    
    enum CodingKeys: String, CodingKey {
        case isEdited = "is_edited"
        case title
        case createdAt = "created_at"
        case content = "context"
        case id
        case userId = "user_id"
        case updatedAt = "updated_at"
        case liked
    }
}

struct PostData: Identifiable, Hashable, Decodable {
    let id: UUID
    let name: String
    let title: String
    let createdAt: Date
    let userId: UUID
    let isEdited: Bool
    
    var isLiked: Bool
    var content: String
    var likes: Int
}

extension PostData {
    static func construct(post: PostDataDTO, likes: Int = 0, token: String) async throws -> PostData {
        var nickname: String = ""
        
        let (response, _): (Data, URLResponse) = try await sendRequestToServer(toEndpoint: serverURLString + "/user/\(post.userId)", httpMethod: "GET", withToken: token)
        let decodedResponse: UserProfileDTO = try JSONDecoder().decode(UserProfileDTO.self, from: response)
        nickname = decodedResponse.nickname
        
        return PostData(
            id: post.id,
            name: nickname,
            title: post.title,
            createdAt: String.convertToDate(post.createdAt),
            userId: post.userId,
            isEdited: post.isEdited,
            isLiked: post.liked,
            content: post.content,
            likes: likes
        )
    }
}

extension String {
    static func convertToDate(_ dateString: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        let date = dateFormatter.date(from: dateString)!
        
        return date
    }
}

extension Date {
    static func relativeTime(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: date, relativeTo: Date())
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
    let createdAt: Date
    var content: String
}

extension CommentData {
    static func construct(comment: CommentDataDTO, token: String) async throws -> CommentData  {
        var nickname: String = ""
        
        let (response, _): (Data, URLResponse) = try await sendRequestToServer(toEndpoint: serverURLString + "/user/\(comment.userId)", httpMethod: "GET", withToken: token)
        let decodedResponse: UserProfileDTO = try JSONDecoder().decode(UserProfileDTO.self, from: response)
        nickname = decodedResponse.nickname
        
        return CommentData(
            id: comment.id,
            name: nickname,
            createdAt: String.convertToDate(comment.createdAt),
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
