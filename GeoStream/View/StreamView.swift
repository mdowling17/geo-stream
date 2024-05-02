//
//  StreamView.swift
//  GeoStream
//
//  Created by Zirui Wang on 4/29/24.
//

import SwiftUI
import MapKit

//struct StreamView: View {
//    @StateObject var manager = LocationManager()
//    
//    var body: some View {
//        Map(coordinateRegion: $manager.region, showsUserLocation: true)
//                .edgesIgnoringSafeArea(.all)
//        }
//}

struct StreamView: View {
    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var searchResults: [Post] = []
    @State private var selectedResult: Post?
    @State private var showPostView: Bool = false
    
    var body: some View {
        NavigationView{
            VStack{
                MenuBarView(searchResults: $searchResults)
                ZStack{
                    Map(position: $position, selection: $selectedResult){
                        ForEach(searchResults, id: \.id) {
                            result in
                            if (result.type == "event") {
                                Marker("Event", systemImage: "calendar", coordinate: result.location)
                                    .tint(.orange)
                                    .tag(result)
                            }
                            else if (result.type == "alert") {
                                Marker("Alert", systemImage: "exclamationmark.circle", coordinate: result.location)
                                    .tint(.red)
                                    .tag(result)
                            }
                            else if (result.type == "review") {
                                Marker("Review", systemImage: "list.star", coordinate: result.location)
                                    .tint(.green)
                                    .tag(result)
                            }
                        }
                    }.mapControls{
                        MapUserLocationButton()
                        MapCompass()
                        MapScaleView()
                    }.safeAreaInset(edge: .bottom){
                        HStack{
                            Spacer()
                            if let post = selectedResult {
                                PostPreView(post: post)
                                    .frame(height: 100)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .padding([.top, .horizontal])
                            }
                            Spacer()
                        }.background(.thinMaterial)
                    }
                    
                    NavigationLink(destination: CreatePostView()){
                        Text("+ Create Post")
                            .bold()
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                    }.offset(x: CGFloat(-110.0),
                             y: CGFloat(-290.0))
                }
            }
        }
    }
}

struct PostPreView: View {
    var post: Post
    
    var body: some View {
        VStack{
            HStack(alignment: .center){
                Text("Someone posted this")
                Text(post.type)
                Text("\(calculateDuration(now: Date(), date: post.timestamp)) hours ago")
            }
            NavigationLink(destination: PostView(post: post)){
                Label("Check Detail", systemImage: "arrowshape.right.circle")
            }
        }
    }
    
    func calculateDuration(now: Date, date: Date) -> Int {
        let diffs = Calendar.current.dateComponents([.hour, .minute], from: now, to: date)
        return diffs.hour ?? 0
    }
}

struct MenuBarView: View {
    @Binding var searchResults: [Post]
    
    var body: some View {
        HStack(alignment: .center) {
            Spacer()
            Button(action: {search(24)}) {
                Text("Past 24 hours").padding().foregroundStyle(.white)
            }
            Button(action: {search(12)}) {
                Text("Past 12 hours").padding().foregroundStyle(.white)
            }
            Button(action: {search(6)}) {
                Text("Past 6 hours").padding().foregroundStyle(.white)
            }
            Button(action: {search(1)}) {
                Text("Past hour").padding().foregroundStyle(.white)
            }
            Spacer()
        }
        .background(Color.gray)
    }
    
    func search(_ hour: Int) {
        // need to implement actually function that fetch posts within MapCamera and specific time
        searchResults = [
            Post(id: "first", userId: "abc", timestamp: Date(), likes: 0, content: "yes", type: "event", location: CLLocationCoordinate2D(latitude: 37.78815531914898, longitude: -122.40754586877463), imageUrl: [], commentId: []),
            Post(id: "second", userId: "cde", timestamp: Date(), likes: 0, content: "no", type: "alert", location: CLLocationCoordinate2D(latitude: 37.784951824864464, longitude: -122.40220161414518), imageUrl: [], commentId: []),
            Post(id: "third", userId: "def", timestamp: Date(), likes: 0, content: "yes", type: "review", location: CLLocationCoordinate2D(latitude: 37.78930690593879, longitude: -122.39700979660641), imageUrl: [], commentId: []),
            Post(id: "forth", userId: "efg", timestamp: Date(), likes: 0, content: "yes", type: "event", location: CLLocationCoordinate2D(latitude: 37.77949484957832, longitude: -122.41768564428206), imageUrl: [], commentId: []),
            Post(id: "fifth", userId: "efg", timestamp: Date(), likes: 0, content: "yes", type: "event", location: CLLocationCoordinate2D(latitude: 37.3323916038548, longitude: -122.00604306620986), imageUrl: [], commentId: []),
        ]
    }
}

#Preview {
    StreamView()
}
