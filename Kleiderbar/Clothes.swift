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

struct Clothes: Codable, Equatable {
    static func ==(lhs: Clothes, rhs: Clothes) -> Bool {
        return lhs.id == rhs.id
    }
    
    static func < (lhs: Clothes, rhs: Clothes) -> Bool {
        return lhs.id < rhs.id
    }
    
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
    static func getClothesArray(from listOfClothes: [String: [Clothes]]) ->  [Clothes] {
        let listOfClothesAllValues = listOfClothes.map{ $0.value }
        let flatListOfClothesAllValues = listOfClothesAllValues.flatMap{ $0}
        return flatListOfClothesAllValues
    }
    
    
    static func getClothesArrayById(from listOfClothes: [String: [Clothes]], idList listOfClothesId: [Int]  ) ->  [Clothes] {
        var clothesArray = Clothes.getClothesArray(from: listOfClothes)
        clothesArray = clothesArray.filter({ (clothes) -> Bool in
            return listOfClothesId.contains(clothes.id)
        })
        return clothesArray
    }
    
    static func mergeClothesArrayToDictionaryBasedOnDateOfCreation(inArray arrayOfClothes: [Clothes], target listOfClothes: [String: [Clothes]] ) -> [String: [Clothes]] {
        var listOfMergedClothes = listOfClothes
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        
        for clothes in arrayOfClothes {
            let clothesDate = dateFormatter.string(from: clothes.dateOfCreation)
            if listOfMergedClothes.contains(where: { (key, value) -> Bool in
                return key == clothesDate
            }) {
                if var currentList = listOfMergedClothes[clothesDate] {
                    currentList.append(clothes)
                    currentList = currentList.sorted(by: { (clothes1, clothes2) -> Bool in
                        return clothes1.id < clothes2.id
                    })
                    listOfMergedClothes.updateValue(currentList, forKey: clothesDate)
                }
            }
        }
        return listOfMergedClothes
        
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
    
    static func createNewClothesListFromArray(from arrayOfClothes: [Clothes] ) -> [String: [Clothes]] {
        var newListOfClothes = [String : [Clothes]]()
       
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd. MM. yyyy"
        
        for clothes in arrayOfClothes {
           
            let clothesDate = dateFormatter.string(from: clothes.dateOfCreation)
            
            if newListOfClothes.contains(where: { (key, value) -> Bool in
                return key == clothesDate
            }) {
                if var currentList = newListOfClothes[clothesDate] {
                    currentList.append(clothes)
                   /* currentList = currentList.sorted(by: { (clothes1, clothes2) -> Bool in
                        return clothes1.id > clothes2.id
                    }) */
                    newListOfClothes.updateValue(currentList, forKey: clothesDate)
                }
            } else {
                var newList = [Clothes]()
                newList.append(clothes)
                newListOfClothes[clothesDate] = newList
            }
        }
       
        return newListOfClothes
    }
    
    
    
    static func removeFromClothesList(from listOfCurrentClothes: [ClothesTable], idList selectedClothes: [Clothes] ) -> [ClothesTable] {
        let newlistOfClothes = listOfCurrentClothes.map { (clothesTable) -> ClothesTable in
            var item = clothesTable
            item.clothesList = item.clothesList.filter({ (clothes) -> Bool in
                return selectedClothes.contains(where: { (clothesIn) -> Bool in
                    return clothesIn.id != clothes.id
                })
            })
            return item
        }       
        return newlistOfClothes
    }
    
    
    static func appendClothesList(list listOfCurrentClothes: [ClothesTable], with listOfNewClothes:[Clothes]) -> [ClothesTable] {
        var listOfCurrentClothes = listOfCurrentClothes
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd. MM. yyyy"
        
        if listOfNewClothes.count > 0 {
            for newClothes in listOfNewClothes {
                let creationDate =  dateFormatter.string(from: newClothes.dateOfCreation)
                
                if  let index = listOfCurrentClothes.index(where: { (clothesTable) -> Bool in
                    let clothesTableHeaderDate =  dateFormatter.string(from: clothesTable.headerDate)
                    return clothesTableHeaderDate == creationDate
                }) {
                    var listOfSubClothes = listOfCurrentClothes[index].clothesList
                    listOfSubClothes.append(newClothes)
                    listOfCurrentClothes[index].clothesList = listOfSubClothes
                } else {
                    var newClothesList = [Clothes]()
                    newClothesList.append(newClothes)
                    var clothesTable = ClothesTable(headerDate: newClothes.dateOfCreation, clothesList: newClothesList )                    
                    clothesTable.clothesList = newClothesList
                    listOfCurrentClothes.append(clothesTable)
                }
            }
        }
        return listOfCurrentClothes.sorted(by: { $0.headerDate.compare($1.headerDate) == .orderedDescending })
    }
}

struct ClothesTable: Codable {
    var headerDate: Date
    var clothesList: [Clothes]
}

enum ClothesStatus: String, Codable  {
    case inShop = "inShop"
    case sold = "sold"
    case inStore = "inStore"
}


