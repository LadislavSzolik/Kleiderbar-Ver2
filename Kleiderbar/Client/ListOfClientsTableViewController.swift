//
//  ListOfClientsTableViewController.swift
//  Kleiderbar Ver2
//
//  Created by Ladislav Szolik on 11.11.17.
//  Copyright © 2017 Ladislav Szolik. All rights reserved.
//

import UIKit

class ListOfClientsTableViewController: UITableViewController {

    let dateFormatter = DateFormatter()
    var listOfClients = [Client] ()
    
    override func viewDidLoad() {
        super.viewDidLoad()
         dateFormatter.dateFormat = "dd.MM.yyyy"
        if let storedClients = Client.loadClients() {
            listOfClients = storedClients
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listOfClients.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ClientCell", for: indexPath)
        let client = listOfClients[indexPath.row]
        cell.textLabel?.text = "\(client.id). \(client.name)"
        let dateOfCreation = dateFormatter.string(from: client.dateOfCreation)
        cell.detailTextLabel?.text = "Datum: \(dateOfCreation), Kleider:  \(client.totalNumberOfClothes)"
        return cell
    }
    
    

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            listOfClients.remove(at: indexPath.row)
            Client.saveClients(listOfClients)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    @IBAction
    func unwindToListOfClients(segue:UIStoryboardSegue) {
        if segue.identifier == "SaveClient" {
            let clientDetail = segue.source as! ClientDetailTableViewController
            if let client = clientDetail.client {
                if let selectedIndex = tableView.indexPathForSelectedRow {
                    listOfClients[selectedIndex.row] = client
                } else {
                    listOfClients.append(client)
                }
            }
        }
        Client.saveClients(listOfClients)
        tableView.reloadData()
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowClientDetail" {
            if let selectedRow = tableView.indexPathForSelectedRow {
                let client = listOfClients[selectedRow.row]
                let navigationController = segue.destination as! UINavigationController
                let clientController = navigationController.topViewController as! ClientDetailTableViewController
                clientController.client = client                
            }
        }
    }
 

}
