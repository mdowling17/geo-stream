//
//  ButtonsView.swift
//  GeoStream
//
//  Created by Matthew Dowling on 5/4/24.
//

import SwiftUI

struct ButtonsView: View {
    @EnvironmentObject var postRowVM: PostRowViewModel
    var age: Int
    
    var body: some View {
        HStack {
            Button {
                postRowVM.toggleShowComment()
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
            HStack{
                Image(systemName: "clock")
                    .foregroundColor(.gray)
                Text("\(age) hours ago")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .foregroundColor(.gray)
    }
}

#Preview {
    ButtonsView(age: 23)
}
