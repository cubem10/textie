//
//  PostWriteView.swift
//  Textie
//
//  Created by 하정우 on 5/16/25.
//

import SwiftUI

struct PostWriteView: View {
    @State var text: String = ""
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: {
                    // TODO: implement API call
                }) {
                    Text("POST_WRITE_SUBMIT")
                }
            }
            ZStack {
                TextEditor(text: $text)
                
                if text.isEmpty {
                    Text("POST_WRITE_PLACEHOLDER")
                }
            }   .overlay {
                    RoundedRectangle(cornerRadius: 8).stroke(Color.black, lineWidth: 1)
                }
            Spacer()
        }.padding()
    }
}

#Preview {
    PostWriteView()
}
