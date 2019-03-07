//
//  ViewController.swift
//  Orange Arrow Mobile
//
//  Created by 刘祥 on 3/5/19.
//  Copyright © 2019 xiangliu90. All rights reserved.
//

import UIKit
import BetterSegmentedControl

class RegisterLoginVC: UIViewController {

    @IBOutlet weak var segmentedControl: BetterSegmentedControl!
    @IBOutlet weak var container: UIView!
    var subviews : [UIView]!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        //change the value of segmented control
        segmentedControl.segments = LabelSegment.segments(withTitles: ["Login", "Sign Up"],
                                                          normalFont: UIFont(name: "Avenir", size: 20.0)!,
                                                          normalTextColor:  Utilities.hexStringToUIColor(hex: "FEC341"),
                                                          selectedFont: UIFont(name: "Avenir-Heavy", size: 20.0)!,
                                                          selectedTextColor: .white)
        //initialize login and signup subview
        subviews = [UIView]()
        subviews.append(LoginVC().view)
        subviews.append(SignUpVC().view)
        // add subviews to container
        for v in subviews{
            container.addSubview(v)
            //add subview constraints to be framed inside container
            v.translatesAutoresizingMaskIntoConstraints = false
            v.leftAnchor.constraint(equalTo: container.leftAnchor).isActive = true
            v.topAnchor.constraint(equalTo: container.topAnchor).isActive = true
            v.rightAnchor.constraint(equalTo: container.rightAnchor).isActive = true
            v.bottomAnchor.constraint(equalTo: container.bottomAnchor).isActive = true
        }
        //set login subview as default
        container.bringSubviewToFront(subviews[0])
        
    }
    
    // when the segmented control was selected
    @IBAction func segmentedCtrlChanged(_ sender: BetterSegmentedControl) {
//        self.container.subviews[Int(sender.index)].backgroundColor = Utilities.hexStringToUIColor(hex: "#FEC341")
        self.container.bringSubviewToFront(subviews![Int(sender.index)])
        //change the subview background color
 
    }
    

}

