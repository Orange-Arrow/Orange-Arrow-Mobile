//
//  LoginVC.swift
//  Orange Arrow Mobile
//
//  Created by 刘祥 on 3/6/19.
//  Copyright © 2019 xiangliu90. All rights reserved.
//

import UIKit
import LGButton

class LoginVC: UIViewController {
    
    @IBOutlet weak var forgetPasswordLink: UIButton!
    @IBOutlet weak var loginButton: LGButton!
    @IBOutlet weak var googleButton: LGButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        forgetPasswordLink.addTarget(self, action: #selector(forgetPasswordTapped), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(loginBtnTapped), for: .touchUpInside)
        googleButton.addTarget(self, action: #selector(googleBtnTapped), for: .touchUpInside)
        // Do any additional setup after loading the view.
    }
    
    @objc func forgetPasswordTapped(){
        print("the forget button works")
    }
    
    @objc func loginBtnTapped(){
        print("the login button works")
    }
    
    @objc func googleBtnTapped(){
        print("the google button works")
    }
    
}




