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
    var post: Post
    var user: User?
    
    func getAge(time: Date) -> Int {
        return Calendar.current.dateComponents([.hour], from: time, to: Date()).hour ?? 0
    }
    
    var body: some View{
        HStack(spacing: 20) {
            if let user = user, let photoURL = user.getPhotoURL() {
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
                    Text("@\(user?.displayName ?? "")")
                        .font(.subheadline).bold()
                    Text("\(getAge(time: post.timestamp)) hours ago")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Spacer()
                }
                Text(post.content)
                    .font(.subheadline)
                    .multilineTextAlignment(.leading)
            }
        }.frame(width: 365)
        Divider()
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
                           city: "San Francisco", state: "California", country: "USA",
                           imageUrl: [],
                           commentIds: [])
                
    )
}
