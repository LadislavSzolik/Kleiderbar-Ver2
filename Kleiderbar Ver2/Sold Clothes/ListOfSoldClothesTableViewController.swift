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
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        
        if let price = soldClothes.price {
           cell.priceLabel.text = "\(String(price)) Fr."
        } else {
            cell.priceLabel.text = "kein Price"
        }
        
        return cell
    }
 

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       
    }
 

}
