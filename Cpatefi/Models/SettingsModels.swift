//
//  SettingsModels.swift
//  Cpatefi
//
//  Created by Роман Денисенко on 19.12.22.
//

import Foundation

struct Section{
    let title : String
    let options : [Option]
}

struct Option{
    let title : String
    let handler : () -> Void
}
