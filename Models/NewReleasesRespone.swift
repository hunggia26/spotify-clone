//
//  NewReleasesRespone.swift
//  Spotify
//
//  Created by Hung Truong on 19/04/2024.
//

import Foundation

struct NewReleasesRespone: Codable {
    let albums: AlbumsResponse
}
struct AlbumsResponse: Codable {
    let items: [Album]
}
struct Album: Codable {
    let album_type: String
    let available_markets: [String]
    let id: String
    var images: [APIImage]
    let name: String
    let release_date: String
    let total_tracks: Int
    let artists: [Artist]
}

