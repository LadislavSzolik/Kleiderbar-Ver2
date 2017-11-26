//
//  Clothes.swift
//  Kleiderbar Ver2
//
//  Created by Ladislav Szolik on 11.11.17.
//  Copyright © 2017 Ladislav Szolik. All rights reserved.
//

import Foundation

struct ClothesCategory: Equatable, Codable {
    var id: Int
    var name: String
    
    static var all: [ClothesCategory] {
        return [ ClothesCategory(id:1, name: "Bodies" ), ClothesCategory(id:2, name: "T-Shirt, Langarm" ), ClothesCategory(id:3, name: "Oberteile" ),ClothesCategory(id:4, name: "Hosen" ), ClothesCategory(id:5, name: "Röckli" ),
                 ClothesCategory(id:6, name: "Pullis, Jägglis, Gilets" ), ClothesCategory(id:7, name: "Jacken" ), ClothesCategory(id:8, name: "Pyjamas, Strampler" ),ClothesCategory(id:9, name: "Kopfbedeckung, Halstücher" ), ClothesCategory(id:10, name: "Schlaf- und Fusssäcke" ),
                 ClothesCategory(id:11, name: "Bettwäsche" ), ClothesCategory(id:12, name: "Skisachen" ), ClothesCategory(id:13, name: "Handschuhe" ),ClothesCategory(id:14, name: "Fleece" ), ClothesCategory(id:15, name: "Schuhe" ),
                 ClothesCategory(id:16, name: "Finken" ), ClothesCategory(id:17, name: "Sportsachen" ), ClothesCategory(id:18, name: "Regensachen" ),ClothesCategory(id:19, name: "Kinderwagen, Buggy" ), ClothesCategory(id:20, name: "Badesachen" ),
                 ClothesCategory(id:21, name: "Kombi" ), ClothesCategory(id:22, name: "Strumpfhosen, Spezialsocken" ), ClothesCategory(id:23, name: "Unterhemden" ),ClothesCategory(id:24, name: "Brillen" ), ClothesCategory(id:25, name: "Spiele" ),
                 ClothesCategory(id:26, name: "Bilderbücher" ), ClothesCategory(id:27, name: "Spielsachen" ), ClothesCategory(id:28, name: "Anderes" )]
    }
    
    static func ==(lhs: ClothesCategory, rhs: ClothesCategory) -> Bool {
        return lhs.id == rhs.id
    }
    
}


struct Clothes: Codable {
    var id: Int
    var category: ClothesCategory
    var price: Double?
    var dateOfCreation: Date
    var status: ClothesStatus
    var moneyGivenBack: Bool
    
    static var globalId = 0
    static func getNextId() -> Int {
        let currentId = Clothes.globalId
        Clothes.globalId = Clothes.globalId + 1
        return  currentId
    }
}

enum ClothesStatus: String, Codable  {
    case inShop = "inShop"
    case sold = "sold"
    case inStore = "inStore"
}
