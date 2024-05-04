//
//  CommentsView.swift
//  GeoStream
//
//  Created by Matthew Dowling on 5/4/24.
//

import SwiftUI
import MapKit

struct CommentsView: View {
    @EnvironmentObject var postRowVM: PostRowViewModel
    
    var body: some View {
        Text("Comments:")
        List(postRowVM.comments) { comment in
            Text(comment.content)
        }
    }
}

#Preview {
    CommentsView().environmentObject(PostRowViewModel(post: Post(id: "1",
                                                                 userId: "1",
                                                                 timestamp: Date(),
                                                                 likes: 0,
                                                                 content: "love this app",
                                                                 type: "event",
                                                                 location: CLLocationCoordinate2D(latitude: 37.78815531914898, longitude: -122.40754586877463),
                                                                 address: "San Francisco", city: "San Francisco", country: "USA", title: "Downtown SF Party",
                                                                 imageUrl: [],
                                                                 commentIds: []), user: User(id: "1", email: "abc", displayName: "def", description: "cdf", photoURL: "dfs", followerIds: [], followingIds: [], favPost: []), age: 0))
}
