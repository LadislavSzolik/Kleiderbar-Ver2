//
//  ListOfClothesTableViewController.swift
//  Kleiderbar Ver2
//
//  Created by Ladislav Szolik on 11.11.17.
//  Copyright © 2017 Ladislav Szolik. All rights reserved.
//

import UIKit
/*
protocol ListOfClothesDelegate {
    func didListOfClothesChanged(newListOfClothes: [String:[Clothes]])
*/

class ListOfClothesTableViewController: UITableViewController, ClothesCellDelegate {
    
    var listOfShopClothes = [String: [Clothes]]()
    var listOfToBeSoldClothes = [String: [Clothes]]()
    var listOfToBeStoredClothes = [String: [Clothes]]()
    var clientId: Int?
    @IBOutlet weak var printButton: UIBarButtonItem!
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var addButton: UIBarButtonItem!
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
            UIBarButtonItem(title: "Verkaufen", style: UIBarButtonItemStyle.plain, target: self, action: #selector(sellClothes(sender:))),
            UIBarButtonItem(title: "Zum Lager", style: UIBarButtonItemStyle.plain, target: self, action: #selector(storeClothes(sender:)))
        ]
        setToolbarItems(items, animated: false)
        let navigationController = parent as! UINavigationController
        navigationToolbar = navigationController.toolbar
        toggleToolbarButtons(isEnabled: false)
    }
    
    @objc func sellClothes(sender: UIBarButtonItem) {
        let selectedClothes = getSelectedClothesId()
        
        listOfToBeSoldClothes = Client.getClothesListBasedOnIds(from: listOfShopClothes, idList: selectedClothes)
        listOfShopClothes = Client.removeFromClothesList(from: listOfShopClothes, idList: selectedClothes)
        
        tableView.setEditing(false, animated: true)
        tableView.reloadData()
        updateNavigationActionButtons()
    }
    
     @objc func storeClothes(sender: UIBarButtonItem) {
        let selectedClothes = getSelectedClothesId()
        
        listOfToBeStoredClothes = Client.getClothesListBasedOnIds(from: listOfShopClothes, idList: selectedClothes)
        listOfShopClothes = Client.removeFromClothesList(from: listOfShopClothes, idList: selectedClothes)
        
        tableView.setEditing(false, animated: true)
        tableView.reloadData()
        updateNavigationActionButtons()
    }
    
