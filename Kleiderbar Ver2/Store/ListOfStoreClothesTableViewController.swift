//
//  ListOfStoreClothesTableViewController.swift
//  Kleiderbar Ver2
//
//  Created by Ladislav Szolik on 26.11.17.
//  Copyright © 2017 Ladislav Szolik. All rights reserved.
//

import UIKit

class ListOfStoreClothesTableViewController: UITableViewController {
    
    var listOfStoreClothes = [String : [Clothes]]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return listOfStoreClothes.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let key = Array(listOfStoreClothes.keys)[section]
        return key
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let key = Array(listOfStoreClothes.keys)[section]
        return listOfStoreClothes[key]!.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let key = Array(listOfStoreClothes.keys)[indexPath.section]
        guard let subListOfClothes = listOfStoreClothes[key] else {fatalError("No Clothes for this section")}
        let cell = tableView.dequeueReusableCell(withIdentifier: "StoreClothesCell", for: indexPath) as! StoreClothesCellTableViewCell
        
       
        let clothes = subListOfClothes[indexPath.row]
        cell.clothesCategoryLabel?.text = "\(clothes.id+1). \(clothes.category.name)"
        if let price = clothes.price {
            cell.priceTextField.text = "\(String(price))"
        } else {
            cell.priceTextField.text = ""
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
