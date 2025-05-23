//
//  CommentElementView.swift
//  Textie
//
//  Created by 하정우 on 5/9/25.
//

import SwiftUI

struct CommentElementView: View {
    var commentData: CommentData
    @State private var showMore: Bool = false
    
    var body: some View {
        let isClipped: Bool = commentData.content.count > 30
        
        HStack(alignment: .top) {
            ProfileImageView()
                .frame(width: 44, height: 44)
            VStack(alignment: .leading) {
                HStack {
                    Text(commentData.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Text("⋅")
                    Text(Date.relativeTime(commentData.createdAt))
                        .font(.subheadline)
                }
                Group {
                    if isClipped {
                        if showMore == false {
                            Text("\(commentData.content.prefix(30))...")
                                .font(.body)
                                .fontWeight(.light)
                            Text("SEE_MORE")
                                .font(.subheadline)
                                .onTapGesture {
                                    showMore.toggle()
                                }
                        } else {
                            Text(commentData.content)
                                .font(.body)
                            Text("SEE_LESS")
                                .font(.subheadline)
                                .onTapGesture {
                                    showMore.toggle()
                                }
                        }
                    } else {
                        Text(commentData.content)
                            .font(.body)
                    }
                }
            }
        }
    }
}

#Preview {
    CommentElementView(commentData: CommentData(id: UUID(), name: "John", createdAt: Date(), content: "placeholder text"))
}
