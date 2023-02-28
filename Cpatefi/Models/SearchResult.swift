//
//  SearchResult.swift
//  Cpatefi
//
//  Created by Роман Денисенко on 3.02.23.
//

import Foundation
enum SearchResult{
    case artist(model : Artist)
    case album(model : Album)
    case track(model : AudioTrack)
    case playlist(model : Playlist)
}
