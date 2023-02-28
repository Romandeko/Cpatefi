//
//  AlbumDetailsResponse.swift
//  Cpatefi
//
//  Created by Роман Денисенко on 9.01.23.
//

import Foundation

struct AlbumDetailsResponse : Codable{
    let album_type : String
    let artists : [Artist]
    let available_markets : [String]
    let id : String
    let images : [APIIMage]
    let label : String
    let name : String
    let tracks : TracksResponse
}

struct TracksResponse : Codable {
    let items : [AudioTrack]
}
