//
//  PostRowView.swift
//  GeoStream
//
//  Created by Matthew Dowling on 5/4/24.
//

import SwiftUI
import SDWebImageSwiftUI
import MapKit

struct PostRowView: View {
    @StateObject var postRowVM: PostRowViewModel
    
    init(post: Post, user: User?) {
        _postRowVM = StateObject(wrappedValue: PostRowViewModel(post: post, user: user))
    }
    
    func getAge(time: Date) -> Int {
        return Calendar.current.dateComponents([.hour], from: time, to: Date()).hour ?? 0
    }
    
    var body: some View{
        VStack(alignment: .leading) {
            HStack(alignment: .top, spacing: 20) {
                if let user = postRowVM.user, let photoURL = user.getPhotoURL() {
                    AnimatedImage(url: photoURL)
                        .resizable()
                        .indicator(.activity)
                        .frame(maxWidth: 56, maxHeight: 56)
                        .scaledToFill()
                        .clipShape(Circle())
                        .padding(.bottom, 4)
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 56, height: 56)
                        .foregroundColor(Color.green)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("@\(postRowVM.user?.displayName ?? "NA")")
                            .font(.subheadline).bold()
                        Text("\(getAge(time: postRowVM.post.timestamp)) hours ago")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Spacer()
                    }
                    Text(postRowVM.post.content)
                        .font(.subheadline)
                        .multilineTextAlignment(.leading)
                }
            }
            Divider()
            if postRowVM.showComment {
                VStack{
                    ForEach(postRowVM.comments) { comment in
                        HStack {
                            Text("@\(comment.posterName)").bold()
                            Text(comment.content)
                            Spacer()
                            Text("\(getAge(time: comment.timestamp)) hours ago")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        Divider()
                        
                    }
                }
            }
        }
    }
}

#Preview {
    PostRowView(post: Post(id: "1",
                           userId: "1",
                           timestamp: Date(),
                           likes: 0,
                           content: "love this app",
                           type: "event",
                           location: CLLocationCoordinate2D(latitude: 37.78815531914898, longitude: -122.40754586877463),
                           address: "San Francisco", city: "San Francisco", country: "USA", title: "Downtown SF Party",
                           imageUrl: [],
                           commentIds: []), user: User(id: "1", email: "abc", displayName: "def", description: "cdf", photoURL: "dfs", followerIds: [], followingIds: [], favPost: [])
                )
}
