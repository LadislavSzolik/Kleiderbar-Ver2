//
//  ListOfStoreClothesTableViewController.swift
//  Kleiderbar Ver2
//
//  Created by Ladislav Szolik on 26.11.17.
//  Copyright © 2017 Ladislav Szolik. All rights reserved.
//

import UIKit

class ListOfStoreClothesTableViewController: UITableViewController, StoreClothesCellDelegate {
    
    var listOfStoreClothes = [ClothesTable]()
    var listOfClothesToBeMovedIntoShop = [Clothes]()
    let dateFormatter = DateFormatter()
    var navigationToolbar: UIToolbar?
    
    
    @IBOutlet weak var selectButton: UIBarButtonItem!
    @IBOutlet weak var backButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        tableView.allowsMultipleSelectionDuringEditing = true
        setupToolbar()
        updateNavigationActionButtons()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return listOfStoreClothes.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionHeader = dateFormatter.string(from: listOfStoreClothes[section].headerDate)
        return sectionHeader
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listOfStoreClothes[section].clothesList.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StoreClothesCell", for: indexPath) as! StoreClothesCellTableViewCell

        let clothes = listOfStoreClothes[indexPath.section].clothesList[indexPath.row]
        cell.delegate = self
        cell.clothesCategoryLabel?.text = "\(clothes.id+1). \(clothes.category.name)"
        if let price = clothes.price {
            cell.priceTextField.text = "\(String(price))"
        } else {
            cell.priceTextField.text = ""
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
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
    

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    
    @IBAction func selectButtonTapped(_ sender: UIBarButtonItem) {
        let editing = !tableView.isEditing
        tableView.setEditing(editing, animated: true)
        updateNavigationActionButtons()
    }
    

    // MARK: - Privat Methods    
    func setupToolbar() {
        let items=[
            UIBarButtonItem(title: "Zum Shop", style: UIBarButtonItemStyle.plain, target: self, action: #selector(putClothesToShop(sender:))),
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
      
    }
    
    @objc func putClothesToShop(sender: UIBarButtonItem) {
        var selectedRows = tableView.indexPathsForSelectedRows!
        var count = selectedRows.count-1
        while count >=  0 {
            let indexPath = selectedRows[count]
            let toBeInShopClothes = listOfStoreClothes[indexPath.section].clothesList.remove(at: indexPath.row)
            listOfClothesToBeMovedIntoShop.append(toBeInShopClothes)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            if listOfStoreClothes[indexPath.section].clothesList.count == 0 {
                listOfStoreClothes.remove(at: indexPath.section)
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
            listOfStoreClothes[indexPath.section].clothesList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            if listOfStoreClothes[indexPath.section].clothesList.count == 0 {
                listOfStoreClothes.remove(at: indexPath.section)
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
            
            if listOfStoreClothes.isEmpty {
                selectButton.isEnabled = false
            } else {
                selectButton.isEnabled = true
            }
        }
    }
    
    func didPriceChanged(sender: StoreClothesCellTableViewCell) {        
        if let indexPath = tableView.indexPath(for: sender) {
            var clothes = listOfStoreClothes[indexPath.section].clothesList[indexPath.row]
            
            if let priceText = sender.priceTextField.text {
                clothes.price = Double(priceText)
            }
            listOfStoreClothes[indexPath.section].clothesList[indexPath.row] = clothes
        }
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
