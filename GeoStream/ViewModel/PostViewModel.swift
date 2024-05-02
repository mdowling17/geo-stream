//
//  PostViewModel.swift
//  GeoStream
//
//  Created by Zirui Wang on 5/1/24.
//

import Foundation

class PostViewModel: ObservableObject {
    let postserv = PostService()
    //let userserv = AuthService()
    
    func fetchComments() {}
    
    func fetchPostImages() {}
}
