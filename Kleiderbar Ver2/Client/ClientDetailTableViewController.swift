//
//  ClientDetailTableViewController.swift
//  Kleiderbar Ver2
//
//  Created by Ladislav Szolik on 11.11.17.
//  Copyright © 2017 Ladislav Szolik. All rights reserved.
//

import UIKit

class ClientDetailTableViewController: UITableViewController {
  
    var client: Client!
    
    @IBOutlet weak var clientNameTextField: UITextField!
    @IBOutlet weak var numberOfClothesLabel: UILabel!
    @IBOutlet weak var numberOfSoldClothes: UILabel!
    @IBOutlet weak var numberOfStoreClothes: UILabel!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let client = client {
            clientNameTextField.text = client.name
        } else {
            client = Client(id: Client.getNextId(), name: "", listOfShopClothes: [:], listOfSoldClothes: [:], listOfStoreClothes: [:], dateOfCreation: Date() )
        }
        updateNumberOfClothesLabels()
        udateSaveButton();
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
    func updateNumberOfClothesLabels() {
        var shopCount = 0
        for keys in client.listOfShopClothes {
            shopCount = shopCount + keys.value.count
        }
        
        var soldCount = 0
        for keys in client.listOfSoldClothes {
            soldCount = soldCount + keys.value.count
        }
        
        var storeCount = 0
        for keys in client.listOfStoreClothes {
            storeCount = storeCount + keys.value.count
        }
     
        numberOfClothesLabel.text = "\(shopCount) Stk"
        numberOfSoldClothes.text = "\(soldCount) Stk"
        numberOfStoreClothes.text = "\(storeCount) Stk"
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
    
    // MARK: - Unwind Segue
    
    @IBAction
    func unwindToClientDetails( segue: UIStoryboardSegue) {
        if segue.identifier == "SaveShopClothes" {
            let shopClothesController = segue.source as! ListOfClothesTableViewController
            client.listOfShopClothes = shopClothesController.listOfShopClothes
            
            // SELL
            if shopClothesController.listOfToBeSoldClothes.count > 0 {
                client.listOfSoldClothes = Client.appendClothesList(list: client.listOfSoldClothes, with: shopClothesController.listOfToBeSoldClothes)
            }
            
            // STORE
            if shopClothesController.listOfToBeStoredClothes.count > 0 {
                client.listOfStoreClothes = Client.appendClothesList(list: client.listOfStoreClothes, with: shopClothesController.listOfToBeStoredClothes)
            }
        }
        updateNumberOfClothesLabels()
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SaveClient" {
            client.name = clientNameTextField.text!
        } else if segue.identifier == "ShowShopClothes" {
            let navigationController = segue.destination as! UINavigationController
            let clothesListController = navigationController.topViewController  as! ListOfClothesTableViewController
            clothesListController.clientId = client.id
            clothesListController.listOfShopClothes = client.listOfShopClothes
            
        } else if segue.identifier == "ShowSoldClothes" {
            let navigationController = segue.destination as! UINavigationController
            let soldClothesController = navigationController.topViewController as! ListOfSoldClothesTableViewController
            soldClothesController.listOfSoldClothes = client.listOfSoldClothes
        } else if segue.identifier == "ShowStoreClothes" {
            let navigationController = segue.destination as! UINavigationController
            let storeClothesController = navigationController.topViewController as! ListOfStoreClothesTableViewController
            storeClothesController.listOfStoreClothes = client.listOfStoreClothes
        }
    }
    
}
