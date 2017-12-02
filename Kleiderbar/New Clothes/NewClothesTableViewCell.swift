//
//  NewClothesTableViewCell.swift
//  Kleiderbar Ver2
//
//  Created by Ladislav Szolik on 25.11.17.
//  Copyright © 2017 Ladislav Szolik. All rights reserved.
//

import UIKit
protocol NewClothesCellDelegate {
    func didClothesStepperChanged(category: ClothesCategory, count: Int)
}

class NewClothesTableViewCell: UITableViewCell {

    @IBOutlet weak var pieceLabel: UILabel!
    @IBOutlet weak var CategoryLabel: UILabel!
    @IBOutlet weak var stepper: UIStepper!
    var category: ClothesCategory!
    var delegate: NewClothesCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        pieceLabel.text = "0 Stk."
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    

    @IBAction func stepperValueChanged(_ sender: Any) {
        pieceLabel.text = "\(Int(stepper.value)) Stk."
        delegate?.didClothesStepperChanged(category: category, count: Int(stepper.value))
    }
}
