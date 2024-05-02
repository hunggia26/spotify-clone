//
//  SettingsModels.swift
//  Spotify
//
//  Created by Hung Truong on 17/04/2024.
//

import Foundation

struct Section {
    let title: String
    let options: [Option]
}
struct Option {
    let title: String
    let handler: () -> Void
}
