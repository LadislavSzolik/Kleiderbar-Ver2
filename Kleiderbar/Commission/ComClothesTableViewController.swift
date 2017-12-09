//
//  ComClothesTableViewController.swift
//  Kleiderbar
//
//  Created by Ladislav Szolik on 06.12.17.
//  Copyright © 2017 Ladislav Szolik. All rights reserved.
//

import UIKit

protocol ComClothesDelegate {
    func didUndoPressed(listOfClothes: [Clothes])
}

class ComClothesTableViewController: UITableViewController {
    
    var listOfClothes = [Clothes]()
    var delegate: ComClothesDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listOfClothes.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ComClothesCell", for: indexPath) as! ComClothesTableViewCell
        let clothes = listOfClothes[indexPath.row]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        let sellDate = dateFormatter.string(from: clothes.dateOfSell!)
        cell.clothesCategoryLabel!.text = clothes.category.name
        cell.datumLabel!.text = "Verkauf: \(sellDate)"
        
        if let price = clothes.price {
            cell.priceLabel!.text = "\(price) Fr."
        } else {
            cell.priceLabel!.text = "Keine Price"
        }
        
        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

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

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "UndoCommission" {           
            delegate?.didUndoPressed(listOfClothes: listOfClothes)
        }
    }
    

}
