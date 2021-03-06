//
//  Utilities.swift
//  Orange Arrow Mobile
//
//  Created by 刘祥 on 3/6/19.
//  Copyright © 2019 xiangliu90. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class Utilities{
    
    static var ref_db: DatabaseReference = Database.database().reference()
    
    //this function might not be right because the color rendered looks weird
    static func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    
    
    //MARK -- change the status bar color
    static func changeStatusBarColor(color:UIColor){
        guard let statusBarView = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView else {
            return
        }
        statusBarView.backgroundColor = color
    }
    
    
    // MARK -- to make navigation bar item
    static func setupNavigationBar(image:String, tappedFunc:Selector, handler:AnyObject) -> UINavigationItem{
        
        let navItem = UINavigationItem(title: "")
        
        let titleImageView = UIImageView(image: UIImage(named:image))
        titleImageView.frame = CGRect(x: 0, y: 0, width: 34, height: 34)
        titleImageView.contentMode = .scaleAspectFit
        navItem.titleView = titleImageView
        
        let backButton = UIButton(type: .system)
        backButton.setImage(UIImage(named:"backBtn"), for: .normal)
        backButton.imageView?.contentMode = .scaleAspectFit
        backButton.tintColor = .white
        backButton.frame = CGRect(x: 0, y: 0, width: 34, height: 34)
        backButton.addTarget(handler, action: tappedFunc, for: .touchUpInside)
        navItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        return navItem
        
    }
    
    ///////
    // MARK -- to make navigation bar item
    static func setupNavigationBar(image:String, tappedFunc:Selector, handler:AnyObject, rightBar:Selector) -> UINavigationItem{
        
        let navItem = UINavigationItem(title: "")
        
        let titleImageView = UIImageView(image: UIImage(named:image))
        titleImageView.frame = CGRect(x: 0, y: 0, width: 34, height: 34)
        titleImageView.contentMode = .scaleAspectFit
        navItem.titleView = titleImageView
        
        let backButton = UIButton(type: .system)
        backButton.setImage(UIImage(named:"backBtn"), for: .normal)
        backButton.imageView?.contentMode = .scaleAspectFit
        backButton.tintColor = .white
        backButton.frame = CGRect(x: 0, y: 0, width: 34, height: 34)
        backButton.addTarget(handler, action: tappedFunc, for: .touchUpInside)
        navItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        navItem.rightBarButtonItem = UIBarButtonItem(title: "Category", style: .plain, target: handler, action: rightBar)
        return navItem
        
    }
    
    // static --  to get the target time and points for certain game for badges
    static func getTargetForBadge(gameName:String, level:Int, measure:String) -> Int {
        // badgeOfTime , badgeOfPoints
        let stringPath = Bundle.main.path(forResource: measure, ofType: "plist")
        
        let url = URL(fileURLWithPath: stringPath!)
        let gameDictionary = NSDictionary(contentsOf: url)
        assert(gameDictionary != nil, "badge configuration file not found")
        let list = gameDictionary!["\(gameName)"] as! NSArray
        let leveltarget = list[level-1] as! Int
        return leveltarget
        
    }
    
    
    // update user badge of time true or false
    static func updateBadgeInFirebase(level:Int, gameName:String, measure:String){
        // BadgeOfTime, BadgeOfPoints
        guard let userID = Auth.auth().currentUser?.uid else { fatalError("No User Sign In") }
        let targetDB = self.ref_db.child("users_information").child(userID).child(measure).child(gameName).child(String(level-1))
        
        targetDB.setValue(true)
        
    }
    
    
    //MARK -- FUNCTION TO RETURN RIGHT FORMAT OF TIME
    static func timeFormatted(_ totalSeconds: Int) -> String {
        let seconds: Int = totalSeconds % 60
        let minutes: Int = (totalSeconds / 60) % 60
        //     let hours: Int = totalSeconds / 3600
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    

    
    
    //mark -- get level
    static func getLevel(num:Int, completion:@escaping (_ level:Int)->()){
        let userID = Auth.auth().currentUser?.uid
        
        self.ref_db.child("users_information").child(userID!).child("Levels").observeSingleEvent(of: .value) { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSArray ?? []
            
            let levelToBeOpen = value[num] as! Int
            
            completion(levelToBeOpen)
        }
      
    }
    
    // to store the data of game
    static func storeResult(gameName:String, level:Int, points:Int, time:Int, gameIndictorNum:Int, levelFull:Bool){
        let targetDB = self.ref_db.child(gameName).child(String(level))
        guard let userID = Auth.auth().currentUser?.uid else { fatalError("No User Sign In") }
        
        //to format date
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM, dd, yyyy HH:mm:ss a"
        let date = formatter.string(from: Date())
        
        let resultDictionary = ["time":time,"points":points,"date":date] as [String : Any]
        targetDB.child("\(userID)").setValue(resultDictionary)
        
        
    // higher the level
        if levelFull{
            print("level is full")
        }else{
            self.ref_db.child("users_information/\(userID)/Levels/\(gameIndictorNum)").setValue(level+1)
        }
       

    }
    
    //to show the success alert
    static func showSuccessAlert(level:Int, points:Int, gameTime:Int, targetVC:UIViewController, goback:@escaping ()->(), nextLevel:@escaping (_ isSuccess: Bool)->() ){
        
        //to start
        let message = "You finished level\(level)'s all questions with \(points) points in \(Utilities.timeFormatted(gameTime))."
        let alert = UIAlertController(title: "Congrats", message: message, preferredStyle: .alert)
        let nextLevelAction = UIAlertAction(title: "Go to play next level", style: .default, handler: { (UIAlertAction) in nextLevel(true) })
        let goBackAction = UIAlertAction(title: "Go back to main menu", style: .default, handler: { (UIAlertAction) in goback() })
        alert.addAction(nextLevelAction)
        alert.addAction(goBackAction)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
            targetVC.present(alert, animated: true, completion: nil)
        }
    }
    //to show the failure alert
    static func showFailureAlert(level:Int, points:Int, gameTime:Int, targetVC:UIViewController,  goback:@escaping ()->(), tryagain:@escaping (_ isSuccess:Bool)->() ){
        
        //to start
        let message = "You finished level\(level)'s all questions with \(points) points in \(Utilities.timeFormatted(gameTime)). And you didn't pass this level this time."
        let alert = UIAlertController(title: "Sorry", message: message, preferredStyle: .alert)
        let tryagainAction = UIAlertAction(title: "Try it again !", style: .default, handler: { (UIAlertAction) in tryagain(false) })
        let goBackAction = UIAlertAction(title: "Go back to main menu", style: .default, handler: { (UIAlertAction) in goback() })
        alert.addAction(tryagainAction)
        alert.addAction(goBackAction)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
            targetVC.present(alert, animated: true, completion: nil)
        }
    }
    
    //to show the alert for our of questions
    static func showOutofQuestionAlert(level:Int?, points:Int?, gameTime:Int?, targetVC:UIViewController, goback:@escaping ()->() ){
        
        //to start
        var message:String?
        if let levelAlert = level, let pointsAlert = points, let timeAlert = gameTime{
             message = "You finished level\(levelAlert)'s all questions with \(pointsAlert) points in \(Utilities.timeFormatted(timeAlert)). And you reached our highest level for this game!"
        }else{
            message = "You reached our highest level for this game! Come back next time"
        }
       
        let alert = UIAlertController(title: "Congrats", message: message!, preferredStyle: .alert)
        let goBackAction = UIAlertAction(title: "Go back to main menu", style: .default, handler: { (UIAlertAction) in goback() })
        alert.addAction(goBackAction)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
            targetVC.present(alert, animated: true, completion: nil)
        }
    }

    
    
}


extension Array {
    /// Returns an array containing this sequence shuffled
    var shuffled: Array {
        var elements = self
        return elements.shuffle()
    }
    /// Shuffles this sequence in place
    @discardableResult
    mutating func shuffle() -> Array {
        let count = self.count
        indices.lazy.dropLast().forEach {
            swapAt($0, Int(arc4random_uniform(UInt32(count - $0))) + $0)
        }
        return self
    }
    var chooseOne: Element { return self[Int(arc4random_uniform(UInt32(count)))] }
    func choose(_ n: Int) -> Array { return Array(shuffled.prefix(n)) }
}


extension UIView {
    func fadeTransition(_ duration:CFTimeInterval) {
        let animation = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name:
            CAMediaTimingFunctionName.easeInEaseOut)
        animation.type = CATransitionType.fade
        animation.duration = duration
        layer.add(animation, forKey: CATransitionType.fade.rawValue)
    }
}
