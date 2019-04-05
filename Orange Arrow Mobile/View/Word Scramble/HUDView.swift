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
    var hintButton: UIButton!
    
//    let FontHUD = UIFont(name:"comic andy", size: 62.0)!

    
    //this should never be called
    required init(coder aDecoder:NSCoder) {
        fatalError("use init(frame:")
    }
    
    override init(frame:CGRect) {
        
        //load the button image
        let hintButtonImage = UIImage(named: "btn")!
        
        //the help button
        self.hintButton = UIButton(type: .custom)
        hintButton.setTitle("Hint!", for: .normal)
        hintButton.titleLabel?.font = FontHUD
        hintButton.setBackgroundImage(hintButtonImage, for: .normal)
        hintButton.frame = CGRect(x:0, y:0, width:hintButtonImage.size.width, height:hintButtonImage.size.height)
        hintButton.alpha = 0.8
       
        
        
        
        self.stopwatch = StopwatchView(frame:CGRect(x: hintButton.bounds.size.width+50, y: 0, width: 200, height: hintButton.bounds.size.height))
//        self.stopwatch = StopwatchView(frame:CGRect(x:frame.size.width/2-150, y:0, width:300, height:100))
        self.stopwatch.setSeconds(seconds: 0)
        
        super.init(frame:frame)
        self.addSubview(self.stopwatch)
        self.addSubview(hintButton)
        self.isUserInteractionEnabled = true
        



    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        //1 let touches through and only catch the ones on buttons
        let hitView = super.hitTest(point, with: event)
        
        //2
        if hitView is UIButton {
            return hitView
        }
        
        //3
        return nil
    }


}

