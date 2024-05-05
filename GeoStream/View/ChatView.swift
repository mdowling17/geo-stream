//
//  ChatView.swift
//  GeoStream
//
//  Created by Matthew Dowling on 5/2/24.
//

import SwiftUI

struct ChatView: View {
    @StateObject var chatVM = ChatViewModel()

    var body: some View {
        NavigationStack {
            
//            HStack {
//                TextField("Search users", text: $chatVM.searchQuery)
//                    .disableAutocorrection(true)
//                    .textInputAutocapitalization(.never)
//                    .padding(10)
//                    .background(Color(.systemGray6))
//                    .cornerRadius(8)
//
//                Button {
//                    chatVM.searchUsers()
//                } label: {
//                    if chatVM.showSearchButton {
//                        Image(systemName: "magnifyingglass")
//                            .foregroundColor(.gray)
//                    } else {
//                        Image(systemName: "xmark")
//                            .foregroundColor(.gray)
//                    }
//
//                }
//                .padding(.trailing, 4)
//
//                Button {
//                    chatVM.toggleSearchSettings()
//                } label: {
//                    Image(systemName: "gearshape.fill")
//                        .foregroundColor(.gray)
//                }
//                .padding(.trailing)
//            }
//            .background(Color(.systemGray6))
            
            Text("Messages")
                .font(.title)
                .padding()
            ZStack {
                FollowersListView().environmentObject(chatVM)
            }
        }
        .fullScreenCover(isPresented: $chatVM.showIndividualChat) {
            IndividualChatView().environmentObject(chatVM)
        }
    }
}

#Preview {
    ChatView()
}
