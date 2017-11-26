//
//  Client.swift
//  Kleiderbar Ver2
//
//  Created by Ladislav Szolik on 11.11.17.
//  Copyright © 2017 Ladislav Szolik. All rights reserved.
//

import Foundation


struct Client : Codable {
    var id: Int
    var name: String   
    var listOfShopClothes: [String: [Clothes]]
    var listOfSoldClothes: [String: [Clothes]]
    var listOfStoreClothes: [String: [Clothes]]
    var dateOfCreation: Date
    var totalNumberOfClothes: Int {
        var count = 0
        for keys in listOfShopClothes {
            count = count + keys.value.count
        }
        
        for keys in listOfSoldClothes {
            count = count + keys.value.count
        }
        
        for keys in listOfStoreClothes {
            count = count + keys.value.count
        }
        return count
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
    
    static var globalId = 0
    static func getNextId() -> Int {
        let currentId = Client.globalId
        Client.globalId = Client.globalId + 1
        return  currentId
    }
    
    static let DocumentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("clients").appendingPathExtension("plist")
    
    static func saveClients(_ clientList: [Client]) {
        let propertyListEncoder = PropertyListEncoder()
        let codedClients = try? propertyListEncoder.encode(clientList)
        try? codedClients?.write(to: ArchiveURL, options: .noFileProtection)
    }
    
    static func loadClients() -> [Client]? {
        guard let codedClients = try? Data(contentsOf: ArchiveURL) else {return nil}
        let propertyListDecoder = PropertyListDecoder()
        let clientList = try? propertyListDecoder.decode(Array<Client>.self, from: codedClients)
        if let lastClient = clientList?.last {
            Client.globalId = lastClient.id
        }
        
        return clientList
    }
    
}
