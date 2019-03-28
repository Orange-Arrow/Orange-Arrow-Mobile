//
//  ProfileVC.swift
//  Orange Arrow Mobile
//
//  Created by 刘祥 on 3/6/19.
//  Copyright © 2019 xiangliu90. All rights reserved.
//

import UIKit

class ProfileVC: UIViewController {

    @IBOutlet weak var navigationBar: UINavigationBar!

    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let statusBarView = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView else {
            return
        }
        statusBarView.backgroundColor = .gray
        
        let navItem = Utilities.setupNavigationBar(image: "icon_profile", tappedFunc: #selector(backBtnTapped), handler: self)
        navigationBar.setItems([navItem], animated: false)

        // Do any additional setup after loading the view.
    }
    
    @objc func backBtnTapped(){
        dismiss(animated: true, completion: nil)
        Utilities.changeStatusBarColor(color: UIColor(named: "oaColor")!)
        // the color looks so different tho???
    }
    
    

    

    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        self.setNeedsStatusBarAppearanceUpdate()
//    }
//
//    override var preferredStatusBarStyle : UIStatusBarStyle {
//        return .lightContent
//    }
    
//    //MARK -- SET the navagation bar
//    func setNavigationBar() {
//        let screenSize: CGRect = UIScreen.main.bounds
//        let navBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: 44))
//        let navItem = UINavigationItem(title: "Profile")
//        let doneItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: nil, action: #selector(done))
//        navItem.rightBarButtonItem = doneItem
//        navBar.setItems([navItem], animated: false)
//        self.view.addSubview(navBar)
//    }
//
//    @objc func done() { // remove @objc for Swift 3
//        print("123123")
//
//    }
    



}
