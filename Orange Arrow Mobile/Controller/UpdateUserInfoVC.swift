//
//  UpdateProfileVC.swift
//  Orange Arrow Mobile
//
//  Created by 刘祥 on 3/6/19.
//  Copyright © 2019 xiangliu90. All rights reserved.
//

import UIKit
import LGButton
import SkyFloatingLabelTextField
import Firebase
import FSCalendar

class UpdateUserInfoVC: UIViewController {
    
    fileprivate weak var calendar: FSCalendar!

    @IBOutlet weak var imageButton: UIButton!
    @IBOutlet weak var firstNameTextfield: SkyFloatingLabelTextField!
    @IBOutlet weak var lastNameTextfield: SkyFloatingLabelTextField!
    @IBOutlet var genderButtonGroup: [UIButton]!
    @IBOutlet weak var birthDateTextfield: SkyFloatingLabelTextField!
    @IBOutlet weak var schoolTextfield: SkyFloatingLabelTextFieldWithIcon!
    @IBOutlet weak var sportsTextfield: SkyFloatingLabelTextField!
    
    let imagePicker = UIImagePickerController()
    
    var schoolPickerView : UIPickerView!
    var sportsPickerView : UIPickerView!
    let schoolData = ["Arsenal 6-8" , "Arsenal K5" , "FAU" , "Liberty","Miami","Pitt","Robert Morris","Sci-Tech","South Brook"]
    let sportsData = ["Archery", "Auto Racing", "Baseball", "Basketball", "Fencing", "Football", "Golf", "Gymnastics", "Hockey", "Lacrosse", "Soccer", "Softball", "Swimming & Diving", "Tennis", "Track & Field", "Volleyball", "Water Polo", "Wrestling"]
    var gender = "boy"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //delegation for calendar view
         genderButtonGroup[0].backgroundColor = Utilities.hexStringToUIColor(hex: "D6D6D6")
        
        
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        
        setupTextfieldDelegation()
        
        for genderImg in genderButtonGroup{
            genderImg.imageView?.contentMode = .scaleAspectFit
        }
        imageButton.imageView?.contentMode = .scaleAspectFill
 
        // Do any additional setup after loading the view.
        
        
        
//        first to check if anything on database and put it on display
    }
    
    // TODO -- user clicked update profile button
    @IBAction func updateBtnTapped(_ sender: LGButton) {
    }
    // TODO -- User click button to update profile image
    @IBAction func imageBtnTapped(_ sender: UIButton) {
        present(imagePicker, animated: true, completion: nil)
    }
    // MARK -- user click the gender button
    @IBAction func genderBtnClicked(_ sender: UIButton) {
            for btn in genderButtonGroup{
                if btn.tag == sender.tag{
                    gender = btn.title(for: .selected)!
                    btn.backgroundColor = Utilities.hexStringToUIColor(hex: "D6D6D6")
                   
                }else{
                    btn.backgroundColor = nil
                }
            }
    }
    
    
    // MARK - TextField Delegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.tag == 3{
            pickUp(schoolTextfield)
        }else if textField.tag == 2{
            //calendar
            showCalendar(birthDateTextfield)
        }else if textField.tag == 4{
            pickUp(sportsTextfield)
        }
    }
    
    
    private func registerUserInfoWithUID(uid: String, values: [String: AnyObject]){
        
        let userDB = Utilities.ref_db.child("users_information").child(uid)
        userDB.updateChildValues(values) { (error, ref) in
            if error != nil {
                print("user information can't be stored at firebase with error: \(error!)")
                return
            }
            print("additional user info was saved in firebase")
            // goto menu
            self.gotoMenu()
           
        }
    }
    
    private func gotoMenu(){
//         dismiss(animated: true, completion: nil)
        performSegue(withIdentifier: "updateToNavigationSegue", sender: self)
       
    }
    
    
    //MARK -- func to update profile
    @IBAction func updateProfileBtnTapped(_ sender: LGButton) {
        // to check every value is not nil
        guard let firstName = firstNameTextfield.text else{return}
        guard let lastName = lastNameTextfield.text else{return}
        guard let dateOfBirth = birthDateTextfield.text else{return}
        guard let school = schoolTextfield.text else{return}
        guard let sports = sportsTextfield.text else{return}
        
        // initialize the time badge array
        var badgeOfTime = [Bool]()
        for _ in 1...totalLevelNum{
            badgeOfTime.append(false)
        }
        
        //to update database
//         TODO: store profile img to storage
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        let imageName = NSUUID().uuidString
        let storageRef = Storage.storage().reference().child("\(imageName).png")
        
        if let uploadData = imageButton.imageView!.image!.pngData(){
            storageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                if error != nil {
                    print("Upload Image Error with reason \(error!.localizedDescription)")
                    return
                }
                
                storageRef.downloadURL(completion: { (url,error) in
                    guard let downloadURL = url?.absoluteString else{
                        print("there is a download url error \(error!.localizedDescription)")
                        return
                    }
                    
                    let userDictionary = ["First Name":firstName,"Last Name":lastName,"Birthday":dateOfBirth,"Gender":self.gender,"Sports":sports,"School":school,"ProfileImageUrl":downloadURL,"Levels":[1,1,1], "BadgesOfTime":["trivia":badgeOfTime, "puzzle":badgeOfTime, "words":badgeOfTime]] as [String : Any]
                    
                    self.registerUserInfoWithUID(uid:uid, values:userDictionary as [String : AnyObject])
                    
                })
            })
        }
    }
    // end of btn func 
    
    
    
}


