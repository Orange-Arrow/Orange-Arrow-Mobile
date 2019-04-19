//
//  ImagePuzzleVC.swift
//  Orange Arrow Mobile
//
//  Created by 刘祥 on 3/6/19.
//  Copyright © 2019 xiangliu90. All rights reserved.
//

import UIKit
import ProgressHUD

class ImagePuzzleVC: UIViewController {
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var realImage: UIImageView!
    @IBOutlet var optionsButtons: [UIButton]!
    @IBOutlet var puzzleButtons: [UIButton]!
    @IBOutlet weak var progressBar: UIView!
    @IBOutlet weak var levelViewBar: UIView!
    
    @IBOutlet weak var progressBarWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var levelBarWidthConstraint: NSLayoutConstraint!
    
    //to update the level val
    var currentLevel = 1 {
        willSet(newValue){
            levelLabel.fadeTransition(0.5)
            levelLabel.text = "Level \(newValue)"
        }
    }
    
    var puzzle : LoadingData?
    var currentQuesIndex = 0
    var pool = [Question]()
    var points = 0{
        willSet(newValue){
            pointsLabel.fadeTransition(0.5)
            pointsLabel.text = "Points: \(newValue)"
        }
    }
    private var audioController = AudioController()
    //stopwatch variables
    private var secondsLeft = 10
    private var leftTimer = TimerOfGame()
//    var originalBarWidth : CGFloat = 0.0
    private var totalTimer = TimerOfGame()
    private var totalTime = 0

    @IBOutlet weak var originalBar: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Utilities.getLevel(num: 1) { (level) in
            self.currentLevel = level
            print("the current level is \(self.currentLevel)")
            self.puzzle = LoadingData(level: self.currentLevel, count: selectedCount, game: "puzzle")
            
            guard let pools = self.puzzle?.selectedPool else{return}
            self.pool = pools
            
            //update the UI
            self.updateQuestion()
            
        }
        
        
        audioController.preloadAudioEffects(effectFileNames: AudioEffectFiles)
        
