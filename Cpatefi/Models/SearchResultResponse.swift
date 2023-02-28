//
//  SearchResult.swift
//  Cpatefi
//
//  Created by Роман Денисенко on 3.02.23.
//

import Foundation

struct SearchResultsResponse : Codable{
    let albums : SearchAlbumResponse
    let artists: SeartchArtistsResponse
    let playlists : SearchPlaylistsResponse
    let tracks : SearchTracksResponse
}

struct SearchAlbumResponse : Codable{
    let items : [Album]
}

struct SeartchArtistsResponse : Codable{
    let items : [Artist]
}
struct SearchPlaylistsResponse : Codable{
    let items : [Playlist]
}
struct SearchTracksResponse : Codable{
    let items : [AudioTrack]
}
