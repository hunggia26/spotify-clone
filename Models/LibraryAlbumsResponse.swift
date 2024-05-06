//
//  LibraryAlbumsResponse.swift
//  Spotify
//
//  Created by Hung Truong on 06/05/2024.
//

import Foundation

struct LibraryAlbumsResponse: Codable {
    let items: [SaveAlbum]
}

struct SaveAlbum: Codable {
    let added_at: String
    let album: Album
}
