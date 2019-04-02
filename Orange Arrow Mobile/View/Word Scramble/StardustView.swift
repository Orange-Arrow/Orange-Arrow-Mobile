//
//  StardustView.swift
//  Orange Arrow Mobile
//
//  Created by 刘祥 on 4/1/19.
//  Copyright © 2019 xiangliu90. All rights reserved.
//

import UIKit

class StardustView:UIView {
    private var emitter:CAEmitterLayer!
    
    required init(coder aDecoder:NSCoder) {
        fatalError("use init(frame:")
    }
    
    override init(frame:CGRect) {
        super.init(frame:frame)
        //initialize the emitter
        emitter = self.layer as! CAEmitterLayer
        emitter.emitterPosition = CGPoint(x:self.bounds.size.width/2, y:self.bounds.size.height/2)
        emitter.emitterSize = self.bounds.size
        emitter.renderMode = CAEmitterLayerRenderMode.additive
        emitter.emitterShape = CAEmitterLayerEmitterShape.rectangle
    }
    
    override class var layerClass: AnyClass {
        get {
            return CAEmitterLayer.self
        }
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if self.superview == nil {
            return
        }
        
        //load the texture image
        let texture:UIImage? = UIImage(named:"particle")
        assert(texture != nil, "particle image not found")
        
        //create new emitter cell
        let emitterCell = CAEmitterCell()
        emitterCell.contents = texture!.cgImage
        emitterCell.name = "cell"
        emitterCell.birthRate = 200
        emitterCell.lifetime = 1.5
        emitterCell.blueRange = 0.33
        emitterCell.blueSpeed = -0.33
        emitterCell.yAcceleration = 100
        emitterCell.xAcceleration = -200
        emitterCell.velocity = 100
        emitterCell.velocityRange = 40
        emitterCell.scaleRange = 0.5
        emitterCell.scaleSpeed = -0.2
        emitterCell.emissionRange = CGFloat(Double.pi*2)
        
        let emitter = self.layer as! CAEmitterLayer
        emitter.emitterCells = [emitterCell]
    }
    
    func disableEmitterCell() {
        emitter.setValue(0, forKeyPath: "emitterCells.cell.birthRate")
    }
}

