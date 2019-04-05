//
//  StopwatchView.swift
//  Orange Arrow Mobile
//
//  Created by 刘祥 on 4/1/19.
//  Copyright © 2019 xiangliu90. All rights reserved.
//

import UIKit

class StopwatchView: UILabel {
    
//    let FontHUD = UIFont(name:"comic andy", size: 62.0)!
//    let FontHUDBig = UIFont(name:"comic andy", size:120.0)!
    
    //this should never be called
    required init(coder aDecoder:NSCoder) {
        fatalError("use init(frame:")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        self.font = FontHUD

    }
    
    //helper method that implements time formatting
    //to an int parameter (eg the seconds left)
    func setSeconds(seconds:Int) {
        self.text = String(format: " %02i : %02i Left", seconds/60, seconds % 60)
    }
}
