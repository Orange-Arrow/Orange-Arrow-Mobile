//
//  WordScrambleVC.swift
//  Orange Arrow Mobile
//
//  Created by 刘祥 on 3/6/19.
//  Copyright © 2019 xiangliu90. All rights reserved.
//

import UIKit
import Firebase
import ProgressHUD

class WordScrambleVC: UIViewController {
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var hintImageView: UIImageView!
    @IBOutlet weak var levelProgressBar: UIView!
    @IBOutlet weak var gamePorgressBar: UIView!
    @IBOutlet weak var gameView: UIView!
    @IBOutlet weak var originalBar: UIView!
    @IBOutlet weak var levelBar: UIView!
    @IBOutlet weak var gameBar: UIView!
    
    @IBOutlet weak var levelBarLabel: UILabel!
    @IBOutlet weak var gameBarLabel: UILabel!
    @IBOutlet weak var gameBarCon: NSLayoutConstraint!
    @IBOutlet weak var levelBarCon: NSLayoutConstraint!
    
    var timeToBeWrong = 0
    var originalLocationTiles = [CGPoint]()

    var questions : WordScramble?
    var currentLevel : Int = 1 {
        willSet(newVal){
            levelLabel.text = "Level \(newVal)"
            levelBarCon.constant = (originalBar.frame.size.width / CGFloat(totalLevelNum)) * CGFloat(currentLevel)
            levelBar.layoutIfNeeded()
        }
    }
    
    private var tiles = [TileView]()
    private var targets = [TargetView]()
    
    let TileMargin: CGFloat = 10.0
    
    var shuffedSelectedQues: [NSDictionary]?
    var currentNumberOfQuestion = 0 {
        willSet(newVal){
//            gameBarLabel.text = "Game Progress: \(newVal+1)"
//            gameBarCon.constant = (originalBar.frame.size.width / CGFloat(shuffedSelectedQues!.count)) * CGFloat(newVal+1)
//            gameBar.layoutIfNeeded()
            self.updateGameBar(index: newVal)
        }
    }
    
