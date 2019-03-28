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
    


    
    
    
}
