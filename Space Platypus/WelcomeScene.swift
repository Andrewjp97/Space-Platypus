//
//  WelcomeScene.swift
//  Space Platypus Swift
//
//  Created by Andrew Paterson on 6/4/14.
//  Copyright (c) 2014 Andrew Paterson. All rights reserved.
//

import SpriteKit
import GameKit
import iAd

/**
*  The enumeration for the different menu item types
*/
enum kMeunItemType: Int {
    case kMenuItemTypePlay = 1, //Play Butten
    kMenuItemTypeCustomize,  //Customize Button
    kMenuItemTypeScores,  //Scores Button, brings up game center view
    kMenuItemTypeAchievements,  //Achievments Button, brings up game center view
    kMenuItemTypeOptions,  //Options Button
    kMenuItemTypeInvalid  //Touch is outside valid range
}

/**
*  The enumeration for the collision types
*/
enum ColliderType: UInt32 {
    case Rock = 1
    case Life = 2
    case Platypus = 4
    case Gravity = 8
    case Shield = 16
}


var lastRandom: Double = 0

/**
*  A random number generator
*
*  @param Double The Maximum allowable value
*
*  @return The random number
*/
func randomNumberFunction(max: Double) -> Double {
    if lastRandom == 0 {
        lastRandom = NSDate.timeIntervalSinceReferenceDate()
    }
    var newRand =  ((lastRandom * M_PI) * 11048.6954) % max
    lastRandom = newRand
    return newRand
}

class WelcomeScene: SKScene, SKPhysicsContactDelegate, GKGameCenterControllerDelegate {
    
    var contentCreated: Bool = false
    
   
    
    override init(size: CGSize) {
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    

    
    
    
    override func didMoveToView(view: SKView) {
        
        if !contentCreated {
            
            self.createSceneContent()
            contentCreated = true
            
            UIApplication.sharedApplication().statusBarStyle = .LightContent
            self.view?.userInteractionEnabled = true
            
            self.physicsWorld.contactDelegate = self
            
        }
        
        // Prepare banner Ad
        
        
        
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
        let touch = touches.anyObject() as UITouch
        let point = touch.locationInNode(self)
        
        let menuItemType = whatMenuItemTypeIsAtPoint(point)
        
        switch menuItemType {
            
        case .kMenuItemTypePlay:
            let helloNode = self.childNodeWithName("HelloNode")
            if helloNode != nil {
                helloNode?.name = nil
                let zoom = SKAction.scaleTo(0.05, duration: 0.5)
                let fade = SKAction.fadeOutWithDuration(0.5)
                let remove = SKAction.removeFromParent()
                let sequence = SKAction.sequence([zoom, fade, remove])
                helloNode?.runAction(sequence, completion: ({
                    let scene = GameScene(size: self.size)
                    let doors = SKTransition.doorsOpenVerticalWithDuration(0.5)
                    self.view?.presentScene(scene, transition: doors)
                }))
            }
        case .kMenuItemTypeCustomize:
            let scene = CustomizeScene(size: self.size,
                platypusTypes: [.kPlatypusColorDefault, .kPlatypusColorRed, .kPlatypusColorYellow,
                    .kPlatypusColorGreen, .kPlatypusColorPurple, .kPlatypusColorPink,
                    .kPlatypusColorDareDevil, .kPlatypusColorSanta, .kPlatypusColorElf,
                    .kPlatypusColorChirstmasTree, .kPlatypusColorRaindeer, .kPlatypusColorFire])
            
            let doors = SKTransition.doorsOpenVerticalWithDuration(0.5)
            self.view?.presentScene(scene, transition: doors)
        case .kMenuItemTypeScores:
            self.showLeaderboard()
        case .kMenuItemTypeAchievements:
                self.showAchievements()
            case .kMenuItemTypeOptions:
                let scene = OptionsScene(size: self.size)
                let doors = SKTransition.doorsOpenVerticalWithDuration(0.5)
                self.view?.presentScene(scene, transition: doors)
            case .kMenuItemTypeInvalid:
                return

        }

    }

    /**
    *  Checks for rocks offscreen and removes them
    *
    *  @return Void
    */
    override func didSimulatePhysics() {

        let completionBlock: (SKNode!, UnsafeMutablePointer<ObjCBool>) -> Void = {incoming, stop in

            if let node = incoming {

                if node.position.y < 0 || node.position.y > CGRectGetMaxY(self.frame) + 100 || node.position.x < 0 || node.position.x > CGRectGetMaxX(self.frame) {

                    node.removeFromParent()

                }
            }
        }

        self.enumerateChildNodesWithName("rock", usingBlock: completionBlock)

    }

    /**
    *  The Game Center Delegate Callback Method: Called when the controller is dismissed
    *
    *  @param GKGameCenterViewController! The controller being dismissed
    *
    *  @return Void
    */
    func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController!) {

        self.view?.window?.rootViewController?.dismissViewControllerAnimated(true, completion: nil)

    }

