//
//  NewClothesTableViewController.swift
//  Kleiderbar Ver2
//
//  Created by Ladislav Szolik on 25.11.17.
//  Copyright © 2017 Ladislav Szolik. All rights reserved.
//

import UIKit

class NewClothesTableViewController: UITableViewController, NewClothesCellDelegate {
   
    var clothesToCreate = [Int:Int]()
    var listOfNewClothes = [Clothes]()

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
        return ClothesCategory.all.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewClothesCell", for: indexPath) as! NewClothesTableViewCell
        let category = ClothesCategory.all[indexPath.row]
        cell.CategoryLabel?.text = "\(category.id) \(category.name)"
        cell.category = category
        cell.delegate = self
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }


    // MARK: - Delegate
    
    func didClothesStepperChanged(category: ClothesCategory, count: Int) {
        if clothesToCreate[category.id] != nil {
            clothesToCreate.updateValue(count, forKey: category.id)
        } else {
            clothesToCreate[category.id]  = count
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "AddNewClothes" else {return}
        
        for newItem in clothesToCreate {
            for _ in  1...newItem.value {
                if let category = ClothesCategory.all.first(where: { (category) -> Bool in
                    return category.id == newItem.key
                }) {
                    let newClothes =  Clothes(id: Clothes.getNextId() , category: category, price: nil, dateOfCreation: Date(), status: .inShop, moneyGivenBack: false )
                    listOfNewClothes.append(newClothes)
                }
            }
        }
    }
    

}
