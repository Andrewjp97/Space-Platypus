//
//  OptionsScene.swift
//  Space Platypus Swift
//
//  Created by Andrew Paterson on 6/5/14.
//  Copyright (c) 2014 Andrew Paterson. All rights reserved.
//

import Foundation
import SpriteKit
import GameKit

class OptionsScene: SKScene {

    var contentCreated: Bool = false

    override func didMoveToView(view: SKView!) {

        if !self.contentCreated {
            self.makeStars()
            self.backgroundColor = SKColor.blackColor()
            // If motion is enabled, make the button green.  Otherwise, make it red.
            let node = SKSpriteNode(color: motionEnabled ? SKColor.greenColor() : SKColor.redColor(),
                                                                            size: CGSizeMake(250, 100))
            node.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
            node.name = "button"

            let text = SKLabelNode(fontNamed: "Helvetica")
            text.text = motionEnabled ? "Disable Motion Control" : "Enable Motion Control"
            text.fontColor = SKColor.whiteColor()
            text.zPosition = node.zPosition + 1
            text.fontSize = 20
            text.name = "text"
            text.position = node.position
            text.position.y = text.position.y - 10

            self.addChild(text)
            self.addChild(node)

            let backButton = SKLabelNode(fontNamed: "Helvetica")
            backButton.text = "Back"
            backButton.name = "back"
            backButton.fontColor = SKColor.whiteColor()
            backButton.fontSize = 24
            backButton.position = CGPointMake(10 + (0.5 * backButton.frame.size.width), CGRectGetMaxY(self.frame) - 20 - (0.5 * backButton.frame.size.height))
            self.addChild(backButton)

            self.contentCreated = true
        }

    }


    override func touchesBegan(touches: NSSet!, withEvent event: UIEvent!) {

        let block: (SKNode!, CMutablePointer<ObjCBool>) -> Void = ({(node, stop) in

            if node.containsPoint(touches.anyObject().locationInNode(self)) {
                node.removeFromParent()
                self.removeChildrenInArray([self.childNodeWithName("text")])

                motionEnabled = !motionEnabled

                let newNode = SKSpriteNode(color: motionEnabled ? SKColor.greenColor() : SKColor.redColor(),
                    size: CGSizeMake(250, 100))
                newNode.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
                newNode.name = "button"

                let text = SKLabelNode(fontNamed: "Helvetica")
                text.text = motionEnabled ? "Disable Motion Control" : "Enable Motion Control"
                text.fontColor = SKColor.whiteColor()
                text.zPosition = newNode.zPosition + 1
                text.fontSize = 20
                text.name = "text"
                text.position = node.position
                text.position.y = text.position.y - 10

                self.addChild(text)
                self.addChild(newNode)
                return

            }

            })

        self.enumerateChildNodesWithName("button", usingBlock: block)

        let backButtonBlock: (SKNode!, CMutablePointer<ObjCBool>) -> Void = ({(node, stop) in
            if node.containsPoint(touches.anyObject().locationInNode(self)) {
                let transition = SKTransition.doorsCloseVerticalWithDuration(0.5)
                self.scene.view.presentScene(WelcomeScene(size: self.size), transition: transition)
            }
            })

        self.enumerateChildNodesWithName("back", usingBlock: backButtonBlock)


    }

    func makeStars() {

        let path = NSBundle.mainBundle().pathForResource("Stars", ofType: "sks")
        let stars: SKEmitterNode = NSKeyedUnarchiver.unarchiveObjectWithFile(path) as SKEmitterNode
        stars.particlePosition = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame))
        stars.particlePositionRange = CGVectorMake(CGRectGetWidth(self.frame), 0)
        stars.zPosition = -2
        self.addChild(stars)
        stars.advanceSimulationTime(10.0)

    }

}