//
//  HUDView.swift
//  Orange Arrow Mobile
//
//  Created by 刘祥 on 4/1/19.
//  Copyright © 2019 xiangliu90. All rights reserved.
//

import UIKit

class HUDView: UIView {
    
    var stopwatch: StopwatchView
    
    //this should never be called
    required init(coder aDecoder:NSCoder) {
        fatalError("use init(frame:")
    }
    
    override init(frame:CGRect) {
        self.stopwatch = StopwatchView(frame:CGRect(x:frame.size.width/2-150, y:0, width:300, height:100))
        self.stopwatch.setSeconds(seconds: 0)
        
        super.init(frame:frame)
        self.addSubview(self.stopwatch)
        self.isUserInteractionEnabled = false

    }
}

