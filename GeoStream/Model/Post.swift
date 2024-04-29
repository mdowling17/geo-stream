//
//  Post.swift
//  GeoStream
//
//  Created by Zirui Wang on 4/26/24.
//

import Foundation

struct Post: Identifiable, Codable {
    let id: String
    let userId: String
    let time: Date
    var likes: Int
    let content: String
    //let location: (Float, Float)
    let type: Int //0: event, 1: alert, 2: review
}
