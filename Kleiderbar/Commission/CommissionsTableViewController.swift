//
//  CommissionsTableViewController.swift
//  Kleiderbar
//
//  Created by Ladislav Szolik on 06.12.17.
//  Copyright © 2017 Ladislav Szolik. All rights reserved.
//

import UIKit



class CommissionsTableViewController: UITableViewController {
    
    var commissions = [Commission]()
    var clientDetailsController: ClientDetailTableViewController?

    override func viewDidLoad() {
        super.viewDidLoad()

        /*
        let clothes1 = Clothes(id: 1, category: ClothesCategory.all[0] , price: 2, dateOfCreation: Date(), dateOfSell: Date(), dateOfStore: nil, status: .sold, moneyGivenBack: true)
        let clothes2 = Clothes(id: 2, category: ClothesCategory.all[0] , price: 3, dateOfCreation: Date(), dateOfSell: Date(), dateOfStore: nil, status: .sold, moneyGivenBack: true)
        let clothes3 = Clothes(id: 3, category: ClothesCategory.all[0] , price: 4, dateOfCreation: Date(), dateOfSell: Date(), dateOfStore: nil, status: .sold, moneyGivenBack: true)
        let clothes4 = Clothes(id: 4, category: ClothesCategory.all[0] , price: 1, dateOfCreation: Date(), dateOfSell: Date(), dateOfStore: nil, status: .sold, moneyGivenBack: true)
        let com1 = Commission( listOfClothes: [clothes1, clothes2, clothes3, clothes4], dateOfCommission: Date())
        let com2 = Commission( listOfClothes: [clothes1, clothes2, clothes3, clothes4], dateOfCommission: Date())
        let com3 = Commission( listOfClothes: [clothes1, clothes2, clothes3, clothes4], dateOfCommission: Date())
        commissions = [com1, com2, com3] */
                
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commissions.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommissionCell", for: indexPath) as! CommissionTableViewCell
        let commission = commissions[indexPath.row]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        
        let date = dateFormatter.string(from: commission.dateOfCommission)
        
        cell.totalLabel!.text = "\(commission.total) Fr."
        cell.datumLabel!.text = date
        cell.clothesCountLabel!.text = "\(commission.listOfClothes.count) Stk."
       
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
    
    // MARK: - Segue
    @IBAction
    func unwindToCommissions(segue: UIStoryboardSegue) {
        if segue.identifier == "UndoCommission" {
            if let selectedRow = tableView.indexPathForSelectedRow {
                commissions.remove(at: selectedRow.row)
                tableView.deleteRows(at: [selectedRow], with: .automatic)
            }
        }
    }


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowCommission" {
            guard let selectedRow = tableView.indexPathForSelectedRow else {return}
            //let navigation = segue.destination as! UINavigationController
            let comClothesController = segue.destination as! ComClothesTableViewController
            comClothesController.delegate = clientDetailsController
            comClothesController.listOfClothes = commissions[selectedRow.row].listOfClothes
        }
    }

}
