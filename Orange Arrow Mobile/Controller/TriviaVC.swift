//
//  TriviaVC.swift
//  Orange Arrow Mobile
//
//  Created by 刘祥 on 3/6/19.
//  Copyright © 2019 xiangliu90. All rights reserved.
//

import UIKit

class TriviaVC: UIViewController {

    @IBOutlet weak var navigationBar: UINavigationBar!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let navItem = Utilities.setupNavigationBar(image: "icon_trivia", tappedFunc: #selector(backBtnTapped), handler: self)
        navigationBar.setItems([navItem], animated: false)
        // Do any additional setup after loading the view.
    }
    
    @objc func backBtnTapped(){
        dismiss(animated: true, completion: nil)
        Utilities.changeStatusBarColor(color: UIColor(named: "oaColor")!)
        // the color looks so different tho???
    }


}
