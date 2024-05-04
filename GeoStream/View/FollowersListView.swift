//
//  FriendsListView.swift
//  GeoStream
//
//  Created by Matthew Dowling on 5/3/24.
//

import SwiftUI
import SDWebImageSwiftUI

struct FollowersListView: View {    
    @EnvironmentObject var chatVM: ChatViewModel
    
    var body: some View {
        List {
            ForEach(chatVM.followers) { follower in
                HStack {
                    if let photoURL = follower.getPhotoURL() {
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
                    Text(follower.displayName ?? "")
                    Spacer()
                    Button {
                        chatVM.toUserId = follower.id ?? ""
                        chatVM.showIndividualChat = true
                    } label: {
                        Image(systemName: "arrow.right.circle")
                            .foregroundColor(.blue)
                    }
                }
            }
        }
        .listStyle(.plain)
    }
}

#Preview {
    FollowersListView().environmentObject(ChatViewModel())
}
