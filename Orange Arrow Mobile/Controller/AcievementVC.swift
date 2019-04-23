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
    var handle : UInt?

    var achievementsArray = [Achievement]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let statusBarView = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView else {
            return
        }
        statusBarView.backgroundColor = Utilities.hexStringToUIColor(hex: "FEC341")
        
        setupDelegation()
        tableView.isUserInteractionEnabled = false
        tableView.register(UINib(nibName: "AchievementsTableViewCell", bundle: nil), forCellReuseIdentifier: "customAchievementCell")
        
        configureTableView()
        retrieveAchievements()
//        tableView.separatorStyle = .none
        
        
        // Do any additional setup after loading the view.
        let navItem = Utilities.setupNavigationBar(image: "icon_achievement", tappedFunc: #selector(backBtnTapped), handler: self)
        navigationBar.setItems([navItem], animated: false)
        navigationBar.barTintColor = Utilities.hexStringToUIColor(hex: "FEC341")
    }
    
    @objc func backBtnTapped(){
        if let handle = self.handle{
            // Use this to remove the observer when you are done
            Utilities.ref_db.child("users_information").removeObserver(withHandle: handle)
        }
        dismiss(animated: true, completion: nil)
        Utilities.changeStatusBarColor(color: UIColor(named: "oaColor")!)
        // the color looks so different tho???
    }
    
    private func checkIfGetBadgeOfTime(list:[Bool], gameName:String, measure:String) {
        for (index,item) in list.enumerated(){
            if item{
                //it has the badge
                // quick answer warrior
                // 100% points GOAT
                var meaString = ""
                if measure == "BadgeOfTime"{
                    meaString += "Quick Answer Warrior"
                }else if measure == "BadgeOfPoints"{
                    meaString += "100% Points GOAT"
                }
                var meaImg = ""
                if measure == "BadgeOfTime"{
                    meaImg += "time"
                }else if measure == "BadgeOfPoints"{
                    meaImg += "points"
                }
                
                let achievement = Achievement()
                achievement.title = "\(meaString) for \(gameName)"
                achievement.image = "\(gameName) \(meaImg)\(index+1)"
                achievement.level = "Level: \(index+1)"
                self.achievementsArray.append(achievement)
                
                self.configureTableView()
                self.tableView.reloadData()
                
            }
        }
    }
    
    private func findAndAddBadgeFromDB(measure:String){
        let userID = Auth.auth().currentUser?.uid
        
        self.handle = Utilities.ref_db.child("users_information").child(userID!).child(measure).observe(.value) { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            let triviaBadge = value?["trivia"] as? NSArray ?? []
            let puzzleBadge = value?["puzzle"] as? NSArray ?? []
            let wordsBadge = value?["words"] as? NSArray ?? []
            
            let triviaArray: [Bool] = triviaBadge.compactMap({ $0 as? Bool })
            let puzzleArray: [Bool] = puzzleBadge.compactMap({ $0 as? Bool })
            let wordsArray: [Bool] = wordsBadge.compactMap({ $0 as? Bool })
            
            
            // for each array check which is right
            self.checkIfGetBadgeOfTime(list: triviaArray, gameName: "Trivia", measure: measure)
            self.checkIfGetBadgeOfTime(list: puzzleArray, gameName: "Puzzle", measure: measure)
            self.checkIfGetBadgeOfTime(list: wordsArray, gameName: "Word", measure: measure)
            
            
        }
        
    }
    
    //TODO: Create the retrieveMessages method here:
    func retrieveAchievements(){
        findAndAddBadgeFromDB(measure: "BadgeOfTime")
        findAndAddBadgeFromDB(measure: "BadgeOfPoints")
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
