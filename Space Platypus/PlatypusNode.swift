//
//  PlatypusNode.swift
//  Space Platypus
//
//  Created by Andrew Paterson on 6/21/14.
//  Copyright (c) 2014 Karl Paterson. All rights reserved.
//

import UIKit
import SpriteKit

class PlatypusNode: SKSpriteNode {
    
    /**
    *  The Type of the Platypus, is an optional value
    */
    var type: kPlatypusColor?
    
    /**
    *  Designated Initializer for a PlatypusNode
    *
    *  @param The Type of PlatypusNode to be made, changes the image displayed and any special effects
    */
    init(type: kPlatypusColor) {
        
        super.init(imageNamed: imageNameForPlatypusColor(type))
        
        self.type = type
        
        self.name = "PlatypusBody"
        
        self.physicsBody = SKPhysicsBody(texture: self.texture, size: self.size)
        self.physicsBody.dynamic = false
        self.physicsBody.contactTestBitMask = ColliderType.Rock.toRaw() | ColliderType.Life.toRaw()
        self.physicsBody.categoryBitMask = ColliderType.Platypus.toRaw()
        self.physicsBody.collisionBitMask = ColliderType.Rock.toRaw()
        
        if type == kPlatypusColor.kPlatypusColorFire {
            
            let path = NSBundle.mainBundle().pathForResource("bodyOnFire", ofType: "sks")
            let flame: SKEmitterNode = NSKeyedUnarchiver.unarchiveObjectWithFile(path) as SKEmitterNode
            flame.position = self.position
            flame.zPosition = 9
            self.addChild(flame)
            
        }
        
        let eyeOne = newEye()
        eyeOne.position = CGPointMake(-10, 16)
        eyeOne.zPosition = 100
        self.addChild(eyeOne)
        
        let eyeTwo = newEye()
        eyeTwo.position = CGPointMake(10, 16)
        eyeTwo.zPosition = 100
        self.addChild(eyeTwo)
        
        let path = NSBundle.mainBundle().pathForResource("MyParticle", ofType: "sks")
        let exhaust: SKEmitterNode = NSKeyedUnarchiver.unarchiveObjectWithFile(path) as SKEmitterNode
        exhaust.position = CGPointMake(0, -32)
        self.addChild(exhaust)

    }
    
    /**
    *  Creates a new eye, complete with blinking animation action
    *
    *  @return An SKSpriteNode that is an eye and blinks
    */
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

}
