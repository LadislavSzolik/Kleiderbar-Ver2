//
//  ClothesTableViewCell.swift
//  Kleiderbar Ver2
//
//  Created by Ladislav Szolik on 11.11.17.
//  Copyright © 2017 Ladislav Szolik. All rights reserved.
//

import UIKit

protocol ClothesCellDelegate {
    func didPriceChanged(cellIndex: IndexPath, price: Double)
}

class ClothesTableViewCell: UITableViewCell {

    var delegate: ClothesCellDelegate?
    var cellIndex:IndexPath?
    @IBOutlet weak var clothesPriceTextField: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var clothesCategoryLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        addDoneButtonOnNumpad(textField: clothesPriceTextField)
        // Configure the view for the selected state
    }
    
    func addDoneButtonOnNumpad(textField: UITextField) {
        
        let keypadToolbar: UIToolbar = UIToolbar()
        
        // add a done button to the numberpad
        keypadToolbar.items=[
           
            UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: self, action: nil),
             UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: textField, action: #selector(UITextField.resignFirstResponder))
        ]
        keypadToolbar.sizeToFit()
        // add a toolbar with a done button above the number pad
        textField.inputAccessoryView = keypadToolbar
    }

    @IBAction func clothesPriceEdited(_ sender: UITextField) {
        if let priceText = priceTextField.text, let price = Double(priceText), let index = cellIndex {            
            delegate?.didPriceChanged(cellIndex: index, price: price)
        }
    }
}
