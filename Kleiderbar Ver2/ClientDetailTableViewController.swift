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
    var listOfClothes: [Clothes]?
    
    @IBOutlet weak var clientNameTextField: UITextField!
    @IBOutlet weak var numberOfClothesLabel: UILabel!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let client = client {
            clientNameTextField.text = client.name
        } else {
            client = Client(id: Client.getNextId(), name: "", listOfClothes: [])
        }
        
        if let listOfClothes = listOfClothes {
            numberOfClothesLabel.text = "\(listOfClothes.count) Stk"
        }
        udateSaveButton();
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "SaveClient" {
            client.listOfClothes = listOfClothes ?? []
            client.name = clientNameTextField.text!
        } else if segue.identifier == "ShowClothes" {
            let clothesListController = segue.destination as! ListOfClothesTableViewController
            clothesListController.delegate = self
            clothesListController.clientId = client.id
            client.name = clientNameTextField.text!
            clothesListController.clientName = client.name
            clothesListController.listOfClothes = listOfClothes ?? []
        }
    }
    
    func didListOfClothesChanged(newListOfClothes: [Clothes]) {
        listOfClothes = newListOfClothes
        numberOfClothesLabel.text = "\(String(describing: listOfClothes!.count)) Stk"
        udateSaveButton()
    }
 
    func udateSaveButton() {
        if let textField = clientNameTextField.text, let _ = listOfClothes {
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
}
