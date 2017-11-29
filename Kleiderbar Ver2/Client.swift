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
