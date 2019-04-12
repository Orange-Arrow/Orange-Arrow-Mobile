//
//  RankingTableViewCell.swift
//  Orange Arrow Mobile
//
//  Created by 刘祥 on 4/11/19.
//  Copyright © 2019 xiangliu90. All rights reserved.
//

import UIKit

class RankingTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var rankNum: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var originalBarView: UIView!
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    @IBOutlet weak var progressBarView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
