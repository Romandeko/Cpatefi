//
//  AuthResponse.swift
//  Cpatefi
//
//  Created by Роман Денисенко on 19.12.22.
//

import Foundation

struct AuthResponse : Codable{
    let access_token : String
    let expires_in : Int
    let refresh_token : String?
    let scope : String
    let token_type : String
}
