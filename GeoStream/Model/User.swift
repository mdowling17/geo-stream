//
//  User.swift
//  GeoStream
//
//  Created by Zirui Wang on 4/29/24.
//

import Foundation

struct User: Identifiable, Codable {
    let id: String
    let email: String
    let userName: String?
    let description: String?
    let profileImgUrl: String?
}
