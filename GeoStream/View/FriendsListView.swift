//
//  FriendsListView.swift
//  GeoStream
//
//  Created by Matthew Dowling on 5/3/24.
//

import SwiftUI
import SDWebImageSwiftUI

struct FriendsListView: View {    
    @EnvironmentObject var chatVM: ChatViewModel
    
    var body: some View {
        List {
            ForEach(chatVM.friends) { friend in
                HStack {
                    if let photoURL = friend.getPhotoURL() {
                        WebImage(url: photoURL)
                            .resizable()
                            .frame(maxWidth: 32, maxHeight: 32)
                            .scaledToFill()
                            .cornerRadius(16)
                            .padding(.bottom, 4)
                    } else {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(maxWidth: 32, maxHeight: 32)
                            .scaledToFill()
                            .foregroundColor(.app)
                            .padding(.bottom, 4)
                    }
                    Text(friend.displayName ?? "")
                    Spacer()
                    Button {
                        chatVM.toUserId = friend.id ?? ""
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
    FriendsListView().environmentObject(ChatViewModel())
}
