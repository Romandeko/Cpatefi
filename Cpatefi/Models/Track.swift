//
//  Track.swift
//  Cpatefi
//
//  Created by Роман Денисенко on 18.12.22.
//

import Foundation
import MusicKit
struct AudioTrack : Codable{
    var album : Album?
    let artists : [Artist]
    let available_markets: [String]
    let disc_number: Int
    let duration_ms: Int
    let explicit: Bool
    let external_urls: [String:String]
    let id : String
    let name : String
    let preview_url : String?
}
