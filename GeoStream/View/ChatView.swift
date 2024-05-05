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
