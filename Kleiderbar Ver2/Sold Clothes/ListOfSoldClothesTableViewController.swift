//
//  ListOfSoldClothesTableViewController.swift
//  Kleiderbar Ver2
//
//  Created by Ladislav Szolik on 16.11.17.
//  Copyright © 2017 Ladislav Szolik. All rights reserved.
//

import UIKit

class ListOfSoldClothesTableViewController: UITableViewController {

    var listOfSoldClothes = [String: [Clothes]]()
    var listOfClothesToBeMovedIntoShop = [Clothes]()
    var listOfToBeStoredClothes = [String: [Clothes]]()
    
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var selectButton: UIBarButtonItem!
    var navigationToolbar: UIToolbar?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.allowsMultipleSelectionDuringEditing = true
        setupToolbar()
        updateNavigationActionButtons()
    }
    
    func setupToolbar() {
        let items=[
            UIBarButtonItem(title: "Zum Shop", style: UIBarButtonItemStyle.plain, target: self, action: #selector(putClothesToShop(sender:))),
            UIBarButtonItem(title: "Zum Lager", style: UIBarButtonItemStyle.plain, target: self, action: #selector(storeClothes(sender:))),
            UIBarButtonItem(title: "Löschen", style: UIBarButtonItemStyle.plain, target: self, action: #selector(deleteClothes(sender:)))
        ]
        setToolbarItems(items, animated: false)
        let navigationController = parent as! UINavigationController
        navigationToolbar = navigationController.toolbar
        toggleToolbarButtons(isEnabled: false)
    }
    
    func toggleToolbarButtons(isEnabled: Bool) {
        guard let configuredToolbarItems = toolbarItems else {
            fatalError("No toolbar Item added, but tried to access!")
        }
        configuredToolbarItems[0].isEnabled = isEnabled
        configuredToolbarItems[1].isEnabled = isEnabled
        configuredToolbarItems[2].isEnabled = isEnabled
    }
    
    @objc func putClothesToShop(sender: UIBarButtonItem) {
        let selectedClothes = getSelectedClothesId()
        
        listOfClothesToBeMovedIntoShop = Clothes.getClothesArrayById(from: listOfSoldClothes, idList: selectedClothes)
        listOfSoldClothes = Clothes.removeFromClothesList(from: listOfSoldClothes, idList: selectedClothes)
        
        tableView.setEditing(false, animated: true)
        tableView.reloadData()
        updateNavigationActionButtons()
    }
    
    @objc func storeClothes(sender: UIBarButtonItem) {
        let selectedClothes = getSelectedClothesId()
        
        listOfToBeStoredClothes = Clothes.createNewClothesList(from: listOfSoldClothes, idList: selectedClothes, to: .inStore)
        listOfSoldClothes = Clothes.removeFromClothesList(from: listOfSoldClothes, idList: selectedClothes)
        
        tableView.setEditing(false, animated: true)
        tableView.reloadData()
        updateNavigationActionButtons()
    }
    
    @objc func deleteClothes(sender: UIBarButtonItem) {
        let selectedClothes = getSelectedClothesId()
        
        listOfSoldClothes = Clothes.removeFromClothesList(from: listOfSoldClothes, idList: selectedClothes)
        
        tableView.setEditing(false, animated: true)
        tableView.reloadData()
        updateNavigationActionButtons()
    }
    
    func getSelectedClothesId() -> [Int] {
        var selectedClothesId = [Int]()
        if let selectedClothesIndex = tableView.indexPathsForSelectedRows {
            for indexPath in selectedClothesIndex {
                let key = Array(listOfSoldClothes.keys)[indexPath.section]
                let clothesId = listOfSoldClothes[key]![indexPath.row].id
                selectedClothesId.append(clothesId)
            }
        }
        return selectedClothesId
    }
    
    func updateNavigationActionButtons() {
        if tableView.isEditing {
            selectButton.title = "Cancel"
            backButton.isEnabled = false
            if let navigationToolbar = navigationToolbar {
                navigationToolbar.isHidden = false
            }
        } else {
            selectButton.title = "Select"
            backButton.isEnabled = true
            if let navigationToolbar = navigationToolbar {
                navigationToolbar.isHidden = true
            }
            
            if listOfSoldClothes.isEmpty {
                selectButton.isEnabled = false
            } else {
                selectButton.isEnabled = true                
            }
        }
    }
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return listOfSoldClothes.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let key = Array(listOfSoldClothes.keys)[section]
        return key
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let key = Array(listOfSoldClothes.keys)[section]
       return listOfSoldClothes[key]!.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let key = Array(listOfSoldClothes.keys)[indexPath.section]
        guard let subListOfClothes = listOfSoldClothes[key] else {fatalError("No Clothes for this section")}
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SoldClothesCell", for: indexPath) as! SoldClothesTableViewCell
        let soldClothes = subListOfClothes[indexPath.row]
        
        cell.clothesCategoryLabel.text = "\(soldClothes.id+1). \(soldClothes.category.name)"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        let creationDateString = dateFormatter.string(from: soldClothes.dateOfCreation)
        cell.creationDateLabel.text = "Hinzugefügt: " + creationDateString
        
        if let price = soldClothes.price {
           cell.priceLabel.text = "\(String(price)) Fr."
        } else {
            cell.priceLabel.text = "kein Price"
        }
        
        return cell
    }
 

    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !tableView.isEditing {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        if let selectedRows = tableView.indexPathsForSelectedRows {
            if selectedRows.count > 0 {
                toggleToolbarButtons(isEnabled: true)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if tableView.indexPathsForSelectedRows == nil {
            toggleToolbarButtons(isEnabled: false)
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let key = Array(listOfSoldClothes.keys)[indexPath.section]
            listOfSoldClothes[key]?.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    

    @IBAction func selectButtonTapped(_ sender: Any) {
        let editing = !tableView.isEditing
        tableView.setEditing(editing, animated: true)
        updateNavigationActionButtons()
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       
    }
 

}
