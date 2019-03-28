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
        ("icon_profile", Utilities.hexStringToUIColor(hex: "FF2600"), "Go to your profile page", "menuToProfileSegue"),
        ("icon_trivia", Utilities.hexStringToUIColor(hex: "FFFB00"), "this is the rule of trivia game", "menuToTriviaSegue"),
        ("icon_puzzle", Utilities.hexStringToUIColor(hex: "8EFA00"), "this is the rule of puzzle game", "menuToPuzzleSegue"),
        ("icon_word", Utilities.hexStringToUIColor(hex: "00FDFF"), "this is the rule of word scramble game", "menuToWordScrambleSegue"),
        ("icon_ranking", Utilities.hexStringToUIColor(hex: "0096FF"), "this will show various game ranking", "menuToLeadingBoardSegue"),
        ("icon_achievement", Utilities.hexStringToUIColor(hex: "9437FF"), "check out your own achievement to unlock various awesome badges", "menuToAchievementSegue"),
        ("icon_setting", Utilities.hexStringToUIColor(hex: "FF40FF"), "contact us or view various policy or just check settings", "menuToSettingSegue"),
        ("icon_logout", Utilities.hexStringToUIColor(hex: "FF2F92"), "this will help you log out the app,simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum",""),
    ]

    @IBOutlet weak var circleMenu: CircleMenu!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
