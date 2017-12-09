//
//  Client.swift
//  Kleiderbar Ver2
//
//  Created by Ladislav Szolik on 11.11.17.
//  Copyright © 2017 Ladislav Szolik. All rights reserved.
//

import Foundation

struct Commission : Codable {
    var total: Double {
        return listOfClothes.reduce(0, { (currentTotal, newValue) -> Double in
            return currentTotal + newValue.price!
        })
    }
    var listOfClothes: [Clothes]
    var dateOfCommission: Date
    
    func isClothesInCommission(id: Int) -> Bool {
        return listOfClothes.contains(where: { (clothes) -> Bool in
            return clothes.id == id
        })
    }
}

struct Client : Codable {
    var id: Int
    var name: String   
    var listOfShopClothes: [ClothesTable]
    var listOfSoldClothes: [ClothesTable]
    var listOfStoreClothes: [ClothesTable]
    var listOfCommissions: [Commission]
    var dateOfCreation: Date
    var totalNumberOfClothes: Int {
        var count = 0
        for clothesTable in listOfShopClothes {
            count = count + clothesTable.clothesList.count
        }
        
        for clothesTable in listOfSoldClothes {
            count = count + clothesTable.clothesList.count
        }
        
        for clothesTable in listOfStoreClothes {
            count = count + clothesTable.clothesList.count
        }
        return count
    }
    
    var totalCommission: Double {
        return sumOfSoldButNotPayedBack * 0.4
    }
    
    var sumOfSoldButNotPayedBack: Double {
        return listOfSoldClothes.reduce(0, {$0 + $1.commissions})
    }
    
    mutating func setMoneyBack() {
        listOfSoldClothes = listOfSoldClothes.map({ (clothesTable) -> ClothesTable in
            var item = clothesTable
            item.setMoneyBack()
            return item
        })
    }
    
    mutating func payMoneyBack() {
        let listOfNewlyPayedbackClothes = listOfSoldClothes.reduce([Clothes](), { (currentList, clothesTable) -> [Clothes] in
            var list = currentList
            list.append(contentsOf: clothesTable.getClothesForMoneyBack())
            return list
        })
        let commission = Commission(listOfClothes: listOfNewlyPayedbackClothes, dateOfCommission: Date())
        listOfCommissions.append(commission)
        
        setMoneyBack()
    }
    
    mutating func undoMoneyBack(listOfOfClothesToRevert: [Clothes]) {
        for i in 0...listOfSoldClothes.count - 1 {
            let clothesTable = listOfSoldClothes[i]
            let newClothetList = clothesTable.clothesList.map({ (clothes) -> Clothes in
                var item = clothes
                if listOfOfClothesToRevert.contains(where: { (clothes) -> Bool in
                    return clothes.id == item.id
                }) {
                    item.moneyGivenBack = false
                }
                return item
            })
            listOfSoldClothes[i].clothesList = newClothetList
        }
        let clothesId = listOfOfClothesToRevert.first!.id
        listOfCommissions = listOfCommissions.filter { !$0.isClothesInCommission(id: clothesId)}
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
        return clientList
    }
    
    
    static let ArchiveURLForClientId = DocumentsDirectory.appendingPathComponent("clientsId")
    
    static func saveClientId(_ clientId: Int) {
        let id =  UniqueClientId(id: clientId)
        let propertyListEncoder = PropertyListEncoder()
        let codedId = try? propertyListEncoder.encode(id)
        try? codedId?.write(to: ArchiveURLForClientId, options: .noFileProtection)
    }
    
    static func loadLastClientId() -> Int {
        guard let codedId = try? Data(contentsOf: ArchiveURLForClientId) else {return 0}
        let propertyListDecoder = PropertyListDecoder()
        if let clientId = try? propertyListDecoder.decode(UniqueClientId.self, from: codedId) {
            return clientId.id
        } else {
            return 0
        }
    }
    
}

struct UniqueClientId: Codable {
    var id: Int
}


