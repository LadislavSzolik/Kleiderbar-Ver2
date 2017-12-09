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
    
    var listOfShopClothes = [ClothesTable]()
    var listOfToBeSoldClothes = [Clothes]()
    var listOfToBeStoredClothes = [Clothes]()
    var clientId: Int?
    @IBOutlet weak var printButton: UIBarButtonItem!
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var selectButton: UIBarButtonItem!
    
    var navigationToolbar: UIToolbar?
    let dateFormatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.allowsMultipleSelectionDuringEditing = true
        dateFormatter.dateFormat = "dd. MM. yyyy"
        setupToolbar()
        updateNavigationActionButtons()
    }
    
    func setupToolbar() {
        let items=[
            UIBarButtonItem(title: "Verkaufen", style: UIBarButtonItemStyle.plain, target: self, action: #selector(sellClothes(sender:))),
            UIBarButtonItem(title: "Zum Lager", style: UIBarButtonItemStyle.plain, target: self, action: #selector(storeClothes(sender:))),
            UIBarButtonItem(title: "Löschen", style: UIBarButtonItemStyle.plain, target: self, action: #selector(deleteClothes(sender:)))
        ]
        setToolbarItems(items, animated: false)
        let navigationController = parent as! UINavigationController
        navigationToolbar = navigationController.toolbar
        toggleToolbarButtons(isEnabled: false)
    }
    
    @objc func sellClothes(sender: UIBarButtonItem) {
        var selectedRows = tableView.indexPathsForSelectedRows!
        var count = selectedRows.count-1
        while count >=  0 {
            let indexPath = selectedRows[count]
            var sellingClothes = listOfShopClothes[indexPath.section].clothesList.remove(at: indexPath.row)
            sellingClothes.dateOfSell = Date()
            listOfToBeSoldClothes.append(sellingClothes)
            
            tableView.deleteRows(at: [indexPath], with: .automatic)
            if listOfShopClothes[indexPath.section].clothesList.count == 0 {
                listOfShopClothes.remove(at: indexPath.section)
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
            var storingClothes = listOfShopClothes[indexPath.section].clothesList.remove(at: indexPath.row)
            storingClothes.dateOfStore = Date()
            listOfToBeStoredClothes.append(storingClothes)
            
            tableView.deleteRows(at: [indexPath], with: .automatic)
            if listOfShopClothes[indexPath.section].clothesList.count == 0 {
                listOfShopClothes.remove(at: indexPath.section)
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
            listOfShopClothes[indexPath.section].clothesList.remove(at: indexPath.row)
             tableView.deleteRows(at: [indexPath], with: .automatic)
            if listOfShopClothes[indexPath.section].clothesList.count == 0 {
                listOfShopClothes.remove(at: indexPath.section)
                tableView.deleteSections([indexPath.section], with: .automatic)
            }
            count = count - 1
        }
       
        tableView.setEditing(false, animated: true)
        updateNavigationActionButtons()
    }        
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return listOfShopClothes.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionHeader = dateFormatter.string(from: listOfShopClothes[section].headerDate)
        return sectionHeader
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let clothesTable = listOfShopClothes[section]
        return clothesTable.clothesList.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ClothesCell", for: indexPath) as! ClothesTableViewCell
        cell.delegate = self
        let clothesTableList = listOfShopClothes[indexPath.section].clothesList
        let clothes = clothesTableList[indexPath.row]
        cell.clothesCategoryLabel?.text = "\(clothes.id+1). \(clothes.category.name)"        
        if let price = clothes.price {
            cell.priceTextField.text = "\(String(price))"
        } else {
            cell.priceTextField.text = ""
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
            
            //listOfShopClothes[indexPath.section].clothesList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func toggleToolbarButtons(isEnabled: Bool) {
        guard let configuredToolbarItems = toolbarItems else {
            fatalError("No toolbar Item added, but tried to access!")
        }
        configuredToolbarItems[0].isEnabled = isEnabled
        configuredToolbarItems[1].isEnabled = isEnabled
        configuredToolbarItems[2].isEnabled = isEnabled
    }
    
    func didPriceChanged(sender: ClothesTableViewCell) {
        if let indexPath = tableView.indexPath(for: sender) {
            var clothes = listOfShopClothes[indexPath.section].clothesList[indexPath.row]
            
            if let priceText = sender.priceTextField.text {
                clothes.price = Double(priceText)
            }
            listOfShopClothes[indexPath.section].clothesList[indexPath.row] = clothes
        }
    }

    func buildPdfPages() -> [String] {
        guard let clientId = clientId else {return [] }
        
        var pdfPages = [String]()
        
        var soldCount = 0
        for clothesTable in listOfShopClothes {
            soldCount = soldCount + clothesTable.clothesList.count
        }
        var count = 0
        var pdfContent = ""
        for section in listOfShopClothes {
            for clothes in section.clothesList {
                count = count + 1
                
                if count % 9 == 1 {
                    pdfContent = pdfContent +  "<div style=\"height: 841.8px; padding: 50px; \"> "
                }
                
                let divLabel = generateDivLabel(clientId: clientId, clothes: clothes)
                pdfContent = pdfContent + divLabel
                
                if (count != 0 && count % 9 == 0) || count == soldCount  {
                    pdfContent = pdfContent +  "</div>"
                    pdfPages.append(pdfContent)
                    pdfContent = ""
                }
            }
        }
        return pdfPages
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
        return "<div style=\"font-size: 11px; width: 158.7px; float:left; margin: 5px;\"><div style=\"border:1px solid black;\"><div style=\"margin-top:10px;margin-bottom:4px; margin-left:10px\">Kl. id: "+"\(cothesId)"+"</div>  <div style=\"margin-bottom:4px;  margin-left:10px\" >Kl. art: "+"\(clothesCategory)"+"</div>  <div style=\"margin-bottom:4px; margin-left:10px\">Kund id: "+"\(clientId)"+"</div>  <div style=\"margin-bottom:8px; margin-left:10px\">Datum: "+"\(clothesCreated)"+"</div>  <div style=\"margin-bottom:8px; margin-left:10px\">Groesse: </div><div style=\"margin-left:10px; margin-bottom: 8px;\">Price: <span style=\"font-size:14px;\"><b>"+"\(price)"+"</b></span></div> </div><div style=\" border:1px solid black;\"><div style=\"margin-top:10px;margin-bottom:4px; margin-left:10px\">Kl. id: "+"\(cothesId)"+"</div>  <div style=\"margin-bottom:4px;  margin-left:10px\" >Kl. art: "+"\(clothesCategory)"+"</div>  <div style=\"margin-bottom:4px; margin-left:10px\">Kund id: "+"\(clientId)"+"</div>  <div style=\"margin-bottom:8px; margin-left:10px\">Datum: "+"\(clothesCreated)"+"</div>  <div style=\"margin-bottom:8px; margin-left:10px\">Groesse: </div><div style=\"margin-left:10px;margin-bottom: 8px;\">Price: <span style=\"font-size:14px\"><b>"+"\(price)"+"</b></span></div> </div> </div>"
    }
    
    
    @IBAction func printButtonPressed(_ sender: UIBarButtonItem) {
        let pdfPages = buildPdfPages()
        let render = UIPrintPageRenderer()
        for i in 0..<pdfPages.count {
            let fmt = UIMarkupTextPrintFormatter(markupText: pdfPages[i])
            render.addPrintFormatter(fmt, startingAtPageAt: i)
        }
        
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
            
            if listOfShopClothes.isEmpty {
                selectButton.isEnabled = false
                printButton.isEnabled = false
            } else {
                selectButton.isEnabled = true
                printButton.isEnabled = true
            }
        }
    }
    
    // MARK: - Segue
    
    @IBAction
    func unwindToListOfClothes(segue: UIStoryboardSegue){
        if segue.identifier == "AddNewClothes" {
            let newClothesController = segue.source as! NewClothesTableViewController
            let listOfNewClothes = newClothesController.listOfNewClothes
            
            if listOfNewClothes.count > 0 {
                listOfShopClothes = Clothes.appendClothesList(list: listOfShopClothes, with: listOfNewClothes)
                updateNavigationActionButtons()
                tableView.reloadData()
            }
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       
    }
    

}
