//
//  StoreClothesCellTableViewCell.swift
//  Kleiderbar Ver2
//
//  Created by Ladislav Szolik on 26.11.17.
//  Copyright © 2017 Ladislav Szolik. All rights reserved.
//

import UIKit

class StoreClothesCellTableViewCell: UITableViewCell {

    @IBOutlet weak var clothesCategoryLabel: UILabel!
    @IBOutlet weak var priceTextField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
