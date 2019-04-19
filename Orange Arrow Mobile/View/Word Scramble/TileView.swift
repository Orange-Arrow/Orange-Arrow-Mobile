//
//  TileView.swift
//  Orange Arrow Mobile
//
//  Created by 刘祥 on 3/29/19.
//  Copyright © 2019 xiangliu90. All rights reserved.
//

import UIKit

// to handle once tile is dragged to the target
protocol TileDragDelegateProtocol {
    func tileView(tileView: TileView, didDragToPoint: CGPoint)
}

class TileView:UIImageView{
    var index : Int
    var letter : Character
    var isMatched = false
    
    private var xOffset: CGFloat = 0.0
    private var yOffset: CGFloat = 0.0
    
    var dragDelegate: TileDragDelegateProtocol?
    
    private var tempTransform: CGAffineTransform = .identity

    
    required init(coder aDecoder: NSCoder) {
        fatalError("use init(letter:, sideLength:")
    }
    init(letter:Character, sideLength:CGFloat, index:Int){
        self.letter = letter
        self.index = index
        let image = UIImage(named: "tile")!
        super.init(image:image)
        let scale = sideLength / image.size.width
        self.frame = CGRect(x: 0, y: 0, width: image.size.width * scale, height: image.size.height * scale)
        
        //add a letter on top
        let letterLabel = UILabel(frame: self.bounds)
        letterLabel.textAlignment = NSTextAlignment.center
        letterLabel.textColor = UIColor.white
        letterLabel.backgroundColor = UIColor.clear
        letterLabel.text = String(letter).uppercased()
        letterLabel.font = UIFont(name: "Verdana-Bold", size: 78.0*scale)
        self.addSubview(letterLabel)
        
        self.isUserInteractionEnabled = true
        
        //create the tile shadow
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0
        self.layer.shadowOffset = CGSize(width:10.0, height:10.0)
        self.layer.shadowRadius = 15.0
        self.layer.masksToBounds = false
        
        let path = UIBezierPath(rect: self.bounds)
        self.layer.shadowPath = path.cgPath



    }
    
    func randomize() {
        //1
        //set random rotation of the tile
        //anywhere between -0.2 and 0.3 radians
        
        let rotation = CGFloat(Int.random(in: 0...50)) / 100.0 - 0.2
        self.transform = CGAffineTransform(rotationAngle: rotation)
        
        //2
        //move randomly upwards
        let yOffset = CGFloat(Int.random(in: 0...10) - 10)
        self.center = CGPoint(x:self.center.x, y:self.center.y + yOffset)
    }
    
    //1
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let point = touch.location(in: self.superview)
            xOffset = point.x - self.center.x
            yOffset = point.y - self.center.y
            
            //show the drop shadow
            self.layer.shadowOpacity = 0.8
            
            //save the current transform
            tempTransform = self.transform
            //enlarge the tile
     
            self.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            self.superview?.bringSubviewToFront(self)

        }
        
    }
    
    //2
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let point = touch.location(in: self.superview)
            self.center = CGPoint(x:point.x - xOffset, y:point.y - yOffset)
//            dragDelegate?.tileView(tileView: self, didDragToPoint: self.center)

        }
    }

    
    //3
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        //restore the original transform
        self.transform = tempTransform
        
//        self.touchesMoved(touches, with: event)
        if let touch = touches.first {
            let point = touch.location(in: self.superview)
            self.center = CGPoint(x:point.x - xOffset, y:point.y - yOffset)
            dragDelegate?.tileView(tileView: self, didDragToPoint: self.center)
            
        }
//        dragDelegate?.tileView(tileView: self, didDragToPoint: self.center)
        
        self.layer.shadowOpacity = 0.0

    }
    
    //reset the view transform in case drag is cancelled
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.transform = tempTransform
        self.layer.shadowOpacity = 0.0
    }




    
}
