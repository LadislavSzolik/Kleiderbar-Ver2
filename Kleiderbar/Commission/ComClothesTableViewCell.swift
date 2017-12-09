//
//  ComClothesTableViewCell.swift
//  Kleiderbar
//
//  Created by Ladislav Szolik on 06.12.17.
//  Copyright © 2017 Ladislav Szolik. All rights reserved.
//

import UIKit

class ComClothesTableViewCell: UITableViewCell {

    @IBOutlet weak var clothesCategoryLabel: UILabel!
    @IBOutlet weak var datumLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
