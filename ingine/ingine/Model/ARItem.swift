//
//  ARItem.swift
//  ingine
//
//  Created by Manish Dadwal on 08/10/20.
//  Copyright © 2020 ingine. All rights reserved.
//

import Foundation
struct IngineeredItem {
    var id = ""
    var refImage = ""
    var itemName = ""
    var itemURL = ""
    var visStatus = false
    var lastupdated:Date?

    
}
struct ARItem:Codable {
    var id :String?
    var name:String?
    var refImage:String?
    var matchURL:String?
    var `public` :Bool?
    var lastupdated:Date?
}
