//
//  LeadingBoardVC.swift
//  Orange Arrow Mobile
//
//  Created by 刘祥 on 3/6/19.
//  Copyright © 2019 xiangliu90. All rights reserved.
//

import UIKit
import Firebase
import SideMenu

class LeadingBoardVC: UIViewController {
    
    class Ranking {
        var image = ""
        var name : String = ""
        var level : Int = 0
        var progress : Int = 0
        
    }
    
    
    
    var rankingArray = [Ranking](){
        willSet(newVal){
            // everytime check new value
        }
    }
    
    // i think it should be a new class to contain all three
    var game_name = "Puzzle"{
        willSet(newVal){
            
        }
    }
    var selectedLevel = 1 {
        willSet(newVal){
            //do something to get the new data
        }
    }
    var rankingType = ""
 


    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    var maxProgressTime = 0
    
    var rootviewVC = CategoryTableViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set up the delegation
        
//        guard let navigationController = self.navigationController else {
//            return
//        }
//        navigationController.navigationBar.barTintColor = .black
        
        // Do any additional setup after loading the view.
        let navItem = Utilities.setupNavigationBar(image: "icon_ranking", tappedFunc: #selector(backBtnTapped), handler: self, rightBar: #selector(categoryTapped))
        
        navigationBar.setItems([navItem], animated: false)
 
        // on the right bar item, should include a new one which is for change different categories
        
        setupDelegation()
        
        tableView.register(UINib(nibName: "RankingTableViewCell", bundle: nil), forCellReuseIdentifier: "customRankingCell")
    
        rankingByTime(gameName: game_name, level: selectedLevel)
        configureTableView()
        
//        showMore()


    }
    
    @objc func categoryTapped(){
        performSegue(withIdentifier: "rankingToSideSegue", sender: self)
        
    }
    
    // SET UP THE DELEGATION
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "rankingToSideSegue"{
            let destinationVC = segue.destination as? UISideMenuNavigationController
            guard let target = destinationVC?.viewControllers.first as? CategoryTableViewController else{return}
            self.rootviewVC = target
            self.rootviewVC.delegate = self
        }
    }
    
    
    func showMore(){
        // Define the menus

        SideMenuManager.default.menuRightNavigationController = storyboard!.instantiateViewController(withIdentifier: "RightMenuNavigationController") as? UISideMenuNavigationController
        
//        SideMenuManager.default.menuAddPanGestureToPresent(toView: self.navigationController!.navigationBar)
//        SideMenuManager.default.menuAddScreenEdgePanGesturesToPresent(toView: self.navigationController!.view)
        
        // Set up a cool background image for demo purposes
        SideMenuManager.default.menuAnimationBackgroundColor = UIColor(patternImage: UIImage(named: "stars")!)
        
        print("@#####this is below")
   
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



extension LeadingBoardVC: CategoryDelegate{
    
    func setTheValueForRanking(level: Int, game: String, category: String) {
        print("=========this is working")
        print("\(level) and game \(game) and cate \(category)")
        self.game_name = game
        self.rankingType = category
        self.selectedLevel = level
        
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