// MARK -- extension for the birth of date calendar
extension UpdateUserInfoVC: FSCalendarDataSource, FSCalendarDelegate{
    func showCalendar(_ textfield:UITextField){
        let calendar = FSCalendar(frame: CGRect(x: 0, y: 0, width: 320, height: 300))
        calendar.dataSource = self
        calendar.delegate = self
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let initialDate = formatter.date(from: "2010-01-01")

        if let initial = initialDate{
            calendar.currentPage = initial
        }
       
        textfield.inputView = calendar
//        view.addSubview(calendar)
        self.calendar = calendar
        
    }
    
    // MARK -- set the auto layout
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        calendar.heightAnchor.constraint(equalToConstant: bounds.height)
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateStr = formatter.string(from: date)
        print("the selected date is \(dateStr)")
        birthDateTextfield.text = dateStr
        self.view.endEditing(true)
    }
}


// MARK -- extension for image view picker delegation
extension UpdateUserInfoVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // MARK - DELEGATE FOR IMAGE PICKER
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let pickedImage = info[.editedImage] as? UIImage{
            imageButton.setImage(pickedImage, for: .normal)
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
}


// extension for the pickview delegation
extension UpdateUserInfoVC: UIPickerViewDelegate, UIPickerViewDataSource{
    
    // MARK - FUNCTION TO CREATE UIPickerView with ToolBar
    func pickUp(_ textField : UITextField){
        
        // UIPickerView
        if textField.tag == 3{
            schoolPickerView = UIPickerView(frame:CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 216))
            schoolPickerView.delegate = self
            schoolPickerView.dataSource = self
            schoolPickerView.backgroundColor = UIColor.white
            textField.inputView = self.schoolPickerView
            if textField.text == nil || textField.text == ""{
                textField.text = schoolData[0]
            }

            
        }else if textField.tag == 4{
            sportsPickerView = UIPickerView(frame:CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 216))
            sportsPickerView.delegate = self
            sportsPickerView.dataSource = self
            sportsPickerView.backgroundColor = UIColor.white
            textField.inputView = self.sportsPickerView
            if textField.text == nil || textField.text == ""{
               textField.text = sportsData[0]
            }
            
        }

        
        // ToolBar
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 92/255, green: 216/255, blue: 255/255, alpha: 1)
        toolBar.sizeToFit()
        
        // Adding Button ToolBar
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneClick))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelClick(textField:)))
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        textField.inputAccessoryView = toolBar
        
    }
    
    // MARK - DATA SOURCE METHOD OF PICKERVIEW
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == schoolPickerView{
                return schoolData.count
        }else if pickerView == sportsPickerView{
            return sportsData.count
        }else{
            return -1
        }
    
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == schoolPickerView{
            return schoolData[row]
        }else if pickerView == sportsPickerView{
            return sportsData[row]
        }else{
            return ""
        }
    
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if pickerView == schoolPickerView{
            schoolTextfield.text = schoolData[row]
        }else if pickerView == sportsPickerView{
            sportsTextfield.text = sportsData[row]
        }
    }
    
    // - MARK - FUNCTIONS FOR TOOLBAR BUTTON
    @objc func doneClick(textField: UITextField) {
        self.view.endEditing(true)
    }
    @objc func cancelClick(textField: UITextField) {
//        https://stackoverflow.com/questions/31728680/how-to-make-an-uipickerview-with-a-done-button
        self.view.endEditing(true)
    }
    
}


extension UpdateUserInfoVC: UITextFieldDelegate {
    
    func setupTextfieldDelegation() {
        schoolTextfield.delegate = self
        sportsTextfield.delegate = self
        birthDateTextfield.delegate = self
        firstNameTextfield.delegate = self
        lastNameTextfield.delegate = self
        firstNameTextfield.returnKeyType = .next
        lastNameTextfield.returnKeyType = .done
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == firstNameTextfield {
            lastNameTextfield.becomeFirstResponder()
            return false
        }else{
            textField.resignFirstResponder()
            return false
        }
    }
}
