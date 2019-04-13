//
//  CategoryTableViewController.swift
//  Orange Arrow Mobile
//
//  Created by 刘祥 on 4/12/19.
//  Copyright © 2019 xiangliu90. All rights reserved.
//

import UIKit


protocol CategoryDelegate: class {
    func setTheValueForRanking(level:Int,game:String,category:String)
}

class CategoryTableViewController: UITableViewController {
    
    var choicesArray = [[(String,String)]]()
    let gameName = ["icon_trivia","icon_puzzle","icon_word"]
    let category = ["Shortest Time Used", "Most Points Earned"]
    weak var delegate: CategoryDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        initializeValues()
        tableView.register(UINib(nibName: "CategoryTableViewCell", bundle: nil), forCellReuseIdentifier: "categoryCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 120

      
    }
    
    private func initializeValues(){
        for _ in 1...totalLevelNum{
            var section = [(String,String)]()
            for game in gameName{
                for cate in category{
                    let tuble = (game,cate)
                    section.append(tuble)
                }
            }
            self.choicesArray.append(section)
            tableView.rowHeight = UITableView.automaticDimension
            tableView.estimatedRowHeight = 120
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return choicesArray.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return choicesArray[section].count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Level \(section+1)"
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath) as! CategoryTableViewCell
        
        cell.gameNameImage?.image = UIImage(named: self.choicesArray[indexPath.section][indexPath.row].0)
        cell.rankingLabel.text = self.choicesArray[indexPath.section][indexPath.row].1
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("the level is \(indexPath.section+1)")
        print("the game Name \(choicesArray[indexPath.section][indexPath.row].0)")
        let gameName = choicesArray[indexPath.section][indexPath.row].0
        let underIndex = gameName.index(after: gameName.index(of: "_")!)

        let game = gameName[underIndex...]
        var cate = ""
        switch choicesArray[indexPath.section][indexPath.row].1{
        case "Shortest Time Used": cate = "time"
        case "Most Points Earned": cate = "points"
        default:
            return
        }
        print("======the value is and \(game) \(cate)")
        self.delegate?.setTheValueForRanking(level: indexPath.section+1, game: String(game), category: cate)
        //////to pass the value to ranking table view controller 
    }



}
