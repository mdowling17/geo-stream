//
//  PostView.swift
//  GeoStream
//
//  Created by Zirui Wang on 5/1/24.
//

import Foundation
import SwiftUI
import CoreLocation

struct PostView: View {
    var post: Post
    var user: User?
    
    var body: some View{
        VStack(alignment: .leading) {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "person")
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(user!.email)
                                .font(.subheadline).bold()
                            
                            Text("@")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            Text("2w")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        Text(post.content)
                            .font(.subheadline)
                            .multilineTextAlignment(.leading)
                    }
                }
                
                ButtonsView()
                
                Divider()
        }
    }
}


struct ButtonsView: View {
    var body: some View {
        HStack {
            Button {
                //Action here
            } label: {
                 Image(systemName: "bubble.left")
                    .font(.subheadline)
            }
            
            Spacer()
            
            Button {
                    //Action here
            } label: {
                Image(systemName: "arrow.2.squarepath")
                    .font(.subheadline)
            }
            
            Spacer()
            
            Button {
                //viewModel.post.didLike ?? false ? viewModel.unlikePost() : viewModel.likePost()
            } label: {
//                Image(systemName: viewModel.post.didLike ?? false ? "heart.fill" : "heart")
//                    .font(.subheadline)
//                    .foregroundColor(viewModel.post.didLike ?? false ? .red : .gray)
            }
            
            Spacer()
            
            Button {
                    //Action here
            } label: {
                Image(systemName: "bookmark")
                    .font(.subheadline)
            }
        }
        .padding()
        .foregroundColor(.gray)
    }
}

#Preview {
    PostView(post: Post(id: "first", userId: "abc", timestamp: Date(), likes: 0, content: "yes", type: "event", location: CLLocationCoordinate2D(latitude: 37.78815531914898, longitude: -122.40754586877463), imageUrl: [], commentId: []),
             user: User(email: "abc", userName: "def", description: "hahaha", profileImgUrl: "abc"))
}
