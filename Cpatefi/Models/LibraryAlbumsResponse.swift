//
//  LibraryAlbumsResponse.swift
//  Cpatefi
//
//  Created by Роман Денисенко on 18.02.23.
//

import Foundation

struct LibraryAlbumsResponse : Codable {
    let items : [SavedAlbum]
}

struct SavedAlbum : Codable{
    let added_at : String
    let album : Album
}
