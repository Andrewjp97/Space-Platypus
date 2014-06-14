//
//  CustomizeScene.swift
//  Space Platypus Swift
//
//  Created by Andrew Paterson on 6/5/14.
//  Copyright (c) 2014 Andrew Paterson. All rights reserved.
//

import Foundation
import SpriteKit
import GameKit



class CustomizeScene: SKScene {

    var child: CustomizeScene?
    var parentScene: CustomizeScene?
    var platypusTypes: kPlatypusColor[] = []


    init(size: CGSize, platypusTypes: kPlatypusColor[], parent: CustomizeScene? = nil) {



        super.init(size: size)

        if let sceneParent = parent {
            self.parentScene = parent!
        }

        if platypusTypes.count > 6
        {
            var subarray: kPlatypusColor[] = []
            var counter: Int = 0
            for platypusType in platypusTypes {
                if counter < 6 {
                    counter++
                    self.platypusTypes.append(platypusType)
                } else {
                    subarray.append(platypusType)
                    counter++
                }
            }

            self.child = CustomizeScene(size: size, platypusTypes: subarray, parent: self)

        } else {
            self.platypusTypes = platypusTypes
        }

    }

    override func didMoveToView(view: SKView!) {

        self.layoutPlatapi()
        self.backgroundColor = SKColor.blackColor()
        self.makeStars()

        if self.child {
            let rightArrow = SKSpriteNode(imageNamed: "rightArrow")
            rightArrow.position = CGPointMake(CGRectGetMidX(self.frame) + 100, 50)
            self.addChild(rightArrow)
        }
        if self.parentScene {
            let leftArrow = SKSpriteNode(imageNamed: "leftArrow")
            leftArrow.position = CGPointMake(CGRectGetMidX(self.frame) - 100, 50)
            self.addChild(leftArrow)
        }

    }

    func layoutPlatapi() {
        var index = 0
        for type in self.platypusTypes {
            let node: SKSpriteNode = makePlatypus(type)
            switch index {
            case 0:
                node.position = CGPointMake(CGRectGetMidX(self.frame)-80, CGRectGetMidY(self.frame) + 150)
            case 1:
                node.position = CGPointMake(CGRectGetMidX(self.frame)+80, CGRectGetMidY(self.frame) + 150)
            case 2:
                node.position = CGPointMake(CGRectGetMidX(self.frame)-80, CGRectGetMidY(self.frame) + 30)
            case 3:
                node.position = CGPointMake(CGRectGetMidX(self.frame)+80, CGRectGetMidY(self.frame) + 30)
            case 4:
                node.position = CGPointMake(CGRectGetMidX(self.frame)-80, CGRectGetMidY(self.frame) - 90)
            case 5:
                node.position = CGPointMake(CGRectGetMidX(self.frame)+80, CGRectGetMidY(self.frame) - 90)
            default:
                node.position = CGPointZero
            }
            self.addChild(node)
            index++
        }

    }

    override func update(currentTime: NSTimeInterval) {

    }
    override func touchesBegan(touches: NSSet!, withEvent event: UIEvent!) {
        let block: (SKNode!, CMutablePointer<ObjCBool>) -> Void = ({(node, stop) in

            if node.containsPoint(touches.anyObject().locationInNode(self)) {
                self.highlightNode(node as PlatypusSprite)
            }
            })
        self.enumerateChildNodesWithName("PlatypusBody", usingBlock: block)
    }

    func highlightNode(node: PlatypusSprite) {
        if let color = node.type {
            platypusColor = color
        }
        let block: (SKNode!, CMutablePointer<ObjCBool>) -> Void = ({ (node, stop) in node.removeFromParent() })
        self.enumerateChildNodesWithName("selection", usingBlock: block)
        let selection = SKSpriteNode(imageNamed: "BackgroundSelected")
        selection.name = "selection"
        selection.position = node.position
        selection.position.y = selection.position.y - 20
        selection.zPosition = node.zPosition - 1
        self.addChild(selection)
    }

