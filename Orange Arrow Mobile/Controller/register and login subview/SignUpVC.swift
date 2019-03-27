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
import Firebase

//MARK -- protocol for send signal to superview conduct segue to next page
protocol SignUpViewControllerDelegate: class {
    func signUpBtnTapped()
}


class SignUpVC: UIViewController {
    
    weak var delegate: SignUpViewControllerDelegate?
    
    @IBOutlet weak var passwordTextfield: SkyFloatingLabelTextFieldWithIcon!
    @IBOutlet weak var emailTextfield: SkyFloatingLabelTextFieldWithIcon!
    @IBOutlet weak var repeatPasswordTextfield: SkyFloatingLabelTextFieldWithIcon!
    @IBOutlet weak var signupButton: LGButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //initialize the delegation for ui textfield
        passwordTextfield.delegate = self
        emailTextfield.delegate = self
        repeatPasswordTextfield.delegate = self
        
        //customize textfield
        passwordTextfield.textContentType = .password
        repeatPasswordTextfield.textContentType = .password
        emailTextfield.textContentType = .emailAddress
        passwordTextfield.isSecureTextEntry = true
        repeatPasswordTextfield.isSecureTextEntry = true
        emailTextfield.keyboardType = .emailAddress
        passwordTextfield.returnKeyType = .next
        emailTextfield.returnKeyType = .next
        repeatPasswordTextfield.returnKeyType = .done
        
        signupButton.addTarget(self, action: #selector(signupBtnTapped), for: .touchUpInside)
    }

    //MARK -- sign up button function
    @objc func signupBtnTapped() {
        
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
                guard let uid = Auth.auth().currentUser?.uid else {
                    return
                }
//                print("=============================\(uid)")
                
//                let userDictionary = ["First Name":"","Last Name":"","Email":"","Date of Birth":"","Gender":"","Sports":"","School":schoolInfo,"ProfileImageUrl":downloadURL,"Levels":[1,1,1,1]] as [String : Any]
                
//                let entryNode = Utilities.ref_db.child("UsersInfo")
//                entryNode.updateChildValues(values) { (error, ref) in
//                    if error != nil {
//                        print("user information can't be stored at firebase with error: \(error!)")
//                        return
//                    }
//                    print("additional user info was saved in firebase")
//                }
                
                Utilities.ref_db.child("abcd").setValue([uid:""])
                
                
                // go to next page to let user update their information
                self.delegate?.signUpBtnTapped()
                
            }
        }
    }
    
}

// TODO -- MAKE A FUNCTION TO TOUCH OTHER AREA AND DISMISS THE KEYBOARD

// MARK -- CUSTOM THE KEYBOARD RETURN KEY
extension SignUpVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextfield {
            passwordTextfield.becomeFirstResponder()
            return false
        }else if textField == passwordTextfield {
            repeatPasswordTextfield.becomeFirstResponder()
            return false
        }else if textField == repeatPasswordTextfield{
            repeatPasswordTextfield.resignFirstResponder()
            return false
        }
        return true
    }
}
