//
//  PlaylistDetailResponse.swift
//  Cpatefi
//
//  Created by Роман Денисенко on 9.01.23.
//

import Foundation

struct PlaylistDetailsResponse : Codable{
    let description : String
    let external_urls : [String:String]
    let id : String
    let images : [APIIMage]
    let name : String
    let tracks : PlaylistTracksResponse
}

struct PlaylistTracksResponse : Codable{
    let items: [PlaylistItem]
}

struct PlaylistItem : Codable{
    let track: AudioTrack
}