    /**
    *  Creates the scene content
    *
    *  @return Void
    */
    func createSceneContent() {

        self.backgroundColor = SKColor.blackColor()
        self.scaleMode = SKSceneScaleMode.AspectFit

        self.makeStars()
        self.makeMenuNodes()
        
        let platypus = PlatypusNode(type: platypusColor)
        platypus.position  = CGPointMake(self.frame.size.width / 2, self.frame.size.height - 100)
        self.addChild(platypus)
        
        self.playSpaceship()
        self.addRocks()

    }

    /**
    *  Runs a sequence of actions that move the platypus around on the scene
    *
    *  @return Void
    */
    func playSpaceship() {

        let action1 = SKAction.moveBy(CGVectorMake(85, 10.0), duration: 0.5)
        let action2 = SKAction.moveBy(CGVectorMake(-50.0, -50.0), duration: 1.0)
        let action3 = SKAction.moveBy(CGVectorMake(-130.0, -50.0), duration: 0.75)
        let action4 = SKAction.moveBy(CGVectorMake(-5.0, 30.0), duration: 0.75)
        let action5 = SKAction.moveBy(CGVectorMake(75.0, 20.0), duration: 0.5)
        let action6 = SKAction.moveBy(CGVectorMake(35.0, 25.0), duration: 1.0)
        let action7 = SKAction.moveBy(CGVectorMake(10.0, -10.0), duration: 0.5)
        let action8 = SKAction.moveBy(CGVectorMake(55.0, 50.0), duration: 0.25)
        let sequence = SKAction.sequence([action1, action2, action3, action4,
                                          action5, action6, action7, action6,
                                          action5, action4, action3, action2, action8])
        let repeat = SKAction.repeatActionForever(sequence)

        let platypus = self.childNodeWithName("PlatypusBody")
        platypus?.runAction(repeat)
        
    }

    /**
    *  Creates and adds a rock to the scene at a random point along the top of the screen and applies an impulse to it
    *
    *  @return Void
    */
    func addRock() {
        let rock = SKSpriteNode(color: SKColor(red: 0.67647, green:0.51568, blue:0.29216, alpha:1.0), size: CGSizeMake(8, 8))

        let width: CGFloat = CGRectGetWidth(self.frame)
        let widthAsDouble: Double = Double(width)
        let randomNum = randomNumberFunction(widthAsDouble)
        let randomNumAsCGFloat: CGFloat = randomNum.CGFloatValue
        let point = CGPointMake(randomNumAsCGFloat, CGRectGetHeight(self.frame))

        rock.position = point
        rock.name = "rock"
        rock.physicsBody = SKPhysicsBody(rectangleOfSize: rock.size)
        rock.physicsBody?.usesPreciseCollisionDetection = true
        rock.physicsBody?.categoryBitMask = ColliderType.Rock.rawValue
        rock.physicsBody?.contactTestBitMask = ColliderType.Rock.rawValue | ColliderType.Shield.rawValue
        rock.physicsBody?.collisionBitMask = ColliderType.Rock.rawValue | ColliderType.Platypus.rawValue
        self.addChild(rock)
        rock.physicsBody?.applyImpulse(CGVectorMake(0, -0.75))


    }

