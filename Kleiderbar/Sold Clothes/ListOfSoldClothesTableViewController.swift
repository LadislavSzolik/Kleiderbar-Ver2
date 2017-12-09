//
//  ListOfSoldClothesTableViewController.swift
//  Kleiderbar Ver2
//
//  Created by Ladislav Szolik on 16.11.17.
//  Copyright © 2017 Ladislav Szolik. All rights reserved.
//

import UIKit

class ListOfSoldClothesTableViewController: UITableViewController {

    var listOfSoldClothes = [ClothesTable]()
    var listOfClothesToBeMovedIntoShop = [Clothes]()
    var listOfToBeStoredClothes = [Clothes]()
    
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var selectButton: UIBarButtonItem!
    var navigationToolbar: UIToolbar?
    let dateFormatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dateFormatter.dateFormat = "dd. MM. yyyy"
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
        var selectedRows = tableView.indexPathsForSelectedRows!
        var count = selectedRows.count-1
        while count >=  0 {
            let indexPath = selectedRows[count]
            let toBeInShopClothes = listOfSoldClothes[indexPath.section].clothesList.remove(at: indexPath.row)
            listOfClothesToBeMovedIntoShop.append(toBeInShopClothes)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            if listOfSoldClothes[indexPath.section].clothesList.count == 0 {
                listOfSoldClothes.remove(at: indexPath.section)
                tableView.deleteSections([indexPath.section], with: .automatic)
            }
            count = count - 1
        }
        
        tableView.setEditing(false, animated: true)
        updateNavigationActionButtons()
    }
    
    @objc func storeClothes(sender: UIBarButtonItem) {
        var selectedRows = tableView.indexPathsForSelectedRows!
        var count = selectedRows.count-1
        while count >=  0 {
            let indexPath = selectedRows[count]
            var toBeStoredClothes = listOfSoldClothes[indexPath.section].clothesList.remove(at: indexPath.row)
            toBeStoredClothes.dateOfStore = Date()
            listOfToBeStoredClothes.append(toBeStoredClothes)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            if listOfSoldClothes[indexPath.section].clothesList.count == 0 {
                listOfSoldClothes.remove(at: indexPath.section)
                tableView.deleteSections([indexPath.section], with: .automatic)
            }
            count = count - 1
        }
        
        tableView.setEditing(false, animated: true)
        updateNavigationActionButtons()
    }
    
    @objc func deleteClothes(sender: UIBarButtonItem) {
        var selectedRows = tableView.indexPathsForSelectedRows!
        var count = selectedRows.count-1
        while count >=  0 {
            let indexPath = selectedRows[count]
            listOfSoldClothes[indexPath.section].clothesList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            if listOfSoldClothes[indexPath.section].clothesList.count == 0 {
                listOfSoldClothes.remove(at: indexPath.section)
                tableView.deleteSections([indexPath.section], with: .automatic)
            }
            count = count - 1
        }
        tableView.setEditing(false, animated: true)
        updateNavigationActionButtons()
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
        let sectionHeader = dateFormatter.string(from: listOfSoldClothes[section].headerDate)
        return sectionHeader
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return listOfSoldClothes[section].clothesList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SoldClothesCell", for: indexPath) as! SoldClothesTableViewCell
        let soldClothes = listOfSoldClothes[indexPath.section].clothesList[indexPath.row]
        cell.clothesCategoryLabel.text = "\(soldClothes.id+1). \(soldClothes.category.name)"
        let creationDateString = dateFormatter.string(from: soldClothes.dateOfCreation)
        cell.creationDateLabel.text = "Hinzugefügt: " + creationDateString
        if let price = soldClothes.price {
           cell.priceLabel.text = "\(String(price)) Fr."
        } else {
            cell.priceLabel.text = "kein Price"
        }
        if soldClothes.moneyGivenBack {
            cell.moneyGivenBack!.isHidden = false
        } else {
            cell.moneyGivenBack!.isHidden = true
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
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 54
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            listOfSoldClothes[indexPath.section].clothesList.remove(at: indexPath.row)
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
