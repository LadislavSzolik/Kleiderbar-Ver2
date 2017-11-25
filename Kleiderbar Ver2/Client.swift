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
    var listOfShopClothes: [Clothes]
    var listOfSoldClothes: [Clothes]
    
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