    func makeStars() {

        let path = NSBundle.mainBundle().pathForResource("Stars", ofType: "sks")
        let stars: SKEmitterNode = NSKeyedUnarchiver.unarchiveObjectWithFile(path) as SKEmitterNode
        stars.particlePosition = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame))
        stars.particlePositionRange = CGVectorMake(CGRectGetWidth(self.frame), 0)
        stars.zPosition = -2
        self.addChild(stars)
        stars.advanceSimulationTime(3.0)
        
    }

    func newEye() -> SKSpriteNode {

        let textures = [SKTexture(imageNamed: "EyeOpen"),
            SKTexture(imageNamed: "EyeBlinking1"),
            SKTexture(imageNamed: "EyeBlinking2"),
            SKTexture(imageNamed: "EyeBlinking3"),
            SKTexture(imageNamed: "EyeBlinking4"),
            SKTexture(imageNamed: "EyeBlinking5"),
            SKTexture(imageNamed: "EyeBlinking6"),
            SKTexture(imageNamed: "EyeBlinking7"),
            SKTexture(imageNamed: "EyeBlinking8"),
            SKTexture(imageNamed: "EyeBlinking9"),
            SKTexture(imageNamed: "EyeBlinking10"),
            SKTexture(imageNamed: "EyeBlinking11"),
            SKTexture(imageNamed: "EyeBlinking12"),
            SKTexture(imageNamed: "EyeBlinking13"),
            SKTexture(imageNamed: "EyeBlinking14"),
            SKTexture(imageNamed: "EyeBlinking15"),
            SKTexture(imageNamed: "EyeBlinking16"),
            SKTexture(imageNamed: "EyeBlinking17"),
            SKTexture(imageNamed: "EyeBlinking18"),
            SKTexture(imageNamed: "EyeBlinking19")]

        var light = SKSpriteNode(imageNamed: "EyeOpen")

        var blinkClose = SKAction.animateWithTextures(textures, timePerFrame: 0.005)

        var blink = SKAction.sequence([blinkClose, SKAction.waitForDuration(0.025),
            blinkClose.reversedAction(), SKAction.waitForDuration(3.0)])

        var blinkForever = SKAction.repeatActionForever(blink)

        light.runAction(blinkForever)
        
        return  light
        
    }

    func makePlatypus(type: kPlatypusColor) -> SKSpriteNode{

        let imageName = imageNameForPlatypusColor(type)
        var platypusBody = PlatypusSprite(imageNamed: imageName)
        platypusBody.name = "PlatypusBody"
        platypusBody.type = type
        platypusBody.physicsBody = SKPhysicsBody(texture: platypusBody.texture, size: platypusBody.size)
        platypusBody.physicsBody.dynamic = false
//        platypusBody.physicsBody.contactTestBitMask = ColliderType.Rock.toRaw() | ColliderType.Life.toRaw()
//        platypusBody.physicsBody.categoryBitMask = ColliderType.Platypus.toRaw()
//        platypusBody.physicsBody.collisionBitMask = ColliderType.Rock.toRaw()
        if type == kPlatypusColor.kPlatypusColorFire {

            let path = NSBundle.mainBundle().pathForResource("bodyOnFire", ofType: "sks")
            let flame: SKEmitterNode = NSKeyedUnarchiver.unarchiveObjectWithFile(path) as SKEmitterNode
            flame.position = platypusBody.position
            flame.zPosition = 9
            platypusBody.addChild(flame)

        }


        let eyeOne = newEye()
        eyeOne.position = CGPointMake(-10, 16)
        eyeOne.zPosition = 100
        platypusBody.addChild(eyeOne)

        let eyeTwo = newEye()
        eyeTwo.position = CGPointMake(10, 16)
        eyeTwo.zPosition = 100
        platypusBody.addChild(eyeTwo)

        let path = NSBundle.mainBundle().pathForResource("MyParticle", ofType: "sks")
        let exhaust: SKEmitterNode = NSKeyedUnarchiver.unarchiveObjectWithFile(path) as SKEmitterNode
        exhaust.position = CGPointMake(0, -32)
        platypusBody.addChild(exhaust)

        platypusBody.position = CGPointMake(self.frame.size.width / 2, self.frame.size.height - 100)
        
        return platypusBody
        
        
    }

}

