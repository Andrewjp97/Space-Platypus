//
//  WelcomeScene.swift
//  Space Platypus Swift
//
//  Created by Andrew Paterson on 6/4/14.
//  Copyright (c) 2014 Andrew Paterson. All rights reserved.
//

import SpriteKit
import GameKit


enum kMeunItemType: Int {
    case kMenuItemTypePlay = 1, //Play Butten
    kMenuItemTypeCustomize,  //Customize Button
    kMenuItemTypeScores,  //Scores Button, brings up game center view
    kMenuItemTypeAchievements,  //Achievments Button, brings up game center view
    kMenuItemTypeOptions,  //Options Button
    kMenuItemTypeInvalid  //Touch is outside valid range
}

var lastRandom: Double = 0

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
    var midScreenY: CGFloat = 0.0
    var color: kPlatypusColor = platypusColor
    var counter: Int = 0

    init(size: CGSize) {
        super.init(size: size)
        self.midScreenY = CGRectGetMidY(self.frame)
    }

    enum ColliderType: UInt32 {
        case Rock = 1
        case Life = 2
        case Platypus = 4
        case Gravity = 8
        case Shield = 16
    }




    override func didMoveToView(view: SKView) {

        if !contentCreated {

            self.createSceneContent()
            contentCreated = true

            UIApplication.sharedApplication().statusBarStyle = .LightContent
            self.view.userInteractionEnabled = true

            self.physicsWorld.contactDelegate = self

        }

  }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */

        let point = touches.anyObject().locationInNode(self)

        let menuItemType = whatMenuItemTypeIsAtPoint(point)

        switch menuItemType {

            case .kMenuItemTypePlay:
                let helloNode = self.childNodeWithName("HelloNode")
                if helloNode != nil {
                    helloNode.name = nil
                    let zoom = SKAction.scaleTo(0.05, duration: 0.5)
                    let fade = SKAction.fadeOutWithDuration(0.5)
                    let remove = SKAction.removeFromParent()
                    let sequence = SKAction.sequence([zoom, fade, remove])
                    helloNode.runAction(sequence, completion: ({
                        let scene = GameScene(size: self.size)
                        let doors = SKTransition.doorsOpenVerticalWithDuration(0.5)
                        self.view.presentScene(scene, transition: doors)
                        }))
                }
            case .kMenuItemTypeCustomize:
                let scene = CustomizeScene(size: self.size,
                    platypusTypes: [.kPlatypusColorDefault, .kPlatypusColorRed, .kPlatypusColorYellow,
                                    .kPlatypusColorGreen, .kPlatypusColorPurple, .kPlatypusColorPink,
                                    .kPlatypusColorDareDevil, .kPlatypusColorSanta, .kPlatypusColorElf,
                                    .kPlatypusColorChirstmasTree, .kPlatypusColorRaindeer, .kPlatypusColorFire])
                
                let doors = SKTransition.doorsOpenVerticalWithDuration(0.5)
                self.view.presentScene(scene, transition: doors)
            case .kMenuItemTypeScores:
                self.showLeaderboard()
            case .kMenuItemTypeAchievements:
                self.showAchievements()
            case .kMenuItemTypeOptions:
                let scene = OptionsScene(size: self.size)
                let doors = SKTransition.doorsOpenVerticalWithDuration(0.5)
                self.view.presentScene(scene, transition: doors)
            case .kMenuItemTypeInvalid:
                return

        }

    }

    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */

    }

    override func didSimulatePhysics() {

        let completionBlock: (SKNode!, CMutablePointer<ObjCBool>) -> Void = {incoming, stop in

            if let node = incoming {

                if node.position.y < 0 || node.position.y > CGRectGetMaxY(self.frame) + 100 || node.position.x < 0 || node.position.x > CGRectGetMaxX(self.frame) {

                    node.removeFromParent()

                }
            }
        }

        self.enumerateChildNodesWithName("rock", usingBlock: completionBlock)

    }

    func didBeginContact(contact: SKPhysicsContact!) {

    }

    func didEndContact(contact: SKPhysicsContact!)
    {

    }

    



    func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController!) {

        self.view.window.rootViewController.dismissViewControllerAnimated(true, completion: nil)

    }

    func createSceneContent() {

        self.backgroundColor = SKColor.blackColor()
        self.scaleMode = SKSceneScaleMode.AspectFit

        self.makeStars()
        self.makeMenuNodes()
        self.makePlatypus()
        self.playSpaceship()
        self.addRocks()

    }

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
        platypus.runAction(repeat)
        
    }

    func addRock() {
        let rock = SKSpriteNode(color: SKColor(red: 0.67647, green:0.51568, blue:0.29216, alpha:1.0), size: CGSizeMake(8, 8))

        let width: CGFloat = CGRectGetWidth(self.frame)
        let widthAsDouble: Double = width.bridgeToObjectiveC().doubleValue
        let randomNum = randomNumberFunction(widthAsDouble)
        let randomNumAsCGFloat: CGFloat = randomNum.CGFloatValue
        let point = CGPointMake(randomNumAsCGFloat, CGRectGetHeight(self.frame))

        rock.position = point
        rock.name = "rock"
        rock.physicsBody = SKPhysicsBody(rectangleOfSize: rock.size)
        rock.physicsBody.usesPreciseCollisionDetection = true
        rock.physicsBody.categoryBitMask = ColliderType.Rock.toRaw()
        rock.physicsBody.contactTestBitMask = ColliderType.Rock.toRaw() | ColliderType.Shield.toRaw()
        rock.physicsBody.collisionBitMask = ColliderType.Rock.toRaw() | ColliderType.Platypus.toRaw()

        self.addChild(rock)
        rock.physicsBody.applyImpulse(CGVectorMake(0, -0.75))


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

    func showLeaderboard() {

        let controller = GKGameCenterViewController()
        controller.gameCenterDelegate = self;
        controller.viewState = .Leaderboards
        self.view.window.rootViewController.presentModalViewController(controller, animated: true)

    }

    func showAchievements() {

        let controller = GKGameCenterViewController()
        controller.gameCenterDelegate = self
        controller.viewState  = .Achievements
        self.view.window.rootViewController.presentModalViewController(controller, animated: true)

    }

    func makePlatypus() {

        let imageName = imageNameForPlatypusColor(color)
        var platypusBody = SKSpriteNode(imageNamed: imageName)
        platypusBody.name = "PlatypusBody"

        platypusBody.physicsBody = SKPhysicsBody(texture: platypusBody.texture, size: platypusBody.size)
        platypusBody.physicsBody.dynamic = false
        platypusBody.physicsBody.contactTestBitMask = ColliderType.Rock.toRaw() | ColliderType.Life.toRaw()
        platypusBody.physicsBody.categoryBitMask = ColliderType.Platypus.toRaw()
        platypusBody.physicsBody.collisionBitMask = ColliderType.Rock.toRaw()
        if color == kPlatypusColor.kPlatypusColorFire {

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

        self.addChild(platypusBody)


    }

    func addRocks() {
        if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Phone {
            let duration = 0.10
            let makeRocks = SKAction.runBlock({self.addRock()})
            let delay = SKAction.waitForDuration(duration)
            let sequence = SKAction.sequence([makeRocks, delay])
            let repeat = SKAction.repeatActionForever(sequence)

            self.runAction(repeat)
        }
    }

    func whatMenuItemTypeIsAtPoint(point: CGPoint) -> kMeunItemType {

        if point.y.CGFloatValue > (midScreenY - 54.0) && point.y.CGFloatValue < (midScreenY - 18.0) {
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












