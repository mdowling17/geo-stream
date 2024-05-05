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
        let age = Calendar.current.dateComponents([.hour], from: post.timestamp, to: Date()).hour ?? 0
        _postRowVM = StateObject(wrappedValue: PostRowViewModel(post: post, user: user, age: age))
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
                        Spacer()
                    }
                    Text(postRowVM.post.content)
                        .font(.subheadline)
                        .multilineTextAlignment(.leading)
                }
            }
            ButtonsView(age: postRowVM.age).environmentObject(postRowVM)
            Divider()
            
            if postRowVM.showComment {
                CommentsView()
                    .environmentObject(postRowVM)
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
                           commentIds: []), user: User(id: "1", email: "abc", displayName: "def", description: "cdf", photoURL: "dfs", followerIds: [], followingIds: [], likedPostIds: [])
                )
}
