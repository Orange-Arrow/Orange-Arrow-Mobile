//
//  AcievementVC.swift
//  Orange Arrow Mobile
//
//  Created by 刘祥 on 3/6/19.
//  Copyright © 2019 xiangliu90. All rights reserved.
//

import UIKit

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
        tableView.separatorStyle = .none
        
        
        // Do any additional setup after loading the view.
        let navItem = Utilities.setupNavigationBar(image: "icon_achievement", tappedFunc: #selector(backBtnTapped), handler: self)
        navigationBar.setItems([navItem], animated: false)
    }
    
    @objc func backBtnTapped(){
        dismiss(animated: true, completion: nil)
        Utilities.changeStatusBarColor(color: UIColor(named: "oaColor")!)
        // the color looks so different tho???
    }
    
    //TODO: Create the retrieveMessages method here:
    func retrieveAchievements(){
//        let messageDB = Database.database().reference().child("Messages")
//        messageDB.observe(.childAdded) { (snapshot) in
//            let snapshotValue = snapshot.value as! Dictionary<String,String>
//            let text = snapshotValue["MessageBody"]!
//            let sender = snapshotValue["Sender"]!
//            let message = Message()
//            message.messageBody = text
//            message.sender = sender
//            self.messageArray.append(message)
//            self.configureTableView()
//            self.messageTableView.reloadData()
//        }
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
        tableView.estimatedRowHeight = 120.0
    }
    
}
