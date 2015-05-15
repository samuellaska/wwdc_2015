//
//  ViewController.swift
//  Samuel Laska
//
//  Created by Samuel Laska on 4/23/15.
//  Copyright (c) 2015 Samuel Laska. All rights reserved.
//

import UIKit

@objc
protocol WWDCControllerDelegate {
    var swipeEnabled: Bool { get set }
    func toggleMessagePanel()
    func resetMessages()
}

class WWDCController: UIViewController {    
    
    var delegate: WWDCControllerDelegate?
    
    var animationStep = 0
    
    // top rounded squares
    let topBlack1 = CAShapeLayer()
    let topBlack2 = CAShapeLayer()
    
    // middle disks
    var disks = [CAShapeLayer]()
    let carousel = CALayer()
    
    // Buttons
    @IBOutlet weak var tapButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    
    // Labels inside box
    @IBOutlet weak var middleLabel: UILabel!
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var bottomLabel: UILabel!
    
    @IBOutlet weak var swipeUpLabel: UILabel!
    
    // MARK:- ViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // establish WWDC Logo size
        let wwdcSize = min(view.bounds.size.width, view.bounds.size.height)
        
        // draw WWDC Logo layers
        createTopSquares(wwdcSize)
        createMiddleCircles(wwdcSize)
        
        // disable swipeUp at start
        delegate?.swipeEnabled = false
        swipeUpLabel.alpha = 0.0
        
        topLabel.alpha = 0.0
        middleLabel.alpha = 0.0
        bottomLabel.alpha = 0.0
        
