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

class ContactUsVC: UIViewController {

    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var titleTextfield: SkyFloatingLabelTextField!
    @IBOutlet weak var messageTextfield: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTextfieldDelegation()

        // Do any additional setup after loading the view.
        let navItem = Utilities.setupNavigationBar(image: "icon_setting", tappedFunc: #selector(backBtnTapped), handler: self)
        navigationBar.setItems([navItem], animated: false)
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
