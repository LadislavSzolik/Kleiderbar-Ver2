//
//  ListOfClothesTableViewController.swift
//  Kleiderbar Ver2
//
//  Created by Ladislav Szolik on 11.11.17.
//  Copyright © 2017 Ladislav Szolik. All rights reserved.
//

import UIKit

protocol ListOfClothesDelegate {
    func didListOfClothesChanged(newListOfClothes: [Clothes])
}

class ListOfClothesTableViewController: UITableViewController, ClothesCellDelegate {
    
    var currentClothesCategory: ClothesCategory?
    var listOfClothes = [Clothes]()
    var clientName: String?
    var clientId: Int?
    var delegate: ListOfClothesDelegate?
    @IBOutlet weak var printButton: UIBarButtonItem!
    @IBOutlet weak var backButton: UIBarButtonItem!
    
    var navigationToolbar: UIToolbar?
    
    var listOfSoldClothesController: ListOfSoldClothesTableViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
            
        
        tableView.allowsMultipleSelectionDuringEditing = true
        
        setupToolbar()
        updatePrintButton()
    }
    
    func setupToolbar() {
        let items=[
            UIBarButtonItem(title: "Verkaufen", style: UIBarButtonItemStyle.plain, target: self, action: #selector(sellClothes(sender:)))
        ]
        
        items[0].isEnabled = false
        setToolbarItems(items, animated: false)
        
        let navigationController = parent as! UINavigationController
        navigationToolbar = navigationController.toolbar
        
        let tabBarController = navigationController.parent as! UITabBarController
        if let viewControllers = tabBarController.viewControllers {
            listOfSoldClothesController = viewControllers[1] as! ListOfSoldClothesTableViewController
        }
    }
    
    @objc func sellClothes(sender: UIBarButtonItem) {
        
        // construct array with clothes to sell
        var soldClothes = [Clothes]()
        for rowIndex in tableView.indexPathsForSelectedRows! {
            let clothesToSell = listOfClothes[rowIndex.row]
            listOfClothes.remove(at: rowIndex.row)
            soldClothes.append(clothesToSell)
        }
        
        
        tableView.setEditing(false, animated: true)
        if let navigationToolbar = navigationToolbar {
            navigationToolbar.isHidden = true
        }
        tableView.reloadData()
        listOfSoldClothesController?.listOfSoldClothes = soldClothes
        
    }
    
    func updatePrintButton() {
        var isClientEntered: Bool = false
        if let _ = clientId, let _ = clientName {
            isClientEntered = true
        }
        //printButton.isEnabled = listOfClothes.count > 0 &&  isClientEntered ? true : false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 && currentClothesCategory != nil {
            return 2
        } else if section == 0 {
            return 1
        } else {
           return listOfClothes.count
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }

    @IBAction
    func unwindToListOfClothes(segue: UIStoryboardSegue){
        if segue.identifier == "SelectClothesCategory" {
            let selectionController = segue.source as! ListOfCategoriesTableViewController
            if let selectedCategory = selectionController.selectedCategory {
                 currentClothesCategory = selectedCategory
                tableView.reloadData()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if currentClothesCategory != nil {
                if indexPath.row == 0 {                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: "ClothesCategoryCell", for: indexPath)
                    cell.textLabel?.text = "Categories"
                    if let id = currentClothesCategory?.id, let name = currentClothesCategory?.name {
                        cell.detailTextLabel?.text = "\(String(id)) \(name)"
                    }
                    return cell
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "AddClothesCell", for: indexPath)
                    return cell
                }
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ClothesCategoryCell", for: indexPath)
                cell.textLabel?.text = "Categories"
                return cell
            }
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ClothesCell", for: indexPath) as! ClothesTableViewCell
            cell.delegate = self
            cell.cellIndex = indexPath.row
            let clothes = listOfClothes[indexPath.row]
            cell.clothesCategoryLabel?.text = "\(clothes.id+1). \(clothes.category.name)"
            if let price = clothes.price {
                cell.priceTextField.text = "\(String(price))"
            }
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if !tableView.isEditing {
          tableView.deselectRow(at: indexPath, animated: true)
        }
        
        if indexPath.section == 0 && indexPath.row == 1 {
            if let selectedCategory = currentClothesCategory {
                let clothesId = Clothes.getNextId()
                let newClothes = Clothes(id: clothesId, category: selectedCategory, price: nil, dateOfCreation: Date())
                listOfClothes.append(newClothes)
                delegate?.didListOfClothesChanged(newListOfClothes: listOfClothes)
                updatePrintButton()
                tableView.reloadData()
            }
        }
        
        if indexPath.section == 1  {
            if let selectedRows = tableView.indexPathsForSelectedRows {
                if selectedRows.count > 0{
                  
                    toggleSellToolbarButton(isEnabled: true)
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if indexPath.section == 1  {
            if tableView.indexPathsForSelectedRows == nil {
                toggleSellToolbarButton(isEnabled: false)
            }
        }
    }
    
    func toggleSellToolbarButton(isEnabled: Bool) {
        guard let configuredToolbarItems = toolbarItems else {
            fatalError("No toolbar Item added, but tried to access!")
        }
        configuredToolbarItems[0].isEnabled = isEnabled
        
    }
    
    func didPriceChanged(cellIndex: Int, price: Double) {
        listOfClothes[cellIndex].price = price
        delegate?.didListOfClothesChanged(newListOfClothes: listOfClothes)
    }

    func buildPdfContent() -> String {
        guard let clientId = clientId, let clientName = clientName else {return "" }
        
        var pdfContent = ""
        for clothes in listOfClothes {
            let divLabel = generateDivLabel(clientId: clientId, clientName: clientName, clothes: clothes)
            pdfContent = pdfContent + divLabel
        }
        return pdfContent
    }
    
    func generateDivLabel(clientId: Int, clientName: String, clothes: Clothes ) -> String{
        let cothesId = clothes.id
        let clothesCategory = clothes.category.name
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        let clothesCreated = dateFormatter.string(from: clothes.dateOfCreation)
        
        var price = ""
        if let setPrice = clothes.price {
            price = "\(String(setPrice)) CHF"
        }
        return " <div style=\"font-size: 13px;width: 158.7px; height:228.4px; float:left;border:1px solid black;\"><div style=\"margin-top:10px;margin-bottom:4px; margin-left:10px\">Kl. id: "+"\(cothesId)"+"</div><div style=\"margin-bottom:4px;  margin-left:10px\" >Kl. art: "+"\(clothesCategory)"+"</div><div style=\"margin-bottom:4px; margin-left:10px\">Kund id: "+"\(clientId)"+"</div><div style=\"margin-bottom:4px; margin-left:10px\">Kund Name: "+"\(clientName)"+"</div><div style=\"margin-bottom:4px; margin-left:10px\">Datum: "+"\(clothesCreated)"+"</div><div style=\"margin-bottom:8px; margin-left:10px\">Groesse: </div><div style=\"margin-left:10px\">Price: <span style=\"font-size:16px\"><b>"+"\(price)"+"</b></span></div></div>"
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
        //activityController.popoverPresentationController?.sourceView = self
        
        present(activityController, animated: true, completion: nil)
    }
    
    
    
    @IBAction func selectButtonTapped(_ sender: UIBarButtonItem) {
        
        // create a boolean instead of text check
        if sender.title == "Select" {
           tableView.setEditing(true, animated: true)
            sender.title = "Cancel"
            backButton.isEnabled = false
            printButton.isEnabled = false
            if let navigationToolbar = navigationToolbar {
                navigationToolbar.isHidden = false
            }
        } else {
            tableView.setEditing(false, animated: true)
            sender.title = "Select"
            backButton.isEnabled = true
            printButton.isEnabled = true
            if let navigationToolbar = navigationToolbar {
                navigationToolbar.isHidden = true
            }
        }
        
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 0 {
            return false;
        }
        return true
    }
    

    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        /*if indexPath.section == 1 {
                return .delete
        }*/
        return .none
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            if editingStyle == .delete {
                listOfClothes.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       
    }
    

}