    /**
    *  Creates the stars in the scene's background
    *
    *  @return Void
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

    /**
    *  Creates the menu nodes for the scene
    *
    *  @return Void
    */
    func makeMenuNodes() {

        var helloNode = SKLabelNode()
        helloNode.fontName = "Menlo-BoldItalic"
        helloNode.text = "Space Platypus"
        helloNode.fontSize = 36
        helloNode.position = CGPointMake(CGRectGetMidX(self.frame) + 5, CGRectGetMidY(self.frame) - 5)
        helloNode.name = "HelloNode"
        helloNode.zPosition = 19
        helloNode.fontColor = SKColor.darkGrayColor()

        var helloNode1 = SKLabelNode()
        helloNode1.fontName = "Menlo-BoldItalic"
        helloNode1.text = "Space Platypus"
        helloNode1.fontSize = 36
        helloNode1.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
        helloNode1.name = "HelloNode"
        helloNode1.zPosition = 20

        var playNode = SKLabelNode()
        playNode.fontName = "Helvetica"
        playNode.text = "Play"
        playNode.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) - 36)
        playNode.fontColor = SKColor.redColor()
        playNode.zPosition = 20

        var customizeNode = SKLabelNode()
        customizeNode.fontName = "Helvetica"
        customizeNode.text = "Customize"
        customizeNode.fontColor = SKColor.yellowColor()
        customizeNode.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) - 72)
        customizeNode.zPosition = 20

        var scoreNode = SKLabelNode()
        scoreNode.fontName = "Helvetica"
        scoreNode.text = "Scores"
        scoreNode.fontColor = SKColor.greenColor()
        scoreNode.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) - 108)
        scoreNode.zPosition = 20

        var achievementNode = SKLabelNode()
        achievementNode.fontName = "Helvetica"
        achievementNode.text = "Achievements"
        achievementNode.fontColor = SKColor.blueColor()
        achievementNode.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) - 144)
        achievementNode.zPosition = 20

        var optionsNode = SKLabelNode()
        optionsNode.fontName = "Helvetica"
        optionsNode.text = "Options"
        optionsNode.fontColor = SKColor.purpleColor()
        optionsNode.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) - 180)
        optionsNode.zPosition = 20

        self.addChild(optionsNode)
        self.addChild(achievementNode)
        self.addChild(scoreNode)
        self.addChild(customizeNode)
        self.addChild(playNode)
        self.addChild(helloNode1)
        self.addChild(helloNode)

    }

    /**
    *  Shows the Game Center Leaderboards
    *
    *  @return Void
    */
    func showLeaderboard() {

        let controller = GKGameCenterViewController()
        controller.gameCenterDelegate = self;
        controller.viewState = .Leaderboards
        self.view?.window?.rootViewController?.presentViewController(controller, animated: true, completion: nil)

    }

    /**
    *  Shows the Game Center Achievments
    *
    *  @return Void
    */
    func showAchievements() {

        let controller = GKGameCenterViewController()
        controller.gameCenterDelegate = self
        controller.viewState  = .Achievements
        self.view?.window?.rootViewController?.presentViewController(controller, animated: true, completion: nil)

    }

    /**
    *  Creates the falling rocks in the scene: creates a repeating action to make rocks
    *
    *  @return Void
    */
    func addRocks() {
        
            let duration = 0.10
            let makeRocks = SKAction.runBlock({self.addRock()})
            let delay = SKAction.waitForDuration(duration)
            let sequence = SKAction.sequence([makeRocks, delay])
            let repeat = SKAction.repeatActionForever(sequence)

            self.runAction(repeat)
        
    }

    /**
    *  Determines what, if any menu item is at the given point
    *
    *  @param CGPoint The point to check
    *
    *  @return The type of menu item present, returns kMenuItemTypeInvalid if no menu item is present at the given point
    */
    func whatMenuItemTypeIsAtPoint(point: CGPoint) -> kMeunItemType {

        let midScreenY = CGRectGetMidY(self.frame)
        
        if point.y > (midScreenY - 54.0) && point.y < (midScreenY - 18.0) {
            return .kMenuItemTypePlay
        } else if point.y > (midScreenY - 90) && point.y < (midScreenY - 54) {
            return .kMenuItemTypeCustomize
        } else if point.y > (midScreenY - 126) && point.y < (midScreenY - 90) {
            return .kMenuItemTypeScores
        } else if point.y > (midScreenY - 162) && point.y < (midScreenY - 126) {
            return .kMenuItemTypeAchievements
        } else if point.y > (midScreenY - 198) && point.y < (midScreenY - 162) {
            return .kMenuItemTypeOptions
        } else {
            return .kMenuItemTypeInvalid
        }
    }

}












