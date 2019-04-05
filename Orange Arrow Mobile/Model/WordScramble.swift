//
//  WordScramble.swift
//  Orange Arrow Mobile
//
//  Created by 刘祥 on 3/6/19.
//  Copyright © 2019 xiangliu90. All rights reserved.
//

import Foundation

struct ListOfWordScramble{
    let list : [NSDictionary]
    
    init(levelNumber: Int){
        // find .plist file for this level
        let stringPath = Bundle.main.path(forResource: "word\(levelNumber)", ofType: "plist")
        //load .plist file
        let url = URL(fileURLWithPath: stringPath!)
        let levelDictionary: NSDictionary? = NSDictionary(contentsOf: url)
        //validation
        assert(levelDictionary != nil, "Level configuration file not found")
        //initialize the object from the dictionary
        self.list = levelDictionary!["wordslist"] as! [NSDictionary]
    }
}

class WordScramble {
    
    let contentPool : ListOfWordScramble
    let randomIndexes = [Int]()
    var currentLevel = 1
    var accuracy = 0.0
    let selectedLevelForEachLevel = 15
    var currentPoints = 0
    
//    func generateRandomIndex()->[Int]{
//        return []
//    }
    
    init(level:Int) {
        self.currentLevel = level
        self.contentPool = ListOfWordScramble(levelNumber: level)
    }
    
    
}
