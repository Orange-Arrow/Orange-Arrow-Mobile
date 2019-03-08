//
//  SignUpVC.swift
//  Orange Arrow Mobile
//
//  Created by 刘祥 on 3/6/19.
//  Copyright © 2019 xiangliu90. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import LGButton
//import FontAwesome_swift
import Firebase

class SignUpVC: UIViewController {
    
    @IBOutlet weak var passwordTextfield: SkyFloatingLabelTextFieldWithIcon!
    @IBOutlet weak var emailTextfield: SkyFloatingLabelTextFieldWithIcon!
    @IBOutlet weak var repeatPasswordTextfield: SkyFloatingLabelTextFieldWithIcon!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("this is sign up")
    }

    @IBAction func signupBtnTapped(_ sender: LGButton) {
        
        print("the button was tapped")
        
        //to check if password is same and login
        guard let password = passwordTextfield.text else{return}
        guard let repeatPassword = repeatPasswordTextfield.text else{return}
        if password == repeatPassword {
            guard let email = emailTextfield.text else { return }
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if error != nil{
                    print("there is an error with firebase signup \(error!)")
                    return
                }
                // create user info node on database
                // go to next page to let user update their information
                self.performSegue(withIdentifier: "signupToUpdateinfoSegue", sender: self)
            }
        }
        
        
    }
    
}
