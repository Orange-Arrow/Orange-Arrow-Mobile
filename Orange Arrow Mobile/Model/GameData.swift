//
//  GameData.swift
//  Orange Arrow Mobile
//
//  Created by 刘祥 on 4/1/19.
//  Copyright © 2019 xiangliu90. All rights reserved.
//

import Foundation

class GameData {
    //store the user's game achievement
    var accuracy = 0.0
    var time = 0
    var points:Int = 0 {
        didSet {
            //custom setter - keep the score positive
            points = max(points, 0)
        }
    }
}
