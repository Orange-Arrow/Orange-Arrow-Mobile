//
//  ProfileVC.swift
//  Orange Arrow Mobile
//
//  Created by 刘祥 on 3/6/19.
//  Copyright © 2019 xiangliu90. All rights reserved.
//

import UIKit
import Firebase
import LGButton


class ProfileVC: UIViewController {

    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var schoolLabel: UILabel!
    @IBOutlet weak var sportsLabel: UILabel!
    @IBOutlet weak var triviaProgressBar: UIView!
    @IBOutlet weak var puzzleProgressBar: UIView!
    @IBOutlet weak var wordProgressBar: UIView!
    @IBOutlet weak var originalBar: UIView!
    @IBOutlet var barWidthConstraintCollection: [NSLayoutConstraint]!
    @IBOutlet var levelBarCollection: [UIView]!
    
    @IBOutlet weak var badgeCollectionView: UICollectionView!
    var badgeArr = [String]()
    let gameName = ["trivia","puzzle","words"]
    var handle : UInt?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        retrivalUserData()

        guard let statusBarView = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView else {
            return
        }
        statusBarView.backgroundColor = .gray
        
        let navItem = Utilities.setupNavigationBar(image: "icon_profile", tappedFunc: #selector(backBtnTapped), handler: self)
        navigationBar.setItems([navItem], animated: false)

        // Do any additional setup after loading the view.
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

    @IBAction func updateBtnTapped(_ sender: LGButton) {
        performSegue(withIdentifier: "updateProfileFromProfileSegue", sender: self)
    }
    


    
    //MARK -- TO GET THE USER DATA
    private func retrivalUserData(){
        let userID = Auth.auth().currentUser?.uid
        
        self.handle = Utilities.ref_db.child("users_information").child(userID!).observe(.value) { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            let firstName = value?["First Name"] as? String ?? ""
            let lastName = value?["Last Name"] as? String ?? ""
            let imageurl = value?["ProfileImageUrl"] as? String ?? ""
            let school = value?["School"] as? String ?? ""
            let sports  = value?["Sports"] as? String ?? ""
            let level = value?["Levels"] as? NSArray ?? [0,0,0]
            let badgeOfTime = value?["BadgeOfTime"] as? NSDictionary ?? [:]
            let badgeOfPoints = value?["BadgeOfPoints"] as? NSDictionary ?? [:]
            for name in self.gameName{
                let badgeBool = badgeOfTime[name] as? NSArray ?? []
                let badgeBoolPoints = badgeOfPoints[name] as? NSArray ?? []
                for level in 1...totalLevelNum{
                    if badgeBool[level-1] as! Bool == true{
                        //get the badge
                        self.badgeArr.append("\(name.capitalized) time\(level)")
                    }
                    if badgeBoolPoints[level-1] as! Bool == true{
                        self.badgeArr.append("\(name.capitalized) points\(level)")
                    }
                }
            }
            self.badgeCollectionView.reloadData()
            
            self.updateUI(name: "\(firstName) \(lastName)", image: imageurl, school: school, sports: sports, levels: level)
        }
    }
    
    private func updateUI(name:String, image:String, school:String, sports:String, levels:NSArray){
        nameLabel.text = "Hello, \(name)"
        schoolLabel.text = "School: \(school)"
        sportsLabel.text = "Sports: \(sports)"
        var levelsInNum = [Int]()
        for level in levels{
            guard let n = (level as AnyObject).integerValue else {return}
            levelsInNum.append(n)
        }
        
        if let url = URL(string: image){
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: url) {
                    //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
                    DispatchQueue.main.async {
                        self.profileImage.image = UIImage(data: data)
                    }
                }
            }
        }
        
        for (index,constraint) in barWidthConstraintCollection.enumerated(){
            constraint.constant = (originalBar.frame.size.width / CGFloat(totalLevelNum)) * CGFloat(levelsInNum[index])
            levelBarCollection[index].layoutIfNeeded()
        }
    }

    


}

extension ProfileVC:UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.badgeArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath) as! CollectionViewCell
        cell.badgeImg.image = UIImage(named: badgeArr[indexPath.item])
        return cell
        
    }
    
    
}
