//
//  MessageView.swift
//  GeoStream
//
//  Created by Matthew Dowling on 5/2/24.
//

import SwiftUI
import SDWebImageSwiftUI

struct MessageView: View {
    var message: Message
    
    var body: some View {
        if message.fromUserId == AuthService.shared.currentUser?.uid {
            HStack(alignment: .bottom) {
                HStack {
                    Text(message.text)
                        .padding()
                        .foregroundColor(Color(.systemBackground))
                        .background(.app)
                        .cornerRadius(20)
                }
                .frame(maxWidth: 260, alignment: .trailing)
                
                if let photoURL = message.fetchPhotoURL() {
                    AnimatedImage(url: photoURL)
                        .resizable()
                        .indicator(.activity)
                        .frame(maxWidth: 32, maxHeight: 32)
                        .scaledToFill()
                        .clipShape(Circle())
                        .padding(.bottom, 4)
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(maxWidth: 32, maxHeight: 32)
                        .scaledToFill()
                        .foregroundColor(.app)
                        .padding(.bottom, 4)
                }
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.trailing)
        } else {
            HStack(alignment: .bottom) {
                if let photoURL = message.fetchPhotoURL() {
                    AnimatedImage(url: photoURL)
                        .resizable()
                        .indicator(.activity)
                        .frame(maxWidth: 32, maxHeight: 32)
                        .scaledToFill()
                        .clipShape(Circle())
                        .padding(.bottom, 4)
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(maxWidth: 32, maxHeight: 32)
                        .scaledToFill()
                        .foregroundColor(.gray)
                        .padding(.bottom, 4)
                }
                
                HStack {
                    Text(message.text)
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(20)
                }
                .frame(maxWidth: 260, alignment: .leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading)
        }
    }
}

#Preview {
    MessageView(message: Message(id: "1", toUserId: "1", fromUserId: "Y7FiKUqWZfS8FYGRoOb1WfXreDE3", toPostId: "0", text: "Hello my name is matt dowling and this is going to be a really long multi-line message", photoURL: "https://images.unsplash.com/photo-1554080353-a576cf803bda?q=80&w=1000&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NHx8cGhvdG98ZW58MHx8MHx8fDA%3D", createdAt: Date()))
}