    func getSelectedClothesId() -> [Int] {
        var selectedClothesId = [Int]()
        if let selectedClothesIndex = tableView.indexPathsForSelectedRows {
            for indexPath in selectedClothesIndex {
                let key = Array(listOfShopClothes.keys)[indexPath.section]
                let clothesId = listOfShopClothes[key]![indexPath.row].id
                selectedClothesId.append(clothesId)
            }
        }
        return selectedClothesId
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return listOfShopClothes.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let key = Array(listOfShopClothes.keys)[section]
        return key
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let key = Array(listOfShopClothes.keys)[section]
        return listOfShopClothes[key]!.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let key = Array(listOfShopClothes.keys)[indexPath.section]
        guard let subListOfClothes = listOfShopClothes[key] else {fatalError("No Clothes for this section")}
        let cell = tableView.dequeueReusableCell(withIdentifier: "ClothesCell", for: indexPath) as! ClothesTableViewCell
        cell.delegate = self
        cell.cellIndex = indexPath
        let clothes = subListOfClothes[indexPath.row]
        cell.clothesCategoryLabel?.text = "\(clothes.id+1). \(clothes.category.name)"
        if let price = clothes.price {
            cell.priceTextField.text = "\(String(price))"
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
            let key = Array(listOfShopClothes.keys)[indexPath.section]
            listOfShopClothes[key]?.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func toggleToolbarButtons(isEnabled: Bool) {
        guard let configuredToolbarItems = toolbarItems else {
            fatalError("No toolbar Item added, but tried to access!")
        }
        configuredToolbarItems[0].isEnabled = isEnabled
        configuredToolbarItems[1].isEnabled = isEnabled
    }
    
    func didPriceChanged(cellIndex: IndexPath, price: Double) {
        let key = Array(listOfShopClothes.keys)[cellIndex.section]
        listOfShopClothes[key]![cellIndex.row].price = price
    }

    func buildPdfContent() -> String {
        guard let clientId = clientId else {return "" }
        var pdfContent = ""
        for section in listOfShopClothes {
            for clothes in section.value {
                let divLabel = generateDivLabel(clientId: clientId, clothes: clothes)
                pdfContent = pdfContent + divLabel
            }
        }
        return pdfContent
    }
    
    func generateDivLabel(clientId: Int, clothes: Clothes ) -> String{
        let cothesId = clothes.id
        let clothesCategory = clothes.category.name
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        let clothesCreated = dateFormatter.string(from: clothes.dateOfCreation)
        
        var price = ""
        if let setPrice = clothes.price {
            price = "\(String(setPrice)) Fr."
        }
        return " <div style=\"font-size: 13px;width: 158.7px; height:228.4px; float:left;border:1px solid black;\"><div style=\"margin-top:10px;margin-bottom:4px; margin-left:10px\">Kl. id: "+"\(cothesId)"+"</div><div style=\"margin-bottom:4px;  margin-left:10px\" >Kl. art: "+"\(clothesCategory)"+"</div><div style=\"margin-bottom:4px; margin-left:10px\">Kund id: "+"\(clientId)"+"</div><div style=\"margin-bottom:4px; margin-left:10px\">Datum: "+"\(clothesCreated)"+"</div><div style=\"margin-bottom:8px; margin-left:10px\">Groesse: </div><div style=\"margin-left:10px\">Price: <span style=\"font-size:16px\"><b>"+"\(price)"+"</b></span></div></div>"
    }
    
    
    @IBAction func printButtonPressed(_ sender: UIBarButtonItem) {
        
        let pdfContent = buildPdfContent()
        
        let fmt = UIMarkupTextPrintFormatter(markupText: pdfContent)
        
        
        let render = UIPrintPageRenderer()
        render.addPrintFormatter(fmt, startingAtPageAt: 0)
        
        let page = CGRect(x: 0, y: 0, width: 595.2, height: 841.8) // A4, 72 dpi
        render.setValue(page, forKey: "paperRect")
        render.setValue(page, forKey: "printableRect")
        
        let pdfData = NSMutableData()
        
        UIGraphicsBeginPDFContextToData(pdfData, .zero, nil)
        
        for i in 0..<render.numberOfPages {
            UIGraphicsBeginPDFPage();
            render.drawPage(at: i, in: UIGraphicsGetPDFContextBounds())
        }
        
        UIGraphicsEndPDFContext()
        
        guard let outputURL = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("Kleiderbar").appendingPathExtension("pdf")
            else { fatalError("Destination URL not created") }
        
        try? pdfData.write(to: outputURL, options: .atomic)
        
        let activityController = UIActivityViewController(activityItems: [outputURL], applicationActivities: nil)
        
        present(activityController, animated: true, completion: nil)
    }
    
    
    
    @IBAction func selectButtonTapped(_ sender: UIBarButtonItem) {
        let editing = !tableView.isEditing
        tableView.setEditing(editing, animated: true)
        updateNavigationActionButtons()
    }
    

    // MARK: Private Functions
    
    func updateNavigationActionButtons() {
        if tableView.isEditing {
            selectButton.title = "Cancel"
            backButton.isEnabled = false
            printButton.isEnabled = false
            addButton.isEnabled = false
            if let navigationToolbar = navigationToolbar {
                navigationToolbar.isHidden = false
            }
        } else {
            selectButton.title = "Select"
            backButton.isEnabled = true
            printButton.isEnabled = true
            addButton.isEnabled = true
            if let navigationToolbar = navigationToolbar {
                navigationToolbar.isHidden = true
            }
        }
        
        if listOfShopClothes.isEmpty {
            selectButton.isEnabled = false
            printButton.isEnabled = false
        } else {
            selectButton.isEnabled = true
            printButton.isEnabled = true
        }
    }
    
    // MARK: - Segue
    
    @IBAction
    func unwindToListOfClothes(segue: UIStoryboardSegue){
        if segue.identifier == "AddNewClothes" {
            let newClothesController = segue.source as! NewClothesTableViewController
            let listOfNewClothes = newClothesController.listOfNewClothes
            if listOfNewClothes.count > 0 {
                let creationDate = listOfNewClothes.first!.dateOfCreation
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .medium
                let creationDateString = dateFormatter.string(from: creationDate)
               
                var listOfNewClothesDictionary = [String: [Clothes]]()
                listOfNewClothesDictionary[creationDateString] = listOfNewClothes
                
                listOfShopClothes = Client.appendClothesList(list: listOfShopClothes, with: listOfNewClothesDictionary)
                
                updateNavigationActionButtons()
                tableView.reloadData()
            }
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       
    }
    

}
