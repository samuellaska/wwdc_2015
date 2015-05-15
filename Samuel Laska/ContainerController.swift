//
//  ContainerController.swift
//  Samuel Laska
//
//  Created by Samuel Laska on 4/24/15.
//  Copyright (c) 2015 Samuel Laska. All rights reserved.
//

import UIKit

class ContainerController: UIViewController {
    
    var bgNavigationController: UINavigationController!
    
    var homeViewController: WWDCController!
    var messageController: MessageController!
    var homeScreen = true // WWDC screen displayed?
    var swipeEnabled = true
    
    // MARK:- ViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set wwdc view from storyboard
        homeViewController = UIStoryboard.wwdcViewController()
        homeViewController.delegate = self
        
        // setup background navigational controller, add WWDC home screen
        bgNavigationController = UINavigationController(rootViewController: homeViewController)
        view.addSubview(bgNavigationController.view)
        addChildViewController(bgNavigationController)
        bgNavigationController.didMoveToParentViewController(self)
        
        // hise navigation bar, set white bg color
        bgNavigationController.setNavigationBarHidden(true, animated: false)
        bgNavigationController.view.backgroundColor = UIColor.whiteColor()
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "handlePanGesture:")
        bgNavigationController.view.addGestureRecognizer(panGestureRecognizer)
        
        // push message controller to navigational controller
        messageController = MessageController()
        messageController.view.frame = homeViewController.view.frame
        view.insertSubview(messageController.view, atIndex: 0)
        addChildViewController(messageController!)
        messageController.didMoveToParentViewController(self)
        messageController.delegate = self
        
        // set shadow
        bgNavigationController.view.layer.shadowOpacity = 0.8
        
        // set translucent background view for status bar
        var visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .Light)) as UIVisualEffectView
        visualEffectView.frame = CGRectMake(0, 0, view.frame.width, 20)
        view.addSubview(visualEffectView)
    }
}

// MARK:- Delegate Functions for sub-ViewControllers

extension ContainerController: WWDCControllerDelegate {
    
    func toggleMessagePanel() {
        animateMessagesView(homeScreen,velocity: 0)
    }
    
    func animateMessagesView(goUp: Bool, velocity: CGFloat) {
        if (goUp) {
            homeScreen = false
            homeViewController.resetButton.hidden = false
            messageController.startAutomaton()
            animateViewYPosition(targetPosition: -CGRectGetHeight(bgNavigationController.view.frame), velocity: velocity)
        } else {
            animateViewYPosition(targetPosition: 0, velocity: velocity) { finished in
                self.homeScreen = true
            }
        }
    }
    
    func animateViewYPosition(#targetPosition: CGFloat, velocity: CGFloat, completion: ((Bool) -> Void)! = nil) {
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .CurveEaseInOut, animations: {
            self.bgNavigationController.view.frame.origin.y = targetPosition
            }, completion: completion)
    }
    
    // reset message controller to start from beginning
    func resetMessages() {
        messageController.resetEverything()
    }
}


// MARK:- Swipeup gesture

extension ContainerController: UIGestureRecognizerDelegate {
    
    func handlePanGesture(recognizer: UIPanGestureRecognizer) {
        if (swipeEnabled) {
            switch(recognizer.state) {
    //        case .Began:
            case .Changed:
                let new = recognizer.view!.center.y + recognizer.translationInView(view).y
                if (new <= recognizer.view!.frame.height/2) {
                    recognizer.view!.center.y = new
                    recognizer.setTranslation(CGPointZero, inView: view)
                }
            case .Ended:
                var passedTreshold = false
                if (recognizer.view!.center.y < 0 || recognizer.velocityInView(view).y < -400) {
                    passedTreshold = true
                }
                animateMessagesView(passedTreshold, velocity: recognizer.velocityInView(view).y)
            default:
                break
            }
        }
    }
    
}

// MARK: Storyboard connections

private extension UIStoryboard {
    class func mainStoryboard() -> UIStoryboard { return UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()) }

    class func wwdcViewController() -> WWDCController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("WWDCViewController") as? WWDCController
    }
}

