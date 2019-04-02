//
//  WordScrambleVC.swift
//  Orange Arrow Mobile
//
//  Created by 刘祥 on 3/6/19.
//  Copyright © 2019 xiangliu90. All rights reserved.
//

import UIKit

class WordScrambleVC: UIViewController {

    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var hintImageView: UIImageView!
    @IBOutlet weak var levelProgressBar: UIView!
    @IBOutlet weak var gamePorgressBar: UIView!
    @IBOutlet weak var gameView: UIView!
    
    //set up timer
    var countdownTimer = TimerOfGame()
    var initialTime = 0
    var questions : WordScramble?
    var currentLevel : Int = 1
    
    private var tiles = [TileView]()
    private var targets = [TargetView]()

    let TileMargin: CGFloat = 20.0
    var shuffedSelectedQues: [NSDictionary]?
    var currentNumberOfQuestion = 0
    
    var hud: HUDView!
    
    //stopwatch variables
    private var secondsLeft = 60
    private var leftTimer = TimerOfGame()
    
    private var data = GameData()
    
    private var endValue: Int = 0
    private var timer: Timer? = nil
    
    private var audioController = AudioController()

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        audioController.preloadAudioEffects(effectFileNames: AudioEffectFiles)

        
        
        //start to count the time
        countdownTimer.startTimer(handler: self, selector: #selector(updateTime))

        // update navigation bar
        let navItem = Utilities.setupNavigationBar(image: "icon_word", tappedFunc: #selector(backBtnTapped), handler: self)
        navigationBar.setItems([navItem], animated: false)
        
        
        //initialize the questions
        questions = WordScramble(level: currentLevel)
        
        if let questions = questions{
            let firstEle = questions.contentPool.list[0] as NSDictionary
            print(firstEle["hint"] as! String)
            // to make the questions shuffed and selected
            let pool = questions.contentPool.list
            assert(pool.count > 0, "no level loaded")
            self.shuffedSelectedQues = pool.choose(questions.selectedLevelForEachLevel)
            addLetterBox(currentQuest: 0)
            
            //add one view for all hud and controls
            let hudView = HUDView(frame: CGRect(x: 0, y: 0, width: gameView.bounds.size.width, height: gameView.bounds.size.height))
            gameView.addSubview(hudView)
            self.hud = hudView
            //start the timer
            self.startStopwatch()

        }else{
            print("this is wrong")
        }
        


    }
    
    
    
    
    
    //MARK -- navigation bar back button
    @objc func backBtnTapped(){
        dismiss(animated: true, completion: nil)
        Utilities.changeStatusBarColor(color: UIColor(named: "oaColor")!)
        // the color looks so different tho???
    }

    // MARK -- update the timer for the game
    @objc func updateTime() {
        timeLabel.text = "Time: \(Utilities.timeFormatted(initialTime))"
        initialTime += 1
    }
    
    
    // MARK --  to add the letter in the guessing area
    func addLetterBox (currentQuest : Int) {
        
        guard let queue = shuffedSelectedQues else {return}
        let hint = queue[currentQuest]["hint"] as! String
        print("the hint is \(hint)")
        // update the image of hint
        hintImageView.image = UIImage(named: hint)
        
        let word = queue[currentQuest]["word"] as! String
        let wordArr = Array(word)
        let shuffedword = word.shuffled()
        let length = word.count
        
        print("the word is \(word) and the length is \(length) and the shuffed word is \(shuffedword)")
        
        //calculate the tile size
        let tileSide = ceil(gameView.frame.size.width * 0.9 / CGFloat(length)) - TileMargin
        //get the left margin for first tile
        var xOffset = (gameView.frame.size.width - CGFloat(length) * (tileSide + TileMargin)) / 2.0
        //adjust for tile center (instead of the tile's origin)
        xOffset += tileSide / 2.0

        //1 initialize tile list
        tiles = []
        //2 create tiles
        for (index, letter) in shuffedword.enumerated() {
            //3
            if letter != " " {
                let tile = TileView(letter: letter, sideLength: tileSide)
                tile.randomize()
                tile.dragDelegate = self
                tile.center = CGPoint(x:xOffset + CGFloat(index)*(tileSide + TileMargin), y:gameView.frame.size.height/4*3)
                
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
                target.center = CGPoint(x:xOffset + CGFloat(index)*(tileSide + TileMargin), y:gameView.frame.size.height/4)
                
                gameView.addSubview(target)
                targets.append(target)
            }
        }

    }
    
    func checkForSuccess() {
        for targetView in targets {
            //no success, bail out
            if !targetView.isMatched {
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
        })




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
        }
    }
    
    //
    @objc func updateValue(timer:Timer) {
        //1 update the value
        if (endValue < data.points) {
            data.points -= 1
        } else {
            data.points += 1
        }
        
        //2 stop and clear the timer
        if (endValue == data.points) {
            timer.invalidate()
            self.timer = nil
        }
    }
    
    //count to a given value
    func setValue(newValue:Int, duration:Float) {
        //1 set the end value
        endValue = newValue
        
        //2 cancel previous timer
        if timer != nil {
            timer?.invalidate()
            timer = nil
        }
        
        //3 calculate the interval to fire each timer
        let deltaValue = abs(endValue - data.points)
        if (deltaValue != 0) {
            var interval = Double(duration / Float(deltaValue))
            if interval < 0.01 {
                interval = 0.01
            }
            
            //4 set the timer to update the value
            timer = Timer.scheduledTimer(timeInterval: interval, target: self, selector:#selector(updateValue), userInfo: nil, repeats: true)
        }
    }



}


// to conform to the tile drag protocol
extension WordScrambleVC:TileDragDelegateProtocol {
    //a tile was dragged, check if matches a target
    func tileView(tileView: TileView, didDragToPoint point: CGPoint) {
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
                
                //3
                self.placeTile(tileView: tileView, targetView: targetView)
                
                //more stuff to do on success here
                audioController.playEffect(name: SoundDing)

                //give points
//                right now assign each tile with 2 points for success
                data.points += 2
                pointsLabel.text = "Points: \(data.points)"
                

                
                print("Check if the player has completed the phrase")
                //check for finished game
                self.checkForSuccess() // it is right and can goto next word or the time is limited and goto next with wrong answer

            } else {
                
                //4
                //1
                tileView.randomize()
                //2
                UIView.animate(withDuration: 0.35,
                                           delay:0.00,
                                           options:UIView.AnimationOptions.curveEaseOut,
                                           animations: {
                                            tileView.center = CGPoint(x:tileView.center.x + CGFloat(Int.random(in: 0...40)-20),y:
                                                                          tileView.center.y + CGFloat(Int.random(in: 20...30)))
                },
                                           completion: nil)

                
                //more stuff to do on failure here
                audioController.playEffect(name: SoundWrong)

                //take out points
//                right now if put in wrong place then deduct point with 1
                data.points -= 1
                pointsLabel.text = "Points: \(data.points)"

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