    var hud:HUDView! {
        didSet {
            //connect the Hint button
            hud.hintButton.addTarget(self, action: #selector(actionHint), for:.touchUpInside)
            hud.hintButton.isEnabled = false
        }
    }
    
    //set up timer
    var countdownTimer = TimerOfGame()
    var initialTime = 0
    //stopwatch variables
    private var secondsLeft = 60
    private var leftTimer = TimerOfGame()
    
    // can be changed
//    private var data = GameData()
    var points = 0{
        willSet(newVal){
            pointsLabel.text = "Points: \(newVal)"
        }
    }
    
    private var endValue: Int = 0
    private var timer: Timer? = nil
    
    private var audioController = AudioController()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //set up the audio effect
        guard let statusBarView = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView else {
            return
        }
        statusBarView.backgroundColor = Utilities.hexStringToUIColor(hex: "FEC341")
        
        audioController.preloadAudioEffects(effectFileNames: AudioEffectFiles)
        
        //start to count the time
        countdownTimer.startTimer(handler: self, selector: #selector(updateTime))
        
        // update navigation bar
        let navItem = Utilities.setupNavigationBar(image: "icon_word", tappedFunc: #selector(backBtnTapped), handler: self)
        navigationBar.setItems([navItem], animated: false)
        navigationBar.barTintColor = Utilities.hexStringToUIColor(hex: "FEC341")
        
        //get the current level and update the level first
        Utilities.getLevel(num: 2) { (level) in
            self.currentLevel = level
            self.questions = WordScramble(level: self.currentLevel)
            if let questions = self.questions{
                let firstEle = questions.contentPool.list[0] as NSDictionary
                print(firstEle["hint"] as! String)
                // to make the questions shuffed and selected
                let pool = questions.contentPool.list
                assert(pool.count > 0, "no level loaded")
                self.shuffedSelectedQues = pool.choose(questions.selectedLevelForEachLevel)
                //add one view for all hud and controls
                self.addLetterBox(currentQuest: self.currentNumberOfQuestion, completion: self.addHUDView)
                
                //update gameBar
                self.updateGameBar(index: self.currentNumberOfQuestion)

                //start the timer
                self.startStopwatch()
                

                
            }else{
                print("this is wrong")
            }
        }
    }
    
    func updateGameBar(index:Int){
       
        gameBarLabel.text = "Game Progress: \(index+1)"
        gameBarCon.constant = (originalBar.frame.size.width / CGFloat(shuffedSelectedQues!.count)) * CGFloat(index+1)
        gameBar.layoutIfNeeded()
    }
    
    // MARK -- update the timer for the game
    @objc func updateTime() {
    
        timeLabel.text = "Time: \(Utilities.timeFormatted(initialTime))"
        initialTime += 1
    }
    //MARK -- navigation bar back button
    @objc func backBtnTapped(){
        ProgressHUD.dismiss()
        self.leftTimer.endTimer()
        self.countdownTimer.endTimer()
     
        
        dismiss(animated: true, completion: nil)
        Utilities.changeStatusBarColor(color: UIColor(named: "oaColor")!)
        // the color looks so different tho???
        
    }
    // MARK -- Add the hud view which contains the left timer, hint button
    func addHUDView(){
        let hudView = HUDView(frame: CGRect(x: gameView.bounds.origin.x, y: gameView.bounds.origin.y, width: gameView.bounds.size.width, height: gameView.bounds.size.height))
        gameView.addSubview(hudView)
        self.hud = hudView
        hud.hintButton.isEnabled = true
    }
    
    // MARK -- func for hint button
    //the user pressed the hint button
    @objc func actionHint() {
        // user can only click hint button once
        hud.hintButton.isEnabled = false
        
        //3 find the first unmatched target and matching tile
        var foundTarget:TargetView? = nil
        for target in targets {
            if !target.isMatched {
                foundTarget = target
                break
            }
        }
        //4 find the first tile matching the target
        var foundTile:TileView? = nil
        for tile in tiles {
            if !tile.isMatched && tile.letter == foundTarget?.letter {
                foundTile = tile
                break
            }
        }
        //ensure there is a matching tile and target
        if let target = foundTarget, let tile = foundTile {
            
            //5 don't want the tile sliding under other tiles
            gameView.bringSubviewToFront(tile)
            //6 show the animation to the user
            UIView.animate(withDuration: 1.5,
                           delay:0.0,
                           options:UIView.AnimationOptions.curveEaseOut,
                           animations:{
                            tile.center = target.center
            }, completion: {
                (value:Bool) in
                //7 adjust view on spot
                self.placeTile(tileView: tile, targetView: target)
                
                //9 check for finished game
                for tileview in self.tiles{
                    if tileview.isUserInteractionEnabled == true{
                        return
                    }
                }
                //all tile view are placed
                self.checkForSuccess()
            })
        }
    }
    
    // MARK --  to add the letter in the guessing area
    func addLetterBox (currentQuest : Int, completion:()->()) {
        
        guard let queue = shuffedSelectedQues else {return}
        let hint = queue[currentQuest]["hint"] as! String
//        print("the hint is \(hint)")
        // update the image of hint
        hintImageView.fadeTransition(0.5)
        hintImageView.image = UIImage(named: "\(hint).jpg")
        hintImageView.contentMode = .scaleToFill
        hintImageView.clipsToBounds = true
        
        let word = queue[currentQuest]["word"] as! String
        var shuffedword = word.shuffled()
        var joined = String(shuffedword)
        let length = word.count
        // to check shuffed is not exactly same to original
        while joined == word{
            shuffedword = word.shuffled()
            joined = String(shuffedword)
        }
        
        //calculate the tile size
        let tileSide = ceil(gameView.bounds.size.width * 0.8 / CGFloat(length)) - TileMargin
        //get the left margin for first tile
        var xOffset = (gameView.bounds.size.width - CGFloat(length) * (tileSide + TileMargin)) / 2.0
        //adjust for tile center (instead of the tile's origin)
        xOffset += tileSide / 2.0
        
        //1 initialize tile list
        tiles = []
        //2 create tiles
        for (index, letter) in shuffedword.enumerated() {
            //3
            if letter != " " {
                let tile = TileView(letter: letter, sideLength: tileSide, index:index)
                tile.randomize()
                tile.dragDelegate = self
                tile.center = CGPoint(x:xOffset + CGFloat(index)*(tileSide + TileMargin), y:gameView.bounds.size.height - 10.0 - tileSide/2)
                originalLocationTiles.append(tile.center)
                //4
                gameView.addSubview(tile)
                tiles.append(tile)
            }
        }
        
        //initialize target list
        targets = []
        //create targets
        for (index, letter) in word.enumerated() {
            if letter != " " {
                let target = TargetView(letter: letter, sideLength: tileSide)
                target.center = CGPoint(x:xOffset + CGFloat(index)*(tileSide + TileMargin), y:100)
                gameView.addSubview(target)
                targets.append(target)
            }
        }
        
        completion()
    }
    
    
    func checkIfLastQuestion(){
        if self.currentNumberOfQuestion == self.shuffedSelectedQues!.count-1{
            self.clearBoard()
            //this is last question
            //to check the points
            self.countdownTimer.endTimer()
            if self.points >= pointsToPassScramble{
                
                // to see if good for badge of time and points
                let targetTime = Utilities.getTargetForBadge(gameName: "words", level: self.currentLevel, measure:"badgeOfTime")
                let targetPoints = Utilities.getTargetForBadge(gameName: "words", level: self.currentLevel, measure: "badgeOfPoints")
                
                if self.initialTime <= targetTime{
                    // you can earn the badge
                    Utilities.updateBadgeInFirebase(level: self.currentLevel, gameName: "words", measure: "BadgeOfTime")
                    
                }
                if self.points >= targetPoints{
                    Utilities.updateBadgeInFirebase(level: self.currentLevel, gameName: "words", measure: "BadgeOfPoints")
                }
                
                // firt store the data
                Utilities.storeResult(gameName: "Word", level: self.currentLevel, points: self.points, time: self.initialTime, gameIndictorNum: 2)
                //show alert about choice of next level or go back
                Utilities.showSuccessAlert(level: self.currentLevel, points: self.points, gameTime: self.initialTime, targetVC: self, goback: self.goback){_ in
                    self.gotoNextStep(isSuccess: true)
                }
                
            }else{
                // didnt pass the level
                Utilities.showFailureAlert(level: self.currentLevel, points: self.points, gameTime: self.initialTime, targetVC: self, goback: self.goback){
                    _ in self.gotoNextStep(isSuccess: false)
                }
            }
            
        }else{
            //just go to next question
            self.clearBoard()
            
            self.currentNumberOfQuestion += 1
            self.originalLocationTiles.removeAll()
            self.addLetterBox(currentQuest: self.currentNumberOfQuestion, completion: self.addHUDView)
            self.secondsLeft = 60
            self.startStopwatch()
            self.timeToBeWrong = 0
            
        }
        
    }
    
    //MARK -- to check if the word is right
    func checkForSuccess() {
        for targetView in targets {
            //no success, bail out
            if !targetView.isMatched {
                //this is not right should lower the points
//                print("this is wrong")
//                leftTimer.endTimer()
//                self.clearBoard()
//                self.points-=1
//                ProgressHUD.showError("this is wrong")
//                checkIfLastQuestion()
                return
            }
        }
        print("Game Over!")
        //stop the stopwatch
        leftTimer.endTimer()
        //the anagram is completed!
        audioController.playEffect(name: SoundWin)
        // win animation
        let firstTarget = targets[0]
        let startX:CGFloat = 0
        let endX:CGFloat = gameView.bounds.size.width + 300
        let startY = firstTarget.center.y
        
        let stars = StardustView(frame: CGRect(x:startX, y:startY, width:10, height:10))
        gameView.addSubview(stars)
        gameView.sendSubviewToBack(stars)
        
        UIView.animate(withDuration: 3.0,
                       delay:0.0,
                       options:UIView.AnimationOptions.curveEaseOut,
                       animations:{
                        
                        stars.center = CGPoint(x:endX, y:startY)
        }, completion: {(value:Bool) in
            //game finished
            stars.removeFromSuperview()
            // to clear current board
            self.clearBoard()
            //goto next question
            // here should first check if the index is last question
            self.points+=2
            ProgressHUD.showSuccess("Correct!")
            
            self.checkIfLastQuestion()
        })
  
    }
    
    //func to go to next level
    private func gotoNextStep(isSuccess:Bool){
        if isSuccess{
            self.currentLevel += 1
        }
        self.questions = WordScramble(level: self.currentLevel)
        if let questions = self.questions{
            let firstEle = questions.contentPool.list[0] as NSDictionary
            print(firstEle["hint"] as! String)
            // to make the questions shuffed and selected
            let pool = questions.contentPool.list
            assert(pool.count > 0, "no level loaded")
            self.shuffedSelectedQues = pool.choose(questions.selectedLevelForEachLevel)
            self.initialTime = 0
            self.countdownTimer.startTimer(handler: self, selector: #selector(updateTime))
            self.points = 0
            self.secondsLeft = 60
            self.currentNumberOfQuestion = 0
            self.timeToBeWrong = 0
            //add one view for all hud and controls
            self.originalLocationTiles.removeAll()
            self.addLetterBox(currentQuest: self.currentNumberOfQuestion, completion: self.addHUDView)
            //start the timer
            self.startStopwatch()

        }
    }
    private func goback(){
        ProgressHUD.dismiss()
        leftTimer.endTimer()
        countdownTimer.endTimer()
        dismiss(animated: true, completion: nil)
    }
    
    func startStopwatch() {
        //initialize the timer HUD
        hud?.stopwatch.setSeconds(seconds: secondsLeft)
        //schedule a new timer
        leftTimer.startTimer(handler: self, selector: #selector(leftTime))
        
    }
    
    // MARK -- update the timer for the game
    @objc func leftTime() {
        secondsLeft -= 1
        hud.stopwatch.setSeconds(seconds: secondsLeft)
        
        if secondsLeft == 0{
            leftTimer.endTimer()
//            DispatchQueue.main.async {
                guard let queue = self.shuffedSelectedQues else {return}
                let word = queue[self.currentNumberOfQuestion]["word"] as! String

                ProgressHUD.showError("Time Out! The answer is \(word)")
//            }
            //end of time and didnt finished for sure its lose
      
            
            //to check if its last one
            DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
                self.points-=1
                self.checkIfLastQuestion()
            })

        }
    }
    
    
//    @objc func updateValue(timer:Timer) {
//        //1 update the value
//        if (endValue < data.points) {
//            data.points -= 1
//        } else {
//            data.points += 1
//        }
//
//        //2 stop and clear the timer
//        if (endValue == data.points) {
//            timer.invalidate()
//            self.timer = nil
//        }
//    }
    
    //count to a given value
//    func setValue(newValue:Int, duration:Float) {
//        //1 set the end value
//        endValue = newValue
//
//        //2 cancel previous timer
//        if timer != nil {
//            timer?.invalidate()
//            timer = nil
//        }
//
//        //3 calculate the interval to fire each timer
//        let deltaValue = abs(endValue - data.points)
//        if (deltaValue != 0) {
//            var interval = Double(duration / Float(deltaValue))
//            if interval < 0.01 {
//                interval = 0.01
//            }
//
//            //4 set the timer to update the value
//            timer = Timer.scheduledTimer(timeInterval: interval, target: self, selector:#selector(updateValue), userInfo: nil, repeats: true)
//        }
//    }
    
    
    //clear the tiles and targets
    func clearBoard() {
        tiles.removeAll(keepingCapacity: false)
        targets.removeAll(keepingCapacity: false)
        
        for view in gameView.subviews  {
            view.removeFromSuperview()
        }
    }
    
    
    
}


// to conform to the tile drag protocol
extension WordScrambleVC:TileDragDelegateProtocol {
    //a tile was dragged, check if matches a target
    func tileView(tileView: TileView, didDragToPoint point: CGPoint) {
//        tileView.isUserInteractionEnabled = false
        var targetView: TargetView?
        for tv in targets {
            if tv.frame.contains(point) && !tv.isMatched {
                targetView = tv
                break
            }
        }
        //1 check if target was found
        if let targetView = targetView {
            
            //2 check if letter matches
            if targetView.letter == tileView.letter {
                
//                self.timeToBeWrong = 0
                
                //3
                self.placeTile(tileView: tileView, targetView: targetView)
                
                //more stuff to do on success here
                audioController.playEffect(name: SoundDing)
                
                //give points
                //                right now assign each tile with 2 points for success
//                data.points += 2
//                pointsLabel.text = "Points: \(data.points)"

                print("Check if the player has completed the phrase")
                //check for finished game
                for tileview in self.tiles{
                    if tileview.isUserInteractionEnabled == true{
                        return
                    }
                }
                //all tile view are placed
                self.checkForSuccess()
                
            } else {
                
                // first go back to original place
//                UIView.animate(withDuration: 1.0, //0.35
//                    delay:0.1,
//                    options:UIView.AnimationOptions.curveEaseOut,
//                    animations: {
//                        tileView.center = self.originalLocationTiles[tileView.index]
//                        //                                tileView.center = CGPoint(x:tileView.center.x + CGFloat(Int.random(in: 0...40)-20),y:
//                        //                                    tileView.center.y + CGFloat(Int.random(in: 20...30)))
//                },
//                    completion: nil)
//                 tileView.randomize()
        
              
                UIView.animate(withDuration: 1.5, delay: 0.3, options: .curveEaseOut, animations: {
                    //
//                    let animation = CABasicAnimation(keyPath: "position")
//                    animation.timingFunction = CAMediaTimingFunction(controlPoints: 0.86, 0, 0.07, 1.0)
//                    animation.duration = 1.2
//                    animation.fromValue = NSValue(cgPoint: point)
//                    animation.toValue = NSValue(cgPoint: self.originalLocationTiles[tileView.index])
//                    print("the end value is \(String(describing: animation.toValue))")
//                    tileView.layer.add(animation, forKey: "position")
                    //
                    tileView.center = self.originalLocationTiles[tileView.index]
                }) { (value:Bool) in
//                    tileView.randomize()
                    self.timeToBeWrong += 1
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                        print(self.timeToBeWrong)
                        if self.timeToBeWrong > 3{
                            print("how come this happened???")
                            guard let queue = self.shuffedSelectedQues else {return}
                            let word = queue[self.currentNumberOfQuestion]["word"] as! String
                            ProgressHUD.showError("Three attempt Used! The answer is \(word)")
                            self.audioController.playEffect(name: SoundWrong)
                            DispatchQueue.main.asyncAfter(deadline: .now()+2.0, execute: {
                                
                                self.points-=1
                                self.checkIfLastQuestion()
                            })
                            
                        }else{
                            ProgressHUD.showError("Wrong place \(self.timeToBeWrong) times.")
//                            tileView.isUserInteractionEnabled = true
//                            DispatchQueue.main.asyncAfter(deadline: .now()+2.0, execute: {
//                                tileView.isUserInteractionEnabled = true
//                            })
                        }
                        
                        
//                    })
                    
                }
                
                
                
                
                
               
//                if timeToBeWrong > 3{
//                    //goto next question
//                    //end of time and didnt finished for sure its lose
////                    self.points-=1
//                    DispatchQueue.main.async {
//                        guard let queue = self.shuffedSelectedQues else {return}
//                        let word = queue[self.currentNumberOfQuestion]["word"] as! String
//
//                        ProgressHUD.showError("Three attempt Used! The answer is \(word)")
//                    }
//
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
//
//                        self.points-=1
//                        self.checkIfLastQuestion()
//                    })
////                    ProgressHUD.showError("Three attempt Used")
////                    //to check if its last one
////                    self.checkIfLastQuestion()
//                }
//                tileView.randomize()
                //2

                
                
                //more stuff to do on failure here
//                audioController.playEffect(name: SoundWrong)
                
                //take out points
                //                right now if put in wrong place then deduct point with 1
//                data.points -= 1
//                pointsLabel.text = "Points: \(data.points)"
                
            }
        }
        
    }
    
    //
    func placeTile(tileView: TileView, targetView: TargetView) {
        //1
        targetView.isMatched = true
        tileView.isMatched = true
        
        //2
        tileView.isUserInteractionEnabled = false
        
        //3
        UIView.animate(withDuration: 0.35,
                       delay:0.00,
                       options:UIView.AnimationOptions.curveEaseOut,
                       //4
            animations: {
                tileView.center = targetView.center
                tileView.transform = CGAffineTransform.identity
        },
            //5
            completion: {
                (value:Bool) in
                targetView.isHidden = true
        })
        
        let explode = ExplodeView(frame:CGRect(x:tileView.center.x, y:tileView.center.y, width:10,height:10))
        tileView.superview?.addSubview(explode)
        tileView.superview?.sendSubviewToBack(explode)
        
    }
    
}

