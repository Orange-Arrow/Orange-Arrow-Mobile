//
//  TriviaVC.swift
//  Orange Arrow Mobile
//
//  Created by 刘祥 on 3/6/19.
//  Copyright © 2019 xiangliu90. All rights reserved.
//

import UIKit
import ProgressHUD

class TriviaVC: UIViewController {

    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var totalTimeLabel: UILabel!
    @IBOutlet weak var questionCounterLabel: UILabel!
    @IBOutlet weak var questionAreaLabel: UILabel!
    @IBOutlet var optionButtons: [UIButton]!
    @IBOutlet weak var originalBar: UIView!
    @IBOutlet weak var levelBar: UIView!
    @IBOutlet weak var gameBar: UIView!
    
    @IBOutlet weak var gameBarWidthCon: NSLayoutConstraint!
    @IBOutlet weak var levelBarWidthCon: NSLayoutConstraint!
    
    
    var currentLevel = 1
    var currentQuestionIndex = 0
    var points = 0
    var totalTime = 0
    var totalTimer = TimerOfGame()
    var pool = [Question]()
    var trivia : LoadingData?
    var audioController = AudioController()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Utilities.getLevel(num: 0) { (level) in
            self.currentLevel = level
            self.trivia = LoadingData(level: self.currentLevel, count: selectedCount, game: "trivia")
            
            guard let pools = self.trivia?.selectedPool else{return}
            self.pool = pools
            
            //update the UI
            self.updateQuestion()
            
        }

        
        audioController.preloadAudioEffects(effectFileNames: AudioEffectFiles)
        


        
        //update navigation bar
        let navItem = Utilities.setupNavigationBar(image: "icon_trivia", tappedFunc: #selector(backBtnTapped), handler: self)
        navigationBar.setItems([navItem], animated: false)
        
        totalTimer.startTimer(handler: self, selector: #selector(beginGame))

    }
    
    @objc func beginGame(){
        totalTimeLabel.text = "Time: \(Utilities.timeFormatted(totalTime))"
        totalTime += 1
    }
    
    @objc func backBtnTapped(){
        dismiss(animated: true, completion: nil)
        Utilities.changeStatusBarColor(color: UIColor(named: "oaColor")!)
        // the color looks so different tho???
    }
    
    //func to go to next level
    private func gotoNextStep(isSuccess:Bool){
        if isSuccess{
             self.trivia = LoadingData(level: self.currentLevel+1, count: selectedCount, game: "trivia")
            
        }else{
             self.trivia = LoadingData(level: self.currentLevel, count: selectedCount, game: "trivia")
            
        }
       
        guard let pools = trivia?.selectedPool else{return}
        self.pool = pools
        totalTime = 0
        totalTimer.startTimer(handler: self, selector: #selector(beginGame))
        points = 0
        currentQuestionIndex = 0
        updateQuestion()
        
    }
    private func goback(){
        dismiss(animated: true, completion: nil)
    }

    
    
    @IBAction func optionBtnTapped(_ sender: UIButton) {
        // to check if it is the last question
//        and if not, then check the result and update ui
        
        if currentQuestionIndex == pool.count-1{
            
            if sender.tag == pool[currentQuestionIndex].answer{
                self.points += 2
                pointsLabel.text = "Points: \(points)"
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    ProgressHUD.showSuccess("Awesome, Correct!")
                    self.audioController.playEffect(name: SoundDing)
                }
                
            }else{
                self.points -= 1
                pointsLabel.text = "Points: \(points)"
                let rightAnswer = pool[currentQuestionIndex].options[pool[currentQuestionIndex].answer]
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    ProgressHUD.showError("The correct answer is \n\(rightAnswer)")
                    self.audioController.playEffect(name: SoundWrong)
                    
                }
            }
                // stop the timer
                totalTimer.endTimer()
                guard let totaltime = totalTimeLabel.text else {return}


                
                //to check if it is over certain point
                if self.points >= pointsToPassTrivia {
                    // firt store the data
                    Utilities.storeResult(gameName: "Trivia", level: currentLevel, points: self.points, time: totaltime, gameIndictorNum: 0)
                    
                    //show alert about choice of next level or go back
                    Utilities.showSuccessAlert(level: currentLevel, points: points, gameTime: totaltime, targetVC: self, goback: goback){_ in 
                        self.gotoNextStep(isSuccess: true)
                    }
                }else{
                    //show alert
                    Utilities.showFailureAlert(level: currentLevel, points: points, gameTime: totaltime, targetVC: self, goback: goback){
                        _ in self.gotoNextStep(isSuccess: false)
                    }
                }

        }else{
            // check the result and update to next question
            if sender.tag == pool[currentQuestionIndex].answer{
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    ProgressHUD.showSuccess("Awesome, Correct!")
                    self.audioController.playEffect(name: SoundDing)
                    
                }
                
                self.points += 2
                self.currentQuestionIndex += 1
                
                pointsLabel.text = "Points: \(points)"
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self.updateQuestion()
                }
                
            }else{
                
                let rightAnswer = pool[currentQuestionIndex].options[pool[currentQuestionIndex].answer]
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    ProgressHUD.showError("The correct answer is \n\(rightAnswer)")
                    self.audioController.playEffect(name: SoundWrong)
                    
                }
                points -= 1
                currentQuestionIndex += 1
                
                pointsLabel.text = "Points: \(points)"
                DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                    self.updateQuestion()
                    
                }
            }
        }
        
    }
    
    
    func updateQuestion(){
        
        //update question
        questionCounterLabel.text = "Question \(currentQuestionIndex+1)"
        questionAreaLabel.lineBreakMode = .byWordWrapping
        questionAreaLabel.numberOfLines = 0
        
        //update the questions
        questionAreaLabel.text = pool[currentQuestionIndex].questText
        
        pointsLabel.text = "Points: \(self.points)"
        
        // update the options
        for (index,btn) in optionButtons.enumerated(){
            btn.titleLabel?.numberOfLines = 0
            btn.titleLabel?.lineBreakMode = .byWordWrapping
            btn.setTitle(pool[currentQuestionIndex].options[index], for: .normal)
        }
        // update the progress
        
        gameBarWidthCon.constant = (originalBar.frame.size.width / CGFloat(pool.count)) * CGFloat(currentQuestionIndex+1)
        gameBar.layoutIfNeeded()
        //update level .....

        levelBarWidthCon.constant = (originalBar.frame.size.width / CGFloat(10)) * CGFloat(currentLevel)
        levelBar.layoutIfNeeded()
        
    }
    
    


}
