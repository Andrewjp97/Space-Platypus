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

    /**
    *  Value of whether or not the scene content has been created yet
    */
    var contentCreated: Bool = false

    override func didMoveToView(view: SKView) {

        if !self.contentCreated {
            self.makeStars()
            self.backgroundColor = SKColor.blackColor()
            

            let buttonTuple = self.createButton()
            self.addChild(buttonTuple.button)
            self.addChild(buttonTuple.text)

            self.addChild(self.createBackButton())
            
            self.contentCreated = true
        }

    }

    /**
    *  Creates a fully formed instance of a back button text label
    *
    *  @return The fully formed back button label
    */
    func createBackButton() -> SKLabelNode {
        
        let backButton = SKLabelNode(fontNamed: "Helvetica")
        backButton.text = "Back"
        backButton.name = "back"
        backButton.fontColor = SKColor.whiteColor()
        backButton.fontSize = 24
        backButton.position = CGPointMake(10 + (0.5 * backButton.frame.size.width), CGRectGetMaxY(self.frame) - 20 - (0.5 * backButton.frame.size.height))
        
        return backButton
        
    }
    
    /**
    *  A Function to create a large button that's color dpends upon the global motion variable and whose text depends upon the global motion variable
    *
    *  @return The button portion of the button
    *  @return The text portion of the button
    */
    func createButton() -> (button: SKSpriteNode, text: SKLabelNode) {
        
        // If motion is enabled, make the button green.  Otherwise, make it red.

        let node = SKSpriteNode(color: motionEnabled ? SKColor.greenColor() : SKColor.redColor(),size: CGSizeMake(250, 100))
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
        
        return (node, text)
    }

    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {

        let block: (SKNode!, UnsafeMutablePointer<ObjCBool>) -> Void = ({(node, stop) in
            let touch = touches.anyObject() as UITouch
            if node.containsPoint(touch.locationInNode(self)) {
                node.removeFromParent()
                var name = "text"
                var arr = [name]
                self.removeChildrenInArray(arr)

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

        let backButtonBlock: (SKNode!, UnsafeMutablePointer<ObjCBool>) -> Void = ({(node, stop) in
            let touch = touches.anyObject() as UITouch
            if node.containsPoint(touch.locationInNode(self)) {
                let transition = SKTransition.doorsCloseVerticalWithDuration(0.5)
                self.scene?.view?.presentScene(WelcomeScene(size: self.size), transition: transition)
            }
            })

        self.enumerateChildNodesWithName("back", usingBlock: backButtonBlock)


    }

    /**
    *  Creates The Stars in the background
    */
    func makeStars() {

        let path = NSBundle.mainBundle().pathForResource("Stars", ofType: "sks")
        let stars: SKEmitterNode = NSKeyedUnarchiver.unarchiveObjectWithFile(path!) as SKEmitterNode
        stars.particlePosition = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame))
        stars.particlePositionRange = CGVectorMake(CGRectGetWidth(self.frame), 0)
        stars.zPosition = -2
        self.addChild(stars)
        stars.advanceSimulationTime(10.0)

    }

}