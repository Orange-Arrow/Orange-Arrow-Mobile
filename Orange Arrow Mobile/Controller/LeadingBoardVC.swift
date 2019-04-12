//
//  LeadingBoardVC.swift
//  Orange Arrow Mobile
//
//  Created by 刘祥 on 3/6/19.
//  Copyright © 2019 xiangliu90. All rights reserved.
//

import UIKit
import Firebase

class LeadingBoardVC: UIViewController {
    
    class Ranking {
        var image = ""
//        var image = UIImage()
        var name : String = ""
        var level : Int = 0
        var progress : Int = 0
        
    }
    
    var rankingArray = [Ranking](){
        willSet(newVal){
            // everytime check new value
        }
    }
    var game_name = "Puzzle"
    var selectedLevel = 1
    
    
    

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    var maxProgressTime = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let navItem = Utilities.setupNavigationBar(image: "icon_ranking", tappedFunc: #selector(backBtnTapped), handler: self)
        navigationBar.setItems([navItem], animated: false)
        // on the right bar item, should include a new one which is for change different categories
        
        setupDelegation()
        
        tableView.register(UINib(nibName: "RankingTableViewCell", bundle: nil), forCellReuseIdentifier: "customRankingCell")
    
        rankingByTime(gameName: game_name, level: selectedLevel)
        configureTableView()


    }
    
    @objc func backBtnTapped(){
        dismiss(animated: true, completion: nil)
        Utilities.changeStatusBarColor(color: UIColor(named: "oaColor")!)
        // the color looks so different tho???
    }
    
    
    
    //to ranking the result
    private func rankingByTime(gameName:String, level:Int){

        let resultSortByTime = Utilities.ref_db.child(gameName).child(String(level)).queryOrdered(byChild: "time").queryLimited(toFirst: 10)
        
        resultSortByTime.observe(.value) { snapshot in
            
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                let uid = child.key

                if let dic = child.value as? [String:Any], let time = dic["time"] as? Int{
            
                    //based on uid get the user first last name and image
                    Utilities.ref_db.child("users_information").child(uid).observeSingleEvent(of: .value, with: { (snap) in
                        if let value = snap.value as? NSDictionary {
                            let firstname = value["First Name"] as? String ?? ""
                            let lastname = value["Last Name"] as? String ?? ""
                            let imageurl = value["ProfileImageUrl"] as? String ?? ""
                            
                            let rankingObj = Ranking()
                            rankingObj.image = imageurl
                            rankingObj.level = level
                            rankingObj.name = "\(firstname) \(lastname)"
                            rankingObj.progress = time
                            //add to the array
                            self.rankingArray.append(rankingObj)
                            self.configureTableView()
                            self.tableView.reloadData()
    
                        }
                    })
                }
            }
        }
    }
    

}






extension LeadingBoardVC: UITableViewDelegate, UITableViewDataSource{
    
    func setupDelegation(){
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rankingArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "customRankingCell", for: indexPath) as! RankingTableViewCell
        cell.levelLabel.text = "Lv.\(rankingArray[indexPath.row].level)"
        cell.nameLabel.text = rankingArray[indexPath.row].name
        cell.rankNum.text = "No.\(indexPath.row+1)"
        
        //download the iamge data

        if let url = URL(string: rankingArray[indexPath.row].image){
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: url) {
                    DispatchQueue.main.async {
                        cell.profileImg.image = UIImage(data: data)!
                        
                    }//
                }
            }//
        }


            let originalWidth = cell.originalBarView.frame.size.width
            print("!!!!!originalwidth is \(originalWidth)")
            //        let unitWidth = originalWidth / 10
            
            cell.widthConstraint.constant = 1 * CGFloat(rankingArray[indexPath.row].progress)
            cell.progressBarView.layoutIfNeeded()


        return cell
    }
    
    func configureTableView(){
            tableView.rowHeight = UITableView.automaticDimension
            tableView.estimatedRowHeight = 120

  
    }
    
    
}
