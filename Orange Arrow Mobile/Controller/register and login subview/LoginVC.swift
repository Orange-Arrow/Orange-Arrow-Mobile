//
//  LoginVC.swift
//  Orange Arrow Mobile
//
//  Created by 刘祥 on 3/6/19.
//  Copyright © 2019 xiangliu90. All rights reserved.
//

import UIKit
import LGButton
import Firebase
import SkyFloatingLabelTextField
import GoogleSignIn
import FacebookLogin
import FacebookCore


class LoginVC: UIViewController, GIDSignInUIDelegate, GIDSignInDelegate {
    
    @IBOutlet weak var forgetPasswordLink: UIButton!
    @IBOutlet weak var loginButton: LGButton!
    @IBOutlet weak var googleButton: LGButton!
    @IBOutlet weak var facebookButton: LGButton!
    
    @IBOutlet weak var emailTextfield: SkyFloatingLabelTextFieldWithIcon!
    @IBOutlet weak var passwordTextfield: SkyFloatingLabelTextFieldWithIcon!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //initialize the delegation for ui textfield
        passwordTextfield.delegate = self
        emailTextfield.delegate = self
        
        //customize textfield
        passwordTextfield.textContentType = .password
        emailTextfield.textContentType = .emailAddress
        passwordTextfield.isSecureTextEntry = true
        emailTextfield.keyboardType = .emailAddress
        passwordTextfield.returnKeyType = .done
        emailTextfield.returnKeyType = .next
        
        forgetPasswordLink.addTarget(self, action: #selector(forgetPasswordTapped), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(loginBtnTapped), for: .touchUpInside)
        googleButton.addTarget(self, action: #selector(googleBtnTapped), for: .touchUpInside)
        facebookButton.addTarget(self, action: #selector(facebookBtnTapped), for: .touchUpInside)
        // Do any additional setup after loading the view.
    }
    
    @objc func forgetPasswordTapped(){
        print("the forget button works")
    }
    
    @objc func loginBtnTapped(){
        print("the login button works")
        
        guard let email = emailTextfield.text else {return}
        guard let password = passwordTextfield.text else {return}
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if error != nil {
                print(error!.localizedDescription)
                return
            }
            // to do -- check user info if any of are empty then go to update info page otherwise goto menu page
            // should be done by super view
            print("user has been signed in")
        }
    }
    
    @objc func googleBtnTapped(){
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signIn()
    }
    
    //MARK:- Google Delegate
    func sign(inWillDispatch signIn: GIDSignIn!, error: Error!) {
    }
    
    func sign(_ signIn: GIDSignIn!,
              present viewController: UIViewController!) {
        self.present(viewController, animated: true, completion: nil)
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
                     withError error: Error!) {

//            // Perform any operations on signed in user here.
//            let userId = user.userID                  // For client-side use only!
//            let idToken = user.authentication.idToken // Safe to send to the server
//            let fullName = user.profile.name
//            let givenName = user.profile.givenName
//            let familyName = user.profile.familyName
//            let email = user.profile.email

        if let error = error {
            print("there is a error with google sign in \(error.localizedDescription)")
            return
        }
        
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        print("the credential is \(credential)")
        //sign in with firebase
        Auth.auth().signInAndRetrieveData(with: credential) { (authResult, error) in
            if let error = error {
                print("there is an error with firebase google sign in \(error.localizedDescription)")
                return
            }
            print("google user has signed in")
            //todo -- check current user has a complete user profile or not, if not then go to update if yes, then go to menu page
        }
    }
    
    //MARK -- FACEBOOK LOGIN BUTTON Clicked
    @objc func facebookBtnTapped(){
        print("the facebook button works")
        
        let loginManager = LoginManager()
        loginManager.logIn(readPermissions: [ReadPermission.publicProfile], viewController: self) { loginResult in
            switch loginResult {
            case .failed(let error):
                print(error)
            case .cancelled:
                print("User cancelled login.")
            case .success(let grantedPermissions, let declinedPermissions, let accessToken):
                print("Logged in!")
                //login into firebase
                let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.authenticationToken)
                Auth.auth().signInAndRetrieveData(with: credential) { (authResult, error) in
                    if let error = error {
                        print("there is an error with facebook login to firebase \(error)")
                        return
                    }
                    print("facebook user signed in")
                    //todo -- check user logged info
                }
            }
        }
    }
    
}


// MARK -- CUSTOM THE KEYBOARD RETURN KEY
extension LoginVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextfield {
            passwordTextfield.becomeFirstResponder()
            return false
        }else if textField == passwordTextfield{
            passwordTextfield.resignFirstResponder()
            return false
        }
        return true
    }
}

