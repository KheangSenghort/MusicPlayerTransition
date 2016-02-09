//
//  ViewController.swift
//  MusicPlayerTransition
//
//  Created by xxxAIRINxxx on 2015/08/27.
//  Copyright (c) 2015 xxxAIRINxxx. All rights reserved.
//

import UIKit
import ARNTransitionAnimator

final class ViewController: UIViewController {
    
    @IBOutlet weak var containerView : UIView!
    @IBOutlet weak var tabBar : UITabBar!
    @IBOutlet weak var miniPlayerView : LineView!
    @IBOutlet weak var miniPlayerButton : UIButton!
    
    var animator : ARNTransitionAnimator!
    var modalVC : ModalViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        self.modalVC = storyboard.instantiateViewControllerWithIdentifier("ModalViewController") as? ModalViewController
        self.modalVC.modalPresentationStyle = .FullScreen
        self.modalVC.tapCloseButtonActionHandler = { [weak self] in
            self!.animator.interactiveType = .None
        }
        
        let color = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 0.3)
        self.miniPlayerButton.setBackgroundImage(self.generateImageWithColor(color), forState: .Highlighted)
        
        self.setupAnimator()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        print("ViewController viewWillAppear")
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        print("ViewController viewWillDisappear")
    }
    
    func setupAnimator() {
        self.animator = ARNTransitionAnimator(operationType: .Present, fromVC: self, toVC: modalVC)
        self.animator.usingSpringWithDamping = 0.8
        self.animator.gestureTargetView = self.miniPlayerView
        self.animator.interactiveType = .Present
        
        // Present
        
        self.animator.presentationBeforeHandler = { [weak self] (containerView: UIView, transitionContext:
            UIViewControllerContextTransitioning) in
            self!.animator.direction = .Top
            
            self!.modalVC.view.frame.origin.y = self!.miniPlayerView.frame.origin.y + self!.miniPlayerView.frame.size.height
            containerView.addSubview(self!.view)
            self!.view.insertSubview(self!.modalVC.view, belowSubview: self!.tabBar)
            
            self!.view.layoutIfNeeded()
            self!.modalVC.view.layoutIfNeeded()
            
            // miniPlayerView
            let startOriginY = self!.miniPlayerView.frame.origin.y
            let endOriginY = -self!.miniPlayerView.frame.size.height
            let diff = -endOriginY + startOriginY
            // tabBar
            let tabStartOriginY = self!.tabBar.frame.origin.y
            let tabEndOriginY = containerView.frame.size.height
            let tabDiff = tabEndOriginY - tabStartOriginY
            
            self!.animator.presentationCancelAnimationHandler = { (containerView: UIView) in
                self!.miniPlayerView.frame.origin.y = startOriginY
                self!.modalVC.view.frame.origin.y = self!.miniPlayerView.frame.origin.y + self!.miniPlayerView.frame.size.height
                self!.tabBar.frame.origin.y = tabStartOriginY
                self!.containerView.alpha = 1.0
                for subview in self!.miniPlayerView.subviews {
                    subview.alpha = 1.0
                }
            }
            
            self!.animator.presentationAnimationHandler = { [weak self] (containerView: UIView, percentComplete: CGFloat) in
                let _percentComplete = percentComplete >= 0 ? percentComplete : 0
                self!.miniPlayerView.frame.origin.y = startOriginY - (diff * _percentComplete)
                if self!.miniPlayerView.frame.origin.y < endOriginY {
                    self!.miniPlayerView.frame.origin.y = endOriginY
                }
                self!.modalVC.view.frame.origin.y = self!.miniPlayerView.frame.origin.y + self!.miniPlayerView.frame.size.height
                self!.tabBar.frame.origin.y = tabStartOriginY + (tabDiff * _percentComplete)
                if self!.tabBar.frame.origin.y > tabEndOriginY {
                    self!.tabBar.frame.origin.y = tabEndOriginY
                }
                
                self!.containerView.alpha = 1.0 - (1.0 * _percentComplete) + 0.5
                for subview in self!.miniPlayerView.subviews {
                    subview.alpha = 1.0 - (1.0 * percentComplete)
                }
            }
            
            self!.animator.presentationCompletionHandler = {(containerView: UIView, completeTransition: Bool) in
                if completeTransition {
                    self!.modalVC.view.removeFromSuperview()
                    containerView.addSubview(self!.modalVC.view)
                    self!.animator.interactiveType = .Dismiss
                    self!.animator.gestureTargetView = self!.modalVC.imageView
                    self!.animator.direction = .Bottom
                } else {
                    self!.view.removeFromSuperview()
                    UIApplication.sharedApplication().keyWindow!.addSubview(self!.view)
                }
            }
        }
        
        // Dismiss
        
        self.animator.dismissalBeforeHandler = { [weak self] (containerView: UIView, transitionContext: UIViewControllerContextTransitioning) in
            containerView.addSubview(self!.view)
            self!.view.insertSubview(self!.modalVC.view, belowSubview: self!.tabBar)
            
            self!.view.layoutIfNeeded()
            self!.modalVC.view.layoutIfNeeded()
            
            // miniPlayerView
            let startOriginY = 0 - self!.miniPlayerView.bounds.size.height
            let endOriginY = self!.containerView.bounds.size.height - self!.miniPlayerView.frame.size.height
            let diff = -startOriginY + endOriginY
            // tabBar
            let tabStartOriginY = containerView.bounds.size.height
            let tabEndOriginY = containerView.bounds.size.height - self!.tabBar.bounds.size.height
            let tabDiff = tabStartOriginY - tabEndOriginY
            
            self!.tabBar.frame.origin.y = containerView.bounds.size.height
            
            self!.animator.dismissalCancelAnimationHandler = { (containerView: UIView) in
                self!.miniPlayerView.frame.origin.y = startOriginY
                self!.modalVC.view.frame.origin.y = self!.miniPlayerView.frame.origin.y + self!.miniPlayerView.frame.size.height
                self!.tabBar.frame.origin.y = tabStartOriginY
                self!.containerView.alpha = 0.0
                for subview in self!.miniPlayerView.subviews {
                    subview.alpha = 0.0
                }
            }
            
            self!.animator.dismissalAnimationHandler = {(containerView: UIView, percentComplete: CGFloat) in
                let _percentComplete = percentComplete >= -0.05 ? percentComplete : -0.05
                self!.miniPlayerView.frame.origin.y = startOriginY + (diff * _percentComplete)
                self!.modalVC.view.frame.origin.y = self!.miniPlayerView.frame.origin.y + self!.miniPlayerView.frame.size.height
                self!.tabBar.frame.origin.y = tabStartOriginY - (tabDiff *  _percentComplete)
                
                self!.containerView.alpha = (1.0 * _percentComplete)
                for subview in self!.miniPlayerView.subviews {
                    subview.alpha = 1.0 * _percentComplete
                }
            }
            
            self!.animator.dismissalCompletionHandler = { (containerView: UIView, completeTransition: Bool) in
                if completeTransition {
                    self!.modalVC.view.removeFromSuperview()
                    self!.animator.gestureTargetView = self!.miniPlayerView
                    self!.animator.interactiveType = .Present
                    
                    self!.view.removeFromSuperview()
                    UIApplication.sharedApplication().keyWindow!.addSubview(self!.view)
                }
            }
        }
        
        self.modalVC.transitioningDelegate = self.animator
    }
    
    @IBAction func tapMiniPlayerButton() {
        self.animator.interactiveType = .None
        self.presentViewController(modalVC, animated: true, completion: nil)
    }
    
    private func generateImageWithColor(color: UIColor) -> UIImage {
        let rect = CGRectMake(0, 0, 1, 1)
        
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        
        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextFillRect(context, rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
}

