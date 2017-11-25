//
//  ClientDetailTableViewController.swift
//  Kleiderbar Ver2
//
//  Created by Ladislav Szolik on 11.11.17.
//  Copyright © 2017 Ladislav Szolik. All rights reserved.
//

import UIKit

class ClientDetailTableViewController: UITableViewController, ListOfClothesDelegate {
  
    var client: Client!
    var listOfClothes: [String:[Clothes]]?
    var listOfSoldClothes: [String:[Clothes]]?
    
    @IBOutlet weak var clientNameTextField: UITextField!
    @IBOutlet weak var numberOfClothesLabel: UILabel!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let client = client {
            clientNameTextField.text = client.name
        } else {
            client = Client(id: Client.getNextId(), name: "", listOfShopClothes: [:], listOfSoldClothes: [:], dateOfCreation: Date() )
        }
        
        updateNumberOfClothesLabel()
        udateSaveButton();
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "SaveClient" {
            client.listOfShopClothes = listOfClothes ?? [:]
            client.name = clientNameTextField.text!
        } else if segue.identifier == "ShowClothes" {
            let tabBarController = segue.destination as! UITabBarController
            
            if let viewControllers = tabBarController.viewControllers {
                if let fistController = viewControllers.first  {
                    let navigationController = fistController as! UINavigationController
                    let clothesListController = navigationController.topViewController  as! ListOfClothesTableViewController
                    clothesListController.delegate = self
                    clothesListController.clientId = client.id
                    client.name = clientNameTextField.text!
                    clothesListController.listOfClothes = listOfClothes ?? [:]
                }
                
                let secondController = viewControllers[1]
                let soldClothesController = secondController as! ListOfSoldClothesTableViewController
                soldClothesController.listOfSoldClothes = listOfSoldClothes ?? [:]
            }                       
        }
    }
    
    func didListOfClothesChanged(newListOfClothes: [String : [Clothes]]) {
        listOfClothes = newListOfClothes
        updateNumberOfClothesLabel()
        udateSaveButton()
    }
    
    func updateNumberOfClothesLabel() {
        var shopClothesCount = 0
        if let listOfClothes = listOfClothes {
            for clothes in listOfClothes {
                shopClothesCount = shopClothesCount + clothes.value.count
            }
        }
        numberOfClothesLabel.text = "\(shopClothesCount) Stk"
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
        
    }
}
