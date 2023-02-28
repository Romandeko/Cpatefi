//
//  Playlist.swift
//  Cpatefi
//
//  Created by Роман Денисенко on 18.12.22.
//

import Foundation

struct Playlist : Codable{
    let description : String
    let external_urls : [String:String]
    let id : String
    let images: [APIIMage]
    let name: String
    let owner : User
}
