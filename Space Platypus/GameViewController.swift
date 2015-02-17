//
//  GameViewController.swift
//  Space Platypus Swift
//
//  Created by Andrew Paterson on 6/4/14.
//  Copyright (c) 2014 Andrew Paterson. All rights reserved.
//
import iAd
import UIKit
import SpriteKit
import GameKit

class GameViewController: UIViewController, ADBannerViewDelegate {

    var iAdBanner = ADBannerView()
    var bannerVisible = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if gameCenterEnabled {
            self.authenticateLocalPlayer()
        }
    }

    func bannerViewDidLoadAd(banner: ADBannerView!) {
        if(bannerVisible == false) {
            
            // Add banner Ad to the view
            if(iAdBanner.superview == nil) {
                self.view?.addSubview(iAdBanner)
            }
            
            // Move banner into visible screen frame:
            UIView.beginAnimations("iAdBannerShow", context: nil)
            banner.frame = CGRectOffset(banner.frame, 0, -banner.frame.size.height)
            UIView.commitAnimations()
            
            bannerVisible = true
        }
        
    }
    
    // Hide banner, if Ad is not loaded.
    func bannerView(banner: ADBannerView!, didFailToReceiveAdWithError error: NSError!) {
        if(bannerVisible == true) {
            // Move banner below screen frame:
            UIView.beginAnimations("iAdBannerHide", context: nil)
            banner.frame = CGRectOffset(banner.frame, 0, banner.frame.size.height)
            UIView.commitAnimations()
            bannerVisible = false
        }
        
    }
    
    func bannerViewActionDidFinish(banner: ADBannerView!) {
        let view = self.view as SKView
        view.presentScene(WelcomeScene(size: self.view.frame.size))
        if let height = self.view?.frame.size.height {
            if let width = self.view?.frame.size.width {
                banner.frame = CGRectMake(0, height, width, 50)
                banner.frame = CGRectOffset(banner.frame, 0, banner.frame.size.height)
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {

        let scene = WelcomeScene(size: self.view.frame.size)

        // Configure the view.
        let skView = self.view as SKView
        
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView.ignoresSiblingOrder = true

        /* Set the scale mode to scale to fit the window */
        scene.scaleMode = .AspectFill

        skView.presentScene(scene)
        
        if let height = self.view?.frame.size.height {
            if let width = self.view?.frame.size.width {
                iAdBanner.frame = CGRectMake(0, height, width, 50)
                iAdBanner.delegate = self
                bannerVisible = false
            }
        }

    }

    override func shouldAutorotate() -> Bool {
        return false
    }

    override func supportedInterfaceOrientations() -> Int {
        return UIInterfaceOrientation.Portrait.rawValue
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    func authenticateLocalPlayer() {

        dispatch_async(dispatch_queue_create("com.AndrewPaterson.SpacePlatypus.GameKit", nil), ({

            let localPlayer = getLocalPlayer()

            let handler: (UIViewController!, NSError!) -> Void = ({(controller, error) in

                if controller != nil {
                    self.view.window?.rootViewController?.presentViewController(controller, animated: true, completion: nil)
                } else {
                    gameCenterEnabled = false
                }
                })

            localPlayer.authenticateHandler = handler


            }))

    }
    
}
