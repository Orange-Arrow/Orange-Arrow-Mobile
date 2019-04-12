//
//  AcievementVC.swift
//  Orange Arrow Mobile
//
//  Created by 刘祥 on 3/6/19.
//  Copyright © 2019 xiangliu90. All rights reserved.
//

import UIKit
import Firebase

class AcievementVC: UIViewController {

    @IBOutlet weak var navigationBar: UINavigationBar!
    
    @IBOutlet weak var tableView: UITableView!
    
    class Achievement {

        var image : String = ""
        var title : String = ""
        var level : String = ""
        
    }

    var achievementsArray = [Achievement]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupDelegation()
        
        tableView.register(UINib(nibName: "AchievementsTableViewCell", bundle: nil), forCellReuseIdentifier: "customAchievementCell")
        
        configureTableView()
        retrieveAchievements()
//        tableView.separatorStyle = .none
        
        
        // Do any additional setup after loading the view.
        let navItem = Utilities.setupNavigationBar(image: "icon_achievement", tappedFunc: #selector(backBtnTapped), handler: self)
        navigationBar.setItems([navItem], animated: false)
    }
    
    @objc func backBtnTapped(){
        dismiss(animated: true, completion: nil)
        Utilities.changeStatusBarColor(color: UIColor(named: "oaColor")!)
        // the color looks so different tho???
    }
    
    private func checkIfGetBadgeOfTime(list:[Bool], gameName:String) {
        for (index,item) in list.enumerated(){
            if item{
                //it has the badge
                let achievement = Achievement()
                achievement.title = "Quick Answer Warrior for \(gameName)"
                achievement.image = "\(gameName) time\(index+1)"
                achievement.level = "Level: \(index+1)"
                self.achievementsArray.append(achievement)
                
                self.configureTableView()
                self.tableView.reloadData()
                
            }
        }
    }
    
    //TODO: Create the retrieveMessages method here:
    func retrieveAchievements(){
        
        let userID = Auth.auth().currentUser?.uid
        
        Utilities.ref_db.child("users_information").child(userID!).child("BadgesOfTime").observe(.value) { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            let triviaBadge = value?["trivia"] as? NSArray ?? []
            let puzzleBadge = value?["puzzle"] as? NSArray ?? []
            let wordsBadge = value?["words"] as? NSArray ?? []
            
            let triviaArray: [Bool] = triviaBadge.compactMap({ $0 as? Bool })
            let puzzleArray: [Bool] = puzzleBadge.compactMap({ $0 as? Bool })
            let wordsArray: [Bool] = wordsBadge.compactMap({ $0 as? Bool })
            
            
            // for each array check which is right
            self.checkIfGetBadgeOfTime(list: triviaArray, gameName: "Trivia")
            self.checkIfGetBadgeOfTime(list: puzzleArray, gameName: "Puzzle")
            self.checkIfGetBadgeOfTime(list: wordsArray, gameName: "Word Scramble")
            
          
        }

    }
}


extension AcievementVC: UITableViewDelegate, UITableViewDataSource{
    
    func setupDelegation(){
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return achievementsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "customAchievementCell", for: indexPath) as! AchievementsTableViewCell
      
        cell.levelLabel.text = achievementsArray[indexPath.row].level
        cell.badgeImage.image = UIImage(named: achievementsArray[indexPath.row].image)

        cell.titleLabel.text = achievementsArray[indexPath.row].title
        
        return cell
    }
    
    func configureTableView(){
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 120
    }
    
}
