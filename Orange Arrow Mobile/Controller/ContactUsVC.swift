//
//  ContactUsVC.swift
//  Orange Arrow Mobile
//
//  Created by 刘祥 on 3/6/19.
//  Copyright © 2019 xiangliu90. All rights reserved.
//

import UIKit
import MessageUI
import LGButton
import SkyFloatingLabelTextField
import ProgressHUD
import SafariServices
import Firebase

class ContactUsVC: UIViewController {

    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var titleTextfield: SkyFloatingLabelTextField!
    @IBOutlet weak var messageTextfield: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let statusBarView = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView else {
            return
        }
        statusBarView.backgroundColor = Utilities.hexStringToUIColor(hex: "FEC341")
        
        setupTextfieldDelegation()

        // Do any additional setup after loading the view.
        let navItem = Utilities.setupNavigationBar(image: "icon_setting", tappedFunc: #selector(backBtnTapped), handler: self)
        navigationBar.setItems([navItem], animated: false)
        navigationBar.barTintColor = Utilities.hexStringToUIColor(hex: "FEC341")
    }
    
    @objc func backBtnTapped(){
        dismiss(animated: true, completion: nil)
        Utilities.changeStatusBarColor(color: UIColor(named: "oaColor")!)
        // the color looks so different tho???
    }
    
    
    //MARK -- function when send message tapped
    @IBAction func sendMessBtnTapped(_ sender: LGButton) {
        // to check title and contents not nil
        if titleTextfield.text != "" && messageTextfield.text != ""{
            sendEmail(title: titleTextfield.text!, message: messageTextfield.text!)
        }
    }
    
    
    @IBAction func settingBtnTapped(_ sender: LGButton) {
        print("this is called")
        var url = "http://www.orangearrow.org"
        switch sender.tag{
        case 2: url += "/about-oa"
        case 3: url += "//oa-board"
        case 4: url += "/term"
        default: print("doing nothing")
        }

        if let url = URL(string: url) {
            let svc = SFSafariViewController(url: url)
            present(svc, animated: true, completion: nil)
        }
     
    }
    
    
    //mark -- to delete the user account
    @IBAction func deleteAccountTapped(_ sender: LGButton) {
        //show a alert to confirm
        //and if it is yes then delete
        //to start
        let message = "All of your information will be deleted. Are you sure to delete?"
        let alert = UIAlertController(title: "Alert!", message: message, preferredStyle: .alert)
        let nextLevelAction = UIAlertAction(title: "Yes", style: .default, handler: { (UIAlertAction) in self.deleteAccount() })
        let goBackAction = UIAlertAction(title: "No", style: .cancel, handler: { (UIAlertAction) in alert.dismiss(animated: true, completion: nil) })
        alert.addAction(nextLevelAction)
        alert.addAction(goBackAction)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    private func deleteAccount(){
        guard let userID = Auth.auth().currentUser?.uid else { fatalError("No User Sign In") }
        Utilities.ref_db.child("users_information").child(userID).setValue(nil)
        let gameName = ["Trivia","Puzzle","Word"]
        for name in gameName{
            for level in 1...totalLevelNum{
                Utilities.ref_db.child(name).child(String(level)).child(userID).setValue(nil)
            }
        }
        
        let user = Auth.auth().currentUser
        user?.delete { error in
            if let error = error {
                // An error happened.
                ProgressHUD.showError(error.localizedDescription)
            } else {
                // Account deleted.
                ProgressHUD.showSuccess("Your OA account has been deleted")
                self.dismiss(animated: true, completion: nil)
                //might have error here
            }
        }     
    }

}


extension ContactUsVC: MFMailComposeViewControllerDelegate{
    
    func sendEmail(title:String, message:String) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["xiang@orangearrow.org"])
            mail.setSubject("From OA App: \(title)")
            mail.setMessageBody("<p>\(message)<p>", isHTML: true)
            
            present(mail, animated: true)
        } else {
            // show failure alert
            print("user didnt setup email association")
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        titleTextfield.text = ""
        messageTextfield.text = ""
        controller.dismiss(animated: true)
        // empty the textfield
        ProgressHUD.showSuccess()
        
    }
}


extension ContactUsVC: UITextFieldDelegate, UITextViewDelegate {
    
    func setupTextfieldDelegation() {
        titleTextfield.delegate = self
        messageTextfield.delegate = self
        titleTextfield.returnKeyType = .next
        messageTextfield.returnKeyType = .done
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            messageTextfield.becomeFirstResponder()
            return false
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}