        // Do any additional setup after loading the view.
        let navItem = Utilities.setupNavigationBar(image: "icon_puzzle", tappedFunc: #selector(backBtnTapped), handler: self)
        navigationBar.setItems([navItem], animated: false)
        
        // set up the timer
        totalTimer.startTimer(handler: self, selector: #selector(beginGame))
    }
    
    @objc func beginGame(){
        timeLabel.fadeTransition(0.5)
            timeLabel.text = "Time: \(Utilities.timeFormatted(totalTime))"
        
        totalTime += 1
    }

    
    @objc func backBtnTapped(){
        
        if leftTimer.countdownTimer != nil{
            leftTimer.endTimer()
            ProgressHUD.dismiss()
            totalTimer.endTimer()
        }

        
        dismiss(animated: true, completion: nil)
        Utilities.changeStatusBarColor(color: UIColor(named: "oaColor")!)
        // the color looks so different tho???

    
    }
    
    
    //func to go to next level
    private func gotoNextStep(isSuccess:Bool){
        if isSuccess{
            self.currentLevel += 1
            self.puzzle = LoadingData(level: self.currentLevel, count: selectedCount, game: "puzzle")
            
        }else{
            self.puzzle = LoadingData(level: self.currentLevel, count: selectedCount, game: "puzzle")
            
        }
        
        guard let pools = puzzle?.selectedPool else{return}
        self.pool = pools
        totalTime = 0
        totalTimer.startTimer(handler: self, selector: #selector(beginGame))
        points = 0
        currentQuesIndex = 0
        secondsLeft = 0
        
        updateQuestion()
        
    }
    private func goback(){
        if leftTimer.countdownTimer != nil{
            leftTimer.endTimer()
            ProgressHUD.dismiss()
            totalTimer.endTimer()
        }
        dismiss(animated: true, completion: nil)
    }
    
    
    
    
    //update questions and ui
    func updateQuestion(){
        
        
        //update the start timer
        secondsLeft = 10
        //update the mask pic which is button image
        let imagePool = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18].choose(9)
        print("the pool is \(imagePool)")
        var index = 0
        for singleBtn in puzzleButtons{
            
            singleBtn.layer.borderWidth = 1
            singleBtn.layer.borderColor = UIColor.black.cgColor
            
            let randomName = "ppl\(imagePool[index]).jpg"
            index += 1
            singleBtn.setBackgroundImage(UIImage(named: randomName), for:.normal)
            singleBtn.imageView?.contentMode = .scaleAspectFill
            
            //make sure then can be clicked
            singleBtn.isUserInteractionEnabled = true
        }
        
        //update the real image
        realImage.contentMode = .scaleAspectFill
        realImage.clipsToBounds = true
        realImage.image = UIImage(named: "\(pool[currentQuesIndex].questText).jpg")
        
        
        // update the options
        for (index,btn) in optionsButtons.enumerated(){
            btn.fadeTransition(0.5)
            btn.setTitle(pool[currentQuesIndex].options[index], for: .normal)
        }
        // update the progress
        
        progressBarWidthConstraint.constant = (originalBar.frame.size.width / CGFloat(pool.count)) * CGFloat(currentQuesIndex+1)
        progressBar.layoutIfNeeded()
        //update level .....
        //image current total level is 10
        levelBarWidthConstraint.constant = (originalBar.frame.size.width / CGFloat(10)) * CGFloat(currentLevel)
        levelViewBar.layoutIfNeeded()
        
    }
    
    
    //MARK -- PUZZLE buttons is tapped
    @IBAction func puzzleBtnsTapped(_ sender: UIButton) {
        // to make the button back image as nil and background as clear
        sender.setBackgroundImage(nil, for: .normal)
        for btn in puzzleButtons{
            btn.isUserInteractionEnabled = false
        }
        //every time after update question we should count the timer for next time able to reveal image
        leftTimer.startTimer(handler: self, selector: #selector(leftTime))
//        addCountDownTimerView()
     
        
    }
    
  
    

    
    // MARK -- update the timer for the game
    @objc func leftTime() {
        ProgressHUD.spinnerColor(.orange)
        ProgressHUD.show(" \(secondsLeft) seconds to click & reveal another piece")
        print("the timer funciton was executed with seconds left \(secondsLeft)")
        secondsLeft -= 1
        // update the left time ui
//        countDownTimerLabel!.setSeconds(seconds: secondsLeft)
        if secondsLeft == 0{
//            set the button to be able to tapped
            for btn in puzzleButtons{
                print("the code here to active image buttons")
                btn.isUserInteractionEnabled = true
            }
            // dismiss the label view
            ProgressHUD.dismiss()
            //set the seconds left back to original
            secondsLeft = 10
            leftTimer.endTimer()
        }
    }
    
    
    
    //MARK --  the func for detect if buttons is touched
    @IBAction func optionsBtnTouched(_ sender: UIButton) {
        
        if leftTimer.countdownTimer != nil{
            leftTimer.endTimer()
            ProgressHUD.dismiss()
        }

        
        // to check if it is the last question
        
        if currentQuesIndex == pool.count-1{
            // check the result and calculate the result and do the alerts
            
            if sender.tag == pool[currentQuesIndex].answer{
                self.points += 2
                pointsLabel.text = "Points: \(points)"
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    ProgressHUD.showSuccess("Awesome, Correct!")
                    self.audioController.playEffect(name: SoundDing)
                }
                
            }else{
                self.points -= 1
                pointsLabel.text = "Points: \(points)"
                let rightAnswer = pool[currentQuesIndex].options[pool[currentQuesIndex].answer]
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    ProgressHUD.showError("The correct answer is \n\(rightAnswer)")
                    self.audioController.playEffect(name: SoundWrong)
                    
                }
            }
            // stop the timer
            totalTimer.endTimer()
            // end left timer
//            guard let totaltime = timeLabel.text else {return}
            
            //to check if it is over certain point
            if self.points >= pointsToPassPuzzle {
                
                // to see if good for badge of time
                // to check time is smaller than
                let targetTime = Utilities.getTargetForBadge(gameName: "puzzle", level: self.currentLevel, measure:"badgeOfTime")
                let targetPoints = Utilities.getTargetForBadge(gameName: "puzzle", level: self.currentLevel, measure: "badgeOfPoints")
                
                if self.totalTime <= targetTime{
                    // you can earn the badge
                    Utilities.updateBadgeInFirebase(level: self.currentLevel, gameName: "puzzle", measure: "BadgeOfTime")
                    
                }
                if self.points >= targetPoints{
                    Utilities.updateBadgeInFirebase(level: self.currentLevel, gameName: "puzzle", measure: "BadgeOfPoints")
                }
                
                // firt store the data
                Utilities.storeResult(gameName: "Puzzle", level: currentLevel, points: self.points, time: totalTime, gameIndictorNum: 1)
                //show alert about choice of next level or go back
                Utilities.showSuccessAlert(level: currentLevel, points: points, gameTime: totalTime, targetVC: self, goback: goback){_ in
                    self.gotoNextStep(isSuccess: true)
                }
             
                

            }else{
                //show alert
                Utilities.showFailureAlert(level: currentLevel, points: points, gameTime: totalTime, targetVC: self, goback: goback){
                    _ in self.gotoNextStep(isSuccess: false)
                }
            }
            
            // so this will be last question should calculate the
//            accuracy to see if pass 90% and if so then ask say congrats and give optiion to
//            goto next level or cancel to back to main page
        }else{
            // check the result and update to next question
            if sender.tag == pool[currentQuesIndex].answer{

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    ProgressHUD.showSuccess("Awesome, Correct!")
                    self.audioController.playEffect(name: SoundDing)
                    
                }
                
                self.points += 2
                self.currentQuesIndex += 1
                
                pointsLabel.text = "Points: \(points)"
                
                //                sender.backgroundColor = .green
                //update to next question and grades
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self.updateQuestion()
                    
                }
                
            }else{
                
                let rightAnswer = pool[currentQuesIndex].options[pool[currentQuesIndex].answer]
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                ProgressHUD.showError("The correct star is \(rightAnswer)")
                    self.audioController.playEffect(name: SoundWrong)
                    
                }
                //                sender.backgroundColor = .red
                points -= 1
                currentQuesIndex += 1
                
                pointsLabel.text = "Points: \(points)"
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self.updateQuestion()
                    
                }
            }
            
        }
        
    }
    
    
    
}
