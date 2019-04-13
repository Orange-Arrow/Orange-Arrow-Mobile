//
//  CategoryTableViewCell.swift
//  Orange Arrow Mobile
//
//  Created by 刘祥 on 4/12/19.
//  Copyright © 2019 xiangliu90. All rights reserved.
//

import UIKit

class CategoryTableViewCell: UITableViewCell {
    
    @IBOutlet weak var gameNameImage: UIImageView!
    @IBOutlet weak var rankingLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
