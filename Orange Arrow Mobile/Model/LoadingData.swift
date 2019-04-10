//
//  Trivia.swift
//  Orange Arrow Mobile
//
//  Created by 刘祥 on 3/6/19.
//  Copyright © 2019 xiangliu90. All rights reserved.
//

import Foundation

class LoadingData{
    
    var selectedPool = [Question]()
    
    init(level:Int, count:Int,game:String) {
        
        let stringPath = Bundle.main.path(forResource: "\(game)\(level)", ofType: "plist")
        print("=======the string path is \(String(describing: stringPath))")
        
        let url = URL(fileURLWithPath: stringPath!)
        let levelDictionary = NSDictionary(contentsOf: url)
        assert(levelDictionary != nil, "Level configuration file not found")
        let list = levelDictionary!["\(game)list"] as! [NSDictionary]
        
        //after get data from plist, parse it into Question struct and random select random
        // to select and assign it to puzzle list
        let randomlist = list.choose(count)
        
        for item in randomlist{
            let questionText = item["quesText"] as! String
            let options = item["options"] as! [String]
            let answer = item["answer"] as! Int
            //            print(item)
            let question = Question(questText: questionText, options: options, answer: answer)
            self.selectedPool.append(question)
        }
    }

    
}
