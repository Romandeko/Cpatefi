//
//  AllCategoriesResponse.swift
//  Cpatefi
//
//  Created by Роман Денисенко on 31.01.23.
//

import Foundation

struct AllCategoriesResponse : Codable {
    let categories : Categories
}

struct Categories : Codable{
    let items : [Category]
}

struct Category : Codable{
    let id : String
    let name : String
    let icons: [APIIMage]
}
