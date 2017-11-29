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

struct UniqueClothesId: Codable {
    var id:Int
}

struct Clothes: Codable {
    var id: Int
    var category: ClothesCategory
    var price: Double?
    var dateOfCreation: Date
    var dateOfSell:Date?
    var dateOfStore: Date?
    var status: ClothesStatus
    var moneyGivenBack: Bool
    
    static var globalId = 0
    static func getNextId() -> Int {
        let currentId = Clothes.globalId
        Clothes.globalId = Clothes.globalId + 1
        return  currentId
    }
    
    static let DocumentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("clothesLastId")
    
    static func saveClothesId(_ clothesId: Int) {
        let id =  UniqueClothesId(id: clothesId)
        let propertyListEncoder = PropertyListEncoder()
        let codedId = try? propertyListEncoder.encode(id)
        try? codedId?.write(to: ArchiveURL, options: .noFileProtection)
    }
    
    static func loadLastClothesId() -> Int {
        guard let codedId = try? Data(contentsOf: ArchiveURL) else {return 0}
        let propertyListDecoder = PropertyListDecoder()
        if let clothesId = try? propertyListDecoder.decode(UniqueClothesId.self, from: codedId) {
             return clothesId.id
        } else {
            return 0
        }
    }
    
    static func getClothesListBasedOnIds(from listOfClothes: [String: [Clothes]], idList listOfClothesId: [Int]  ) -> [String: [Clothes]] {
        let listOfFilteredClothes = listOfClothes.mapValues { (listOfClothes) -> [Clothes] in
            return listOfClothes.filter({ (clothes) -> Bool in
                return listOfClothesId.contains(where: { (id) -> Bool in
                    return id == clothes.id
                })
            })
        }
        return listOfFilteredClothes
    }
    
    static func createNewClothesList(from listOfClothes: [String: [Clothes]], idList listOfClothesId: [Int] , to status: ClothesStatus ) -> [String: [Clothes]] {
        // Prepare new section header
        let newDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        let newDateString = dateFormatter.string(from: newDate)
        
        // Prepare new list of clothes
        let listOfClothesAllValues = listOfClothes.map{ $0.value }
        let flatListOfClothesAllValues = listOfClothesAllValues.flatMap{ $0.map({ (clothes) -> Clothes in
            var item = clothes
            switch status {
            case .sold:  item.dateOfSell = newDate
            case .inStore: item.dateOfStore = newDate
            default:
                    break
            }
           
            return item
        }) }        
        let relevantListOfClothesValues = flatListOfClothesAllValues.filter({ (clothes) -> Bool in
            return listOfClothesId.contains(clothes.id)
        })
        
        var newListOfClothes = [String : [Clothes]]()
        newListOfClothes[newDateString] = relevantListOfClothesValues
        return newListOfClothes
    }
    
    static func removeFromClothesList(from listOfCurrentClothes: [String: [Clothes]], idList listOfClothesId: [Int] ) -> [String: [Clothes]] {
        var newlistOfClothes =  [String: [Clothes]]()
        
        for currentClothes in listOfCurrentClothes {
            let truncatedList = currentClothes.value.filter({ (clothes) -> Bool in
                return !listOfClothesId.contains(where: { (id) -> Bool in
                    return id == clothes.id
                })
            })
            newlistOfClothes[currentClothes.key] = truncatedList
        }
        return newlistOfClothes
    }
    
    
    static func appendClothesList(list listOfCurrentClothes: [String: [Clothes]], with listOfNewClothes: [String: [Clothes]]) -> [String: [Clothes]] {
        var listOfCurrentClothes = listOfCurrentClothes
        if listOfNewClothes.count > 0 {
            for newClothesKey in listOfNewClothes {
                let creationDate = newClothesKey.key
                
                if listOfCurrentClothes.contains(where: { (key, value) -> Bool in
                    return key == creationDate
                }) {
                    var listOfSubClothes = listOfCurrentClothes[creationDate]
                    listOfSubClothes?.append(contentsOf: newClothesKey.value)
                    listOfCurrentClothes.updateValue(listOfSubClothes!, forKey: creationDate)
                } else {
                    listOfCurrentClothes[creationDate] = newClothesKey.value
                }
            }
        }
        return listOfCurrentClothes
    }
        
    
}

enum ClothesStatus: String, Codable  {
    case inShop = "inShop"
    case sold = "sold"
    case inStore = "inStore"
}
