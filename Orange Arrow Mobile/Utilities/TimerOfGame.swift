//
//  Timer.swift
//  Orange Arrow Mobile
//
//  Created by 刘祥 on 3/28/19.
//  Copyright © 2019 xiangliu90. All rights reserved.
//

import Foundation

class TimerOfGame {
    
    var countdownTimer : Timer!
    
    func startTimer(handler:AnyObject, selector:Selector) {
        self.countdownTimer = Timer.scheduledTimer(timeInterval: 1, target: handler, selector: selector, userInfo: nil, repeats: true)
    }
    
    func endTimer() {
        self.countdownTimer.invalidate()
    }
    
}
