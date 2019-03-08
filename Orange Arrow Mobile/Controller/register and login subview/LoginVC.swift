//
//  LoginVC.swift
//  Orange Arrow Mobile
//
//  Created by 刘祥 on 3/6/19.
//  Copyright © 2019 xiangliu90. All rights reserved.
//

import UIKit

class LoginVC: UIViewController {
    
    @IBOutlet weak var forgetPasswordLink: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("omg!")
        
        // Do any additional setup after loading the view.
    }

    @IBAction func forgetPasswordTapped(_ sender: UIButton) {
        print("normal button works")
    }

}