        // debug
        resetButton.hidden = true
//        self.delegate?.toggleMessagePanel()
    }
    
    // MARK:- Layers setup
    
    func createTopSquares(referenceSize:CGFloat) {
        
        // size, color, bounds
        let scale = CGFloat(0.4)
        let borderRadius = referenceSize*scale*0.25
        let darkBlue = Script.color(21, g: 1, b: 52, a: 0.65).CGColor
        let bounds = CGRect(x: 0, y: 0, width: referenceSize*scale, height: referenceSize*scale)
        
        // Static square
        topBlack1.bounds = bounds
        topBlack1.position = view.center
        topBlack1.backgroundColor = darkBlue
        topBlack1.cornerRadius = borderRadius
        topBlack1.shouldRasterize = true
        topBlack1.rasterizationScale = UIScreen.mainScreen().scale
        view.layer.insertSublayer(topBlack1, atIndex: 0)
        
        // Moving square
        topBlack2.bounds = bounds
        topBlack2.position = view.center
        topBlack2.backgroundColor = darkBlue
        topBlack2.cornerRadius = borderRadius
        topBlack2.shouldRasterize = true
        topBlack2.rasterizationScale = UIScreen.mainScreen().scale
        view.layer.insertSublayer(topBlack2, atIndex: 0)
    }
    
    func createMiddleCircles(referenceSize:CGFloat) {
        
        // size, diameter
        let scale = CGFloat(1)/3
        let diameter = referenceSize*scale
        let bounds = CGRect(x: 0, y: 0, width: diameter, height: diameter)
        
        for index in 0...7 {
            // disk setup
            let disk = CAShapeLayer()
            disk.bounds = bounds
            disk.position = CGPoint(x: view.center.x, y: view.center.y)
            disk.backgroundColor = Script.colorForIndex(index, alpha: 0.75).CGColor
            disk.cornerRadius = diameter*0.5
            disk.anchorPoint = CGPointMake(0.5, 0.5)
            disk.transform = CATransform3DMakeRotation(degToRad(45*CGFloat(index)), 0.0, 0.0, 0.1)
            disk.shouldRasterize = true
            disk.rasterizationScale = UIScreen.mainScreen().scale
            
            // disk shadow
            disk.shadowColor = UIColor.blackColor().CGColor
            disk.shadowOpacity = 0.4
            disk.shadowOffset = CGSizeMake(-diameter/25, diameter/25)
            disk.shadowRadius = diameter/25
            
            view.layer.insertSublayer(disk, atIndex: 0)
            disks.append(disk)
        }
    }
    
    func createOuterShapes() {
        let referenceSize = min(view.bounds.size.width, view.bounds.size.height)
        
        // layer carrying outer shapes
        carousel.anchorPoint = CGPointMake(0.5, 0.5)
        carousel.position = view.center
        view.layer.addSublayer(carousel)
        
        // shape size, diameter
        let scale = CGFloat(1)/10
        let diameter = referenceSize*scale
        let fromCenter = referenceSize*0.35
        let bounds = CGRect(x: diameter, y: 0, width: diameter, height: diameter)
        
        
        for index in 0...7 {
            let angle = degToRad(45*CGFloat(index))
            
            // shape setup
            let shape = CAShapeLayer()
            shape.bounds = bounds
            shape.backgroundColor = Script.colorForIndex(index, alpha: 0.85).CGColor
            
            // transform = rotate 45deg around center -> translate x -> rotate
            shape.transform = CATransform3DConcat(
                CATransform3DConcat(
                    CATransform3DMakeRotation(CGFloat(M_PI/4), 0.0, 0.0, 0.1),
                    CATransform3DMakeTranslation(fromCenter, 0.0, 0.0)
                ),
                CATransform3DMakeRotation(angle, 0.0, 0.0, 0.1)
            )
            
            // shadow
            shape.shadowColor = UIColor.blackColor().CGColor
            shape.shadowOpacity = 0.25
            shape.shadowOffset = CGSizeMake(-diameter/12.5, diameter/12.5)
            shape.shadowRadius = diameter/12.5
            shape.shouldRasterize = true
            shape.rasterizationScale = UIScreen.mainScreen().scale
            
            
            // disk or rounded square
            if index % 2 == 0 {
                shape.cornerRadius = diameter*0.5
            } else {
                shape.cornerRadius = diameter*0.25
            }
            
            // add to carousel layer
            carousel.addSublayer(shape)
            
            // initial scale animation
            let scale = CABasicAnimation(keyPath: "transform.scale")
            scale.fromValue = NSValue(CATransform3D:CATransform3DMakeScale(0.0, 0.0, 0.0))
            scale.toValue = NSValue(CATransform3D:CATransform3DIdentity)
            scale.duration = 2
            scale.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
            shape.addAnimation(scale, forKey: "scale")
        }
        
        // Carousel animation
        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        animation.fromValue = disks[0].presentationLayer().valueForKeyPath("transform.rotation.z")
        animation.byValue = M_PI*2
        animation.repeatCount = Float.infinity
        animation.duration = 20
        carousel.addAnimation(animation, forKey: "carousel")
    }
    
    // MARK:- Layer animations
    
    func rotateTopLayer(){        
        // Moving Rectangle Rotation
        let rotation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.byValue = -M_PI*2
        rotation.repeatCount = Float.infinity
        rotation.duration = 30
        topBlack2.addAnimation(rotation, forKey: "topRotation")
    }
    
    func rotateMiddleLayer() {
        if (disks.isEmpty) {
            return
        }
        
        for disk in disks {
            // outward animation
            let animation = CABasicAnimation(keyPath: "anchorPoint")
            animation.fromValue = NSValue(CGPoint:CGPointMake(0.5, 0.5))
            animation.toValue = NSValue(CGPoint: CGPointMake(0, 0.5))
            animation.repeatCount = 1
            animation.duration = 2
            animation.removedOnCompletion = false
            animation.fillMode = kCAFillModeForwards
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
            disk.addAnimation(animation, forKey: "diskOutward")
            
            // rotation animation
            let rotation = CABasicAnimation(keyPath: "transform.rotation.z")
            rotation.duration = 20
            rotation.repeatCount = Float.infinity
            rotation.byValue = M_PI*2
            disk.addAnimation(rotation, forKey: "diskRotation")
        }
    }
    
    // MARK:- Colors
    
    // MARK:- Convenience helper functions
    
    func degToRad(deg: CGFloat) -> CGFloat {
        return (deg * CGFloat(M_PI)) / 180.0
    }
    
    // MARK:- UI actions
    
    @IBAction func triggerAnimation(sender: AnyObject) {
        switch(animationStep){
        case 0:
            rotateTopLayer()
            tapButton.setTitle("Tap again!", forState: UIControlState.Normal)
        case 1:
            rotateMiddleLayer()
            tapButton.setTitle("Once more!", forState: UIControlState.Normal)
        case 2:
            createOuterShapes()
            
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                
                // hide tap button
                self.tapButton.alpha = 0.0
                }, completion: { (Bool) -> Void in
                    UIView.animateWithDuration(1.0, animations: { () -> Void in
                        
                        // show center label's
                        self.middleLabel.alpha = 1.0
                        self.topLabel.alpha = 1.0
                        self.bottomLabel.alpha = 1.0
                        
                        }, completion: { (Bool) -> Void in
                            UIView.animateWithDuration(1.0, delay: 1.0, options: nil, animations: { () -> Void in
                                
                            // wait and show&enable swipe up and remaining labels
                            self.delegate?.swipeEnabled = true
                            self.swipeUpLabel.alpha = 1.0
                            
                            }, completion: { (Bool) -> Void in
                        })
                    })
            })
            
            
        default:
            return
        }
        animationStep++
    }
    
    @IBAction func resetToBeginning(sender: AnyObject) {
        animationStep = 0
        topBlack1.removeFromSuperlayer()
        topBlack2.removeFromSuperlayer()
        topBlack2.removeAllAnimations()
        for disk in disks {
            disk.removeFromSuperlayer()
        }
        disks.removeAll(keepCapacity: true)
        carousel.sublayers = nil
        
        topLabel.alpha = 0.0
        middleLabel.alpha = 0.0
        bottomLabel.alpha = 0.0
        swipeUpLabel.alpha = 0.0
        
        tapButton.setTitle("Tap!", forState: UIControlState.Normal)
        tapButton.alpha = 1.0
        
        // establish WWDC Logo size
        let wwdcSize = min(view.bounds.size.width, view.bounds.size.height)
        
        // draw WWDC Logo layers
        createTopSquares(wwdcSize)
        createMiddleCircles(wwdcSize)
        
        // disable swipeUp at start
        delegate?.swipeEnabled = false
        delegate?.resetMessages()
        
        // hide reset button
        self.resetButton.hidden = true
    }
}

