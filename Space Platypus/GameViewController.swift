//
//  GameViewController.swift
//  Space Platypus Swift
//
//  Created by Andrew Paterson on 6/4/14.
//  Copyright (c) 2014 Andrew Paterson. All rights reserved.
//

import UIKit
import SpriteKit
import GameKit


// Simple subclass of SKSpriteNode for the platypus sprites in the customize menus: Not used elsewhere
class PlatypusSprite: SKSpriteNode {
    var type: kPlatypusColor?
}

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        if gameCenterEnabled {
            self.authenticateLocalPlayer()
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

    }

    override func shouldAutorotate() -> Bool {
        return false
    }

    override func supportedInterfaceOrientations() -> Int {
        return UIInterfaceOrientation.Portrait.toRaw()
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
                    self.view.window.rootViewController.presentModalViewController(controller, animated: true)
                } else {
                    gameCenterEnabled = false
                }
                })

            localPlayer.authenticateHandler = handler


            }))

    }
    
}
