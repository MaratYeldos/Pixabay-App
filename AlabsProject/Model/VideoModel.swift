//
//  VideoModel.swift
//  AlabsProject
//
//  Created by Yeldos Marat on 19.01.2022.
//

import Foundation

// MARK: - Welcome
struct VideoHit: Codable {
    let total, totalHits: Int
    let hits: [VideoModel]
}


// MARK: - Hit
struct VideoModel: Codable {
    let id: Int
    let pageURL: String
    let type: String
    let tags: String
    let duration: Int
    let pictureID: String
    let videos: Videos
    let views, downloads, likes, comments: Int
    let userID: Int
    let user: String
    let userImageURL: String

    enum CodingKeys: String, CodingKey {
        case id, pageURL, type, tags, duration
        case pictureID = "picture_id"
        case videos, views, downloads, likes, comments
        case userID = "user_id"
        case user, userImageURL
    }
}

// MARK: - Videos
struct Videos: Codable {
    let large, medium, small, tiny: Large?
}

// MARK: - Large
struct Large: Codable {
    let url: String?
    let width, height, size: Int?
}
