//
//  NavigationVC.swift
//  Orange Arrow Mobile
//
//  Created by 刘祥 on 3/6/19.
//  Copyright © 2019 xiangliu90. All rights reserved.
//

import UIKit
import CircleMenu
import Firebase

class NavigationVC: UIViewController, CircleMenuDelegate {
    
    @IBOutlet weak var menuTextview: UILabel!
    
    let items: [(icon: String, color: UIColor, content: String, segue: String)] = [
        ("icon_profile", Utilities.hexStringToUIColor(hex: "FF2600"), "Check out your profile page, where you can review and update your information at OA and check out the level you reached and badges you earned at OA", "menuToProfileSegue"),
        ("icon_trivia", Utilities.hexStringToUIColor(hex: "FFFB00"), "Learn core values while playing trivia games at OA! Each level you will face random questions and choose one as the right one, be careful you will only have one time to choose! High points and short time will make you advance to next level and earn coolest badges", "menuToTriviaSegue"),
        ("icon_puzzle", Utilities.hexStringToUIColor(hex: "8EFA00"), "Guess your favorite sports star at OA! Each question you can click an OA ambassdor image to reveal a piece of picture, and you will have to wait for certain time to be able to click again. Make the guess whenever you can if you know which star is from the picture. Try to earn more points while make your move fast!", "menuToPuzzleSegue"),
        ("icon_word", Utilities.hexStringToUIColor(hex: "00FDFF"), "Learn word at OA! Each round, you will guess a word based on image hint. You can place the letter in the wrong place no more than 3 times and use the hint only once! Each word, you have to figure out within certain time, be aware! Learn more words with OA now!", "menuToWordScrambleSegue"),
        ("icon_ranking", Utilities.hexStringToUIColor(hex: "0096FF"), "this will show various game ranking", "menuToLeadingBoardSegue"),
        ("icon_achievement", Utilities.hexStringToUIColor(hex: "9437FF"), "check out your own achievement to unlock various awesome badges", "menuToAchievementSegue"),
        ("icon_setting", Utilities.hexStringToUIColor(hex: "FF40FF"), "Having a question to OA? Go to this page and submit your question to OA and someone from OA will reply you asap. You can also view the privacy settings as well as deleting your account.", "menuToSettingSegue"),
        ("icon_logout", Utilities.hexStringToUIColor(hex: "FF2F92"), "Logout OA game and get some rest for tomorrow!",""),
    ]

    @IBOutlet weak var circleMenu: CircleMenu!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        menuTextview.layer.borderColor = UIColor.black.cgColor
//        menuTextview.layer.borderWidth = 0.5
        
        circleMenu.delegate = self
        // Do any additional setup after loading the view.
        menuTextview.text = "Welcome to Orange Arrow Game Center, please click the house to start your journey"
       
        
        circleMenu.setImage(UIImage(named: "menu"), for: .normal)
        circleMenu.setImage(UIImage(named: "cancel"), for: .selected)
        circleMenu.imageView?.contentMode = .scaleAspectFill

    
    }
    
    
    // MARK: <CircleMenuDelegate>
    func circleMenu(_: CircleMenu, willDisplay button: UIButton, atIndex: Int) {
        
     
        
        button.backgroundColor = items[atIndex].color
        
        button.setImage(UIImage(named: items[atIndex].icon), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.imageEdgeInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
        
        // set highlited image
        let highlightedImage = UIImage(named: items[atIndex].icon)?.withRenderingMode(.alwaysTemplate)
        button.setImage(highlightedImage, for: .highlighted)
        button.tintColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
    }
    
    func circleMenu(_: CircleMenu, buttonWillSelected _: UIButton, atIndex: Int) {
       
        menuTextview.text = items[atIndex].content
    }
    
    func circleMenu(_: CircleMenu, buttonDidSelected _: UIButton, atIndex: Int) {
        
        switch atIndex {
        case 7: signout()
        default: performSegue(withIdentifier: items[atIndex].segue, sender: self)
        }
        
    }
    
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        switch segueName{
//            case items[]
//        }
//    }
    
    // MARK -- THE FUNCTION to signout user from current session
    func signout(){
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            // got back to the former page
            dismiss(animated: true, completion: nil)
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }


}






//Icons made by Freepik from www.flaticon.com is licensed by CC 3.0 BY
//Icons made by Smashicons from www.flaticon.com is licensed by CC 3.0 BY
