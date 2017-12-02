//
//  StoreClothesCellTableViewCell.swift
//  Kleiderbar Ver2
//
//  Created by Ladislav Szolik on 26.11.17.
//  Copyright © 2017 Ladislav Szolik. All rights reserved.
//

import UIKit

protocol StoreClothesCellDelegate {
    func didPriceChanged(sender: StoreClothesCellTableViewCell)
}

class StoreClothesCellTableViewCell: UITableViewCell {

    @IBOutlet weak var clothesCategoryLabel: UILabel!
    @IBOutlet weak var priceTextField: UITextField!
    
    var delegate : StoreClothesCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addDoneButtonOnNumpad(textField: priceTextField)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func addDoneButtonOnNumpad(textField: UITextField) {        
        let keypadToolbar: UIToolbar = UIToolbar()
        keypadToolbar.items=[
            UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: self, action: nil),
            UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: textField, action: #selector(UITextField.resignFirstResponder))
        ]
        keypadToolbar.sizeToFit()
        textField.inputAccessoryView = keypadToolbar
    }
    
    @IBAction func priceChanged(_ sender: UITextField) {
        delegate?.didPriceChanged(sender: self)
    }
    
}
