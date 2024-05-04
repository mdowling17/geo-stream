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
    var age: Int
    @StateObject var postVM = PostViewModel()
    
    var body: some View{
        VStack(alignment: .leading) {
                HStack(alignment: .top, spacing: 20) {
                    if let img = postVM.userImg {
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFill()
                            .clipShape(Circle())
                            .frame(width: 56, height: 56)
                            .foregroundColor(Color.green)
                    } else {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .scaledToFill()
                            //.clipShape(Circle())
                            .frame(width: 56, height: 56)
                            .foregroundColor(Color.green)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        
                        HStack {
                            Text("@\(postVM.user?.displayName ?? "NA")")
                                .font(.subheadline).bold()
                            Spacer()
                            
                            HStack{
                                Image(systemName: "clock")
                                    .foregroundColor(.gray)
                                Text("\(age) hours ago")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        Text(post.content)
                            .font(.subheadline)
                            .multilineTextAlignment(.leading)
                    }
                }
                ButtonsView
                Divider()
        }.onAppear {
            Task {
                await postVM.fetchUser(post.userId)
                await postVM.fetchUserImg(post.userId)
            }
        }
    }
}

extension PostView {
    var ButtonsView: some View {
        HStack {
            Button {
                //Action here
            } label: {
                 Image(systemName: "bubble.left")
                    .font(.subheadline)
            }
            
            Spacer()
            
            Button {
                //viewModel.post.didLike ?? false ? viewModel.unlikePost() : viewModel.likePost()
            } label: {
                Image(systemName:"heart")
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
    PostView(post: Post(id: "1",
                        userId: "1",
                        timestamp: Date(),
                        likes: 0,
                        content: "love this app",
                        type: "event",
                        location: CLLocationCoordinate2D(latitude: 37.78815531914898, longitude: -122.40754586877463),
                        address: "San Francisco", city: "San Francisco", country: "USA", title: "Downtown SF Party",
                        imageUrl: [],
                        commentIds: []),
             age: 10)
}
