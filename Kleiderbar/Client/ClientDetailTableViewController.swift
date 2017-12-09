//
//  ClientDetailTableViewController.swift
//  Kleiderbar Ver2
//
//  Created by Ladislav Szolik on 11.11.17.
//  Copyright © 2017 Ladislav Szolik. All rights reserved.
//

import UIKit

class ClientDetailTableViewController: UITableViewController, ComClothesDelegate {
    
    
  
    var client: Client!
    
    @IBOutlet weak var clientNameTextField: UITextField!
    @IBOutlet weak var numberOfClothesLabel: UILabel!
    @IBOutlet weak var numberOfSoldClothes: UILabel!
    @IBOutlet weak var numberOfStoreClothes: UILabel!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var payButton: UIButton!
    @IBOutlet weak var totalCommissionAmount: UILabel!
    
    let dateFormatter = DateFormatter()
   
    override func viewDidLoad() {
        super.viewDidLoad()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        
        if let client = client {
            clientNameTextField.text = client.name
        } else {
            Client.globalId = Client.loadLastClientId()
            client = Client(id: Client.getNextId(), name: "", listOfShopClothes: [], listOfSoldClothes: [], listOfStoreClothes: [], listOfCommissions: [], dateOfCreation: Date() )
            Client.saveClientId(Client.globalId)
        }
        updateNumberOfClothesLabels()
        udateSaveButton()
        updateTotalCommission()
        updatePayButton()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
    func updateNumberOfClothesLabels() {
        var shopCount = 0
        for clothesTable in client.listOfShopClothes {
            shopCount = shopCount + clothesTable.clothesList.count
        }
        
        var soldCount = 0
        for clothesTable in client.listOfSoldClothes {
            soldCount = soldCount + clothesTable.clothesList.count
        }
        
        var storeCount = 0
        for clothesTable in client.listOfStoreClothes {
            storeCount = storeCount + clothesTable.clothesList.count
        }
     
        numberOfClothesLabel.text = "\(shopCount) Stk"
        numberOfSoldClothes.text = "\(soldCount) Stk"
        numberOfStoreClothes.text = "\(storeCount) Stk"
    }
    
    func updateTotalCommission() {
        totalCommissionAmount.text = "\(client.totalCommission) Fr."
    }
 
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func udateSaveButton() {
        if let textField = clientNameTextField.text {
            if !textField.isEmpty {
                saveButton.isEnabled = true
            } else {
                saveButton.isEnabled = false
            }
        } else {
            saveButton.isEnabled = false
        }
    }

    @IBAction func clientNameEditingChanged(_ sender: Any) {
        udateSaveButton()
    }
    
    @IBAction func payButtonPressed(_ sender: Any) {
        client.payMoneyBack()
        updateTotalCommission()
        updatePayButton()
    }
    
    
    // MARK: - Unwind Segue
    
    @IBAction
    func unwindToClientDetails( segue: UIStoryboardSegue) {
        if segue.identifier == "SaveShopClothes" {
            let shopClothesController = segue.source as! ListOfClothesTableViewController
            client.listOfShopClothes = shopClothesController.listOfShopClothes
            
            // SELL
            if shopClothesController.listOfToBeSoldClothes.count > 0 {
                client.listOfSoldClothes = appendListOfClothes(target: client.listOfSoldClothes, with: shopClothesController.listOfToBeSoldClothes, for: .sold)
            }
            
            // STORE
            if shopClothesController.listOfToBeStoredClothes.count > 0 {
                client.listOfStoreClothes = appendListOfClothes(target: client.listOfStoreClothes, with: shopClothesController.listOfToBeStoredClothes, for: .inStore)
            }
        } else if segue.identifier == "SaveSoldClothes" {
            let soldClothesController = segue.source as! ListOfSoldClothesTableViewController
            client.listOfSoldClothes = soldClothesController.listOfSoldClothes
            
            // SHOP
            if soldClothesController.listOfClothesToBeMovedIntoShop.count > 0 {
              client.listOfShopClothes = appendListOfClothes(target: client.listOfShopClothes, with: soldClothesController.listOfClothesToBeMovedIntoShop, for: .inShop)
            }
            
            // STORE
            if soldClothesController.listOfToBeStoredClothes.count > 0 {
                client.listOfStoreClothes = appendListOfClothes(target: client.listOfStoreClothes, with: soldClothesController.listOfToBeStoredClothes, for: .inStore)
            }
        } else if segue.identifier == "SaveStoreClothes" {
            
            let storeClothesController = segue.source as! ListOfStoreClothesTableViewController
            client.listOfStoreClothes = storeClothesController.listOfStoreClothes
            
            // SHOP
            if storeClothesController.listOfClothesToBeMovedIntoShop.count > 0 {
                client.listOfShopClothes = appendListOfClothes(target: client.listOfShopClothes, with: storeClothesController.listOfClothesToBeMovedIntoShop, for: .inShop)
            }
        }
        updateNumberOfClothesLabels()
        updateTotalCommission()
        updatePayButton()
    }
    
    func appendListOfClothes(target listOfClothesTables: [ClothesTable], with listOfClothes: [Clothes], for clothesStatus: ClothesStatus ) -> [ClothesTable] {
        var dateToUse = Date()
        switch clothesStatus {
        case .inShop:
            dateToUse = listOfClothes.first!.dateOfCreation
        case .inStore:
            dateToUse = listOfClothes.first!.dateOfStore!
        case .sold:
            dateToUse = listOfClothes.first!.dateOfSell!
        }
                
        var appendedListOfClothesTables = listOfClothesTables
        if appendedListOfClothesTables.count == 0 {
            appendedListOfClothesTables.append( ClothesTable(headerDate: dateToUse, clothesList: listOfClothes))
        } else {
            let storeDateString = dateFormatter.string(from: dateToUse)
            for i in 0...appendedListOfClothesTables.count-1 {
                var clothesTable = appendedListOfClothesTables[i]
                let tableDateString = dateFormatter.string(from: clothesTable.headerDate)
                if tableDateString == storeDateString {
                    clothesTable.clothesList.append(contentsOf: listOfClothes)
                    clothesTable.clothesList.sort(by: <)
                    appendedListOfClothesTables[i] = clothesTable
                    break
                } else {
                    appendedListOfClothesTables.append( ClothesTable(headerDate: dateToUse, clothesList: listOfClothes))
                }
            }
        }
        return appendedListOfClothesTables.sorted(by: { $0.headerDate.compare($1.headerDate) == .orderedDescending })
    }
    
    func didUndoPressed(listOfClothes: [Clothes]) {
        client.undoMoneyBack(listOfOfClothesToRevert: listOfClothes)
        updateTotalCommission()
        updatePayButton()
    }
    
    func updatePayButton() {
        if client.totalCommission > 0 {
            payButton.isEnabled = true
        } else {
            payButton.isEnabled = false
        }
    }
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SaveClient" {
            client.name = clientNameTextField.text!
            
        } else if segue.identifier == "ShowShopClothes" {
            let navigationController = segue.destination as! UINavigationController
            let clothesListController = navigationController.topViewController  as! ListOfClothesTableViewController
            clothesListController.clientId = client.id
            
            /*
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd. MM. yyyy"
            guard let testDate = dateFormatter.date(from: "22. 11. 2017") else {return}
            print("executed")
            let testClothes1 = Clothes(id: 1, category: ClothesCategory.all[0] , price: 22, dateOfCreation: testDate, dateOfSell: nil, dateOfStore: nil, status: .inShop, moneyGivenBack: false)
            let testClothesList = [testClothes1]
            let clothesTable1 = ClothesTable(headerDate: testDate, clothesList: testClothesList)
            client.listOfShopClothes = [clothesTable1] */
                
            clothesListController.listOfShopClothes = client.listOfShopClothes
        } else if segue.identifier == "ShowSoldClothes" {
            let navigationController = segue.destination as! UINavigationController
            let soldClothesController = navigationController.topViewController as! ListOfSoldClothesTableViewController
            soldClothesController.listOfSoldClothes = client.listOfSoldClothes
        } else if segue.identifier == "ShowStoreClothes" {
            let navigationController = segue.destination as! UINavigationController
            let storeClothesController = navigationController.topViewController as! ListOfStoreClothesTableViewController
            storeClothesController.listOfStoreClothes = client.listOfStoreClothes
        } else if segue.identifier == "ShowCommissions" {
            let commissionsController = segue.destination as! CommissionsTableViewController
            commissionsController.clientDetailsController = self
            commissionsController.commissions = client.listOfCommissions
        }
    }
    
}
