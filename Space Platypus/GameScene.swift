//
//  GameScene.swift
//  Space Platypus Swift
//
//  Created by Andrew Paterson on 6/5/14.
//  Copyright (c) 2014 Andrew Paterson. All rights reserved.
//

import Foundation
import SpriteKit
import GameKit
import CoreMotion

class GameScene: SKScene, SKPhysicsContactDelegate, TimerDelegate {

    var contentCreated = false
    var seconds = 0
    var stars: SKEmitterNode
    var running = true
    var invincible = false
    var hits: Int = 0 {
    didSet {
        if hits < 0 {
            hits = 0
        }
        if hits == 0 {
            let node = self.childNodeWithName("lifeBar") as SKSpriteNode
            node.texture = SKTexture(imageNamed: "LifeBarFull")
        }
        if hits == 1 {
            let node = self.childNodeWithName("lifeBar") as SKSpriteNode
            node.texture = SKTexture(imageNamed: "LifeBarTwo")
        }
        if hits == 2 {
            let node = self.childNodeWithName("lifeBar") as SKSpriteNode
            node.texture = SKTexture(imageNamed: "LifeBarOne")
        }
        if hits == 3 {
            let node = self.childNodeWithName("lifeBar") as SKSpriteNode
            node.texture = SKTexture(imageNamed: "LifeBarEmpty")
        }
        if hits > 3 {
            self.slowMotion = false
            self.gameOver()
        }
    }
    }
    var leaderboards: [AnyObject] = []
    var shouldAcceptFurtherCollisions = true
    var shouldMakeMoreRocks = true
    var level = 0
    var achievementsDictionary = [:]
    var motionManager: CMMotionManager?
    var impulseSlower = false
    var timer: Timer = Timer()
    var timerLabel: SKLabelNode
    var slowMotion: Bool = false {
        willSet {
            if newValue == false {
                self.removeSlowMotion()
            }
            else {
                self.addSlowMotion()
            }
        }
    }

    /**
    *  Handles returning the scene to it's normal state
    *
    *  @return Void
    */
    func removeSlowMotion() {
        self.timer.removeAllActions()
        self.timer.scale = 1.0
        self.timer.start()
        let action = SKAction.runBlock({
            self.enumerateChildNodesWithName("slow", usingBlock: ({(node, stop) in
            node.alpha = node.alpha - 0.4
            }))
            })
        
        let repeat = SKAction.repeatAction(SKAction.sequence([action, SKAction.waitForDuration(0.025)]), count: 10)
        self.runAction(repeat)
        let block: (SKNode!, UnsafeMutablePointer<ObjCBool>) -> Void = ({(node, stop) in
            
            if let node = node as? SKSpriteNode {
                let origional = node.physicsBody
                node.physicsBody = nil
                node.physicsBody = SKPhysicsBody(rectangleOfSize: node.size)
                node.physicsBody?.categoryBitMask = origional!.categoryBitMask
                node.physicsBody?.categoryBitMask = origional!.categoryBitMask
                node.physicsBody?.contactTestBitMask = origional!.contactTestBitMask
                node.physicsBody?.applyImpulse(CGVectorMake(0, -0.75 * (self.impulseSlower ? 0.5 : 1.0) * (1.0 + (self.seconds.CGFloatValue / 100.0))))
            }
            
            })
        self.enumerateChildNodesWithName("rock", usingBlock: block)
        self.enumerateChildNodesWithName("life", usingBlock: block)
        self.enumerateChildNodesWithName("gravity", usingBlock: block)
        self.enumerateChildNodesWithName("invincible", usingBlock: block)
        self.physicsWorld.gravity = CGVectorMake(0, self.physicsWorld.gravity.dy * 20)
        
        

    
    }
    
    /**
    *  Handles the implementaion of slowing down the scene and overlaying a transparent node
    *
    *  @return Void
    */
    func addSlowMotion(){
        self.timer.scale = 8.0
        let node = SKSpriteNode(color: SKColor(white: 0.1, alpha: 0.6), size: self.size)
        node.alpha = 0.0
        node.name = "slow"
        node.anchorPoint = CGPointZero
        node.zPosition = 1000
        let action = SKAction.runBlock({
            let node = self.childNodeWithName("slow") as SKSpriteNode
            node.alpha = node.alpha + 0.2
            })
        let repeat = SKAction.repeatAction(SKAction.sequence([action, SKAction.waitForDuration(0.05)]), count: 20)
        self.addChild(node)
        node.runAction(repeat)
        let block: (SKNode!, UnsafeMutablePointer<ObjCBool>) -> Void = ({(node, stop) in
            if let node = node as? SKSpriteNode {
            let origional = node.physicsBody
                node.physicsBody = nil
                node.physicsBody = SKPhysicsBody(rectangleOfSize: node.size)
                node.physicsBody?.categoryBitMask = origional!.categoryBitMask
                node.physicsBody?.collisionBitMask = origional!.collisionBitMask
                node.physicsBody?.contactTestBitMask = origional!.contactTestBitMask
                node.physicsBody?.applyImpulse(CGVectorMake(0, -0.125 * (self.impulseSlower ? 0.5 : 1.0) * (1.0 + (self.seconds.CGFloatValue / 100.0))))
            }
            
            
            })
        self.enumerateChildNodesWithName("rock", usingBlock: block)
        self.enumerateChildNodesWithName("life", usingBlock: block)
        self.enumerateChildNodesWithName("gravity", usingBlock: block)
        self.enumerateChildNodesWithName("invincible", usingBlock: block)
        self.physicsWorld.gravity = CGVectorMake(0, self.physicsWorld.gravity.dy * 0.05)
        
    }

    override init(size: CGSize) {

        self.timerLabel  = SKLabelNode(fontNamed: "Helvetica")
        self.timerLabel.text = "0:00"
        self.stars = SKEmitterNode()
        super.init(size: size)
        self.stars = makeStars()
        self.addChild(self.stars)


    }

    required init?(coder aDecoder: NSCoder) {
        self.stars = SKEmitterNode()
        self.timerLabel = SKLabelNode()
        super.init(coder: aDecoder)
        
    }

    func timerDidChangeTime(value: Int, valueString: String) {
        self.seconds = value
        let string = value % 60 < 10 ? "0\(value % 60)" : "\(value % 60)"
        self.timerLabel.text = "\(value / 60):\(string)"
        self.timerLabel.position = CGPointMake(10 + (0.5 * self.timerLabel.frame.size.width), self.frame.size.height - 20 - (0.5 * self.timerLabel.frame.size.height))
        NSLog(valueString)
        NSLog(self.timerLabel.text)
        NSLog("\(self.timerLabel.position)")
    }

    override func didMoveToView(view: SKView) {

        if !contentCreated {

            self.timer.delegate = self
            self.addChild(self.timer)
            self.timerLabel.zPosition = 500
            self.backgroundColor = SKColor.blackColor()
            self.timerLabel.fontSize = 24
            self.timerLabel.fontColor = SKColor.whiteColor()
            self.timerLabel.position = CGPointMake(10 + (0.5 * self.timerLabel.frame.size.width), self.frame.size.height - 20 - (0.5 * self.timerLabel.frame.size.height))
            self.addChild(self.timerLabel)


            if motionEnabled {
                motionManager = CMMotionManager()
                motionManager!.startAccelerometerUpdates()
            }
            createSceneContent()
            contentCreated = true

            self.physicsWorld.contactDelegate = self
            // Minimum gravity needed to allow rocks that are collided with to continue off screen
            self.physicsWorld.gravity = CGVectorMake(0, -1.5)

            loadAchievements()
            loadLeaderboardInfo()

        }
    }

    /**
    *  Processes the motion from the accelerometer
    *
    *  @param NSTimeInterval The time interval since the last update
    *
    *  @return Void
    */
    func processUserMotionForUpdate(currentTimeInterval: NSTimeInterval) {
        
        if self.shouldAcceptFurtherCollisions {
            let ship = self.childNodeWithName("PlatypusBody")
            let data = self.motionManager?.accelerometerData

            if let datas = data {

                let positionY: Double = Double(ship!.position.y)
                let positionX: Double = Double(ship!.position.x)
                let accelerometerX: Double = datas.acceleration.x as Double * 15.0
                let accelerometerY: Double = datas.acceleration.y as Double * 15.0
                let height: Double = Double(CGRectGetMaxY(self.frame))
                let width: Double = Double(CGRectGetMaxX(self.frame))
                
                let horizontalNotNegative: Bool = positionX + accelerometerX >= 0.0
                let horizontalNotPastScreen: Bool = positionX + accelerometerX <= width
                let verticalNotNegative: Bool = positionY + accelerometerY >= 0.0
                let verticalNotPastScreen: Bool = positionY + accelerometerY <= height

                let horizontal: Bool = horizontalNotNegative && horizontalNotPastScreen
                let vertical: Bool = verticalNotNegative && verticalNotPastScreen

                if horizontal && vertical {

                    let newX = positionX + accelerometerX
                    let newY = positionY + accelerometerY

                    let newPostion = CGPointMake(newX.CGFloatValue, newY.CGFloatValue)

                    ship?.position = newPostion

                }
            }
        }
    }

    /**
    *  Creates the Scenes content
    *
    *  @return Void
    */
    func createSceneContent() {

        let platypus = PlatypusNode(type: platypusColor)
        platypus.position = CGPointMake(self.frame.size.width / 2, 100)
        self.addChild(platypus)
        
        self.addRocks()
        self.timer.start()
        let makeRocks = SKAction.runBlock({self.addPowerup()})
        let delay = SKAction.waitForDuration(10.0, withRange: 5.0)
        let sequence = SKAction.sequence([delay, makeRocks])
        let repeat = SKAction.repeatActionForever(sequence)
        
        self.runAction(repeat)
        self.makeLifeBar()
        
    }

    /**
    *  Creates the life bar and displays it on screen
    *
    *  @return Void
    */
    func makeLifeBar() {

        let node = SKSpriteNode(imageNamed: "LifeBarFull")
        node.name = "lifeBar"
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            //let width: CGFloat = self.view?.window?.frame.size.width!
            //let height: CGFloat = self.view?.window?.frame.size.height!
            if let view = self.view {
                if let window = view.window {
                    let width = window.frame.width
                    let height = window.frame.height
                    node.position = CGPointMake(width - 70, height - 15)
                }
            }
            
            
        } else {
            if let view = self.view {
                if let window = view.window {
                    let width = window.frame.width
                    let height = window.frame.height
                    node.position = CGPointMake(width - 70, height - 35)
                }
            }
            
        }
        self.addChild(node)

    }

    override func didSimulatePhysics() {

        let block: (SKNode!, UnsafeMutablePointer<ObjCBool>) -> Void = ({(node, stop) in
            if node.position.x > self.frame.width + 10 || node.position.x < -10 || node.position.y < -10 {
                node.removeFromParent()
            }
            })

        self.enumerateChildNodesWithName("rock", usingBlock: block)

    }

    override func update(currentTime: NSTimeInterval) {

        if motionEnabled {
            self.processUserMotionForUpdate(currentTime)
        }

    }

    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {

        super.touchesBegan(touches, withEvent: event)

        if self.slowMotion {
            self.slowMotion = false
        }
        
        if motionEnabled {
            return
        }

        if self.shouldAcceptFurtherCollisions {

            let hull = self.childNodeWithName("PlatypusBody")
            let touch: UITouch = touches.anyObject() as UITouch
            let move = SKAction.moveTo(CGPointMake(touch.locationInNode(self).x, touch.locationInNode(self).y + 50), duration:0.05);

            hull?.runAction(move)

        }

    }

    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {

        super.touchesMoved(touches, withEvent: event)

        if motionEnabled {
            return
        }

        if self.shouldAcceptFurtherCollisions {

            let hull = self.childNodeWithName("PlatypusBody")
            let touch: UITouch = touches.anyObject() as UITouch
            let move = SKAction.moveTo(CGPointMake(touch.locationInNode(self).x, touch.locationInNode(self).y + 50), duration:0.05);

            hull?.runAction(move)

        }

    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        if self.shouldAcceptFurtherCollisions && !motionEnabled {
            self.slowMotion = true
        }
    }

    /**
    *  Creates an individual rock and applys an impulse to it
    *
    *  @return Void
    */
    func addRock() {
        let rock = SKSpriteNode(color: SKColor(red: 0.67647, green:0.51568, blue:0.29216, alpha:1.0), size: CGSizeMake(8, 8))

        let width: CGFloat = CGRectGetWidth(self.frame)
        let widthAsDouble: Double = Double(width)
        let randomNum = randomNumberFunction(widthAsDouble)
        let randomNumAsCGFloat: CGFloat = CGFloat(randomNum)
        let point = CGPointMake(randomNumAsCGFloat, CGRectGetHeight(self.frame))

        rock.position = point
        rock.name = "rock"
        rock.physicsBody = SKPhysicsBody(rectangleOfSize: rock.size)
        rock.physicsBody?.usesPreciseCollisionDetection = true
        rock.physicsBody?.categoryBitMask = ColliderType.Rock.rawValue
        rock.physicsBody?.contactTestBitMask = ColliderType.Rock.rawValue | ColliderType.Shield.rawValue
        rock.physicsBody?.collisionBitMask = ColliderType.Rock.rawValue | ColliderType.Platypus.rawValue

        self.addChild(rock)
        rock.physicsBody?.applyImpulse(CGVectorMake(0, (self.slowMotion ? -0.125 : -0.75) * (self.impulseSlower ? 0.5 : 1.0) * (1.0 + (self.seconds.CGFloatValue / 100.0))))
        NSLog("\(rock.physicsBody?.velocity.dy)")


    }

    /**
    *  Makes the stars in the scene background
    *
    *  @return Void
    */
    func makeStars() -> SKEmitterNode {

        let path = NSBundle.mainBundle().pathForResource("Stars", ofType: "sks")
        let stars: SKEmitterNode = NSKeyedUnarchiver.unarchiveObjectWithFile(path!) as SKEmitterNode
        stars.particlePosition = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame))
        stars.particlePositionRange = CGVectorMake(CGRectGetWidth(self.frame), 0)
        stars.zPosition = -2
        stars.advanceSimulationTime(10.0)
        return stars

    }

    /**
    *  Creates a new action to continue adding rocks, recursively
    *
    *  @return Void
    */
    func addRocks() {
        if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Phone {
            let duration = self.slowMotion ? 1.36 : 0.16
            let makeRocks = SKAction.runBlock({self.addRock()})
            let makeRocks2 = SKAction.runBlock({self.addRocks()})
            let delay = SKAction.waitForDuration(duration)
            let sequence = SKAction.sequence([makeRocks, delay, makeRocks2])
            self.runAction(sequence)
        } else {
            let duration = self.slowMotion ? 0.96 : 0.12
            let makeRocks = SKAction.runBlock({self.addRock()})
            let makeRocks2 = SKAction.runBlock({self.addRocks()})
            let delay = SKAction.waitForDuration(duration)
            let sequence = SKAction.sequence([makeRocks, delay, makeRocks2])

            self.runAction(sequence)
        }
    }

    /**
    *  Creates a new random powerup and sets up a reaccuring action to continue making powerups
    *
    *  @return Void
    */
    func addPowerup() {

        var random = arc4random()
        let width: CGFloat = CGRectGetWidth(self.frame)
        let widthAsDouble: Double = Double(width)
        let randomNum: Double = randomNumberFunction(widthAsDouble) as Double
        let randomNumAsCGFloat: CGFloat = randomNum.CGFloatValue
        let point = CGPointMake(randomNumAsCGFloat, CGRectGetHeight(self.frame) + 50)
        random = random % 3
        if random == 0 {
            let lifePowerup = SKSpriteNode(imageNamed: "healthPowerup")
            lifePowerup.position = point
            lifePowerup.name = "life"
            lifePowerup.physicsBody = SKPhysicsBody(rectangleOfSize: lifePowerup.size)
            lifePowerup.physicsBody?.usesPreciseCollisionDetection = true
            lifePowerup.physicsBody?.categoryBitMask = ColliderType.Life.rawValue
            lifePowerup.physicsBody?.contactTestBitMask = ColliderType.Platypus.rawValue
            lifePowerup.physicsBody?.collisionBitMask = ColliderType.Platypus.rawValue
            lifePowerup.physicsBody?.usesPreciseCollisionDetection = true
            lifePowerup.physicsBody?.mass = 1
            if (!self.impulseSlower) {
                let vector = CGVectorMake(0, 0.0 - 3.0 - (self.level.CGFloatValue / 2.0))
                lifePowerup.physicsBody?.applyImpulse(vector)
            }
            else {
                let vector = CGVectorMake(0, -3.0)
                lifePowerup.physicsBody?.applyImpulse(vector)
            }
            self.addChild(lifePowerup)


        }
        if (random == 1) {
            let lifePowerup = SKSpriteNode(imageNamed: "gravityPowerup")
            lifePowerup.position = point
            lifePowerup.name = "gravity"
            lifePowerup.physicsBody = SKPhysicsBody(rectangleOfSize: lifePowerup.size)
            lifePowerup.physicsBody?.usesPreciseCollisionDetection = true
            lifePowerup.physicsBody?.categoryBitMask = ColliderType.Gravity.rawValue
            lifePowerup.physicsBody?.contactTestBitMask = ColliderType.Platypus.rawValue
            lifePowerup.physicsBody?.collisionBitMask = ColliderType.Platypus.rawValue
            lifePowerup.physicsBody?.usesPreciseCollisionDetection = true
            lifePowerup.physicsBody?.mass = 1
            if (!self.impulseSlower) {
                let vector = CGVectorMake(0, 0.0 - 3.0 - (self.level.CGFloatValue / 2.0))
                lifePowerup.physicsBody?.applyImpulse(vector)
            }
            else {
                let vector = CGVectorMake(0, -3.0)
                lifePowerup.physicsBody?.applyImpulse(vector)
            }
            self.addChild(lifePowerup)


        }
        if (random == 2) {
            let lifePowerup = SKSpriteNode(imageNamed: "invinciblePowerup")
            lifePowerup.position = point
            lifePowerup.name = "invincible"
            lifePowerup.physicsBody = SKPhysicsBody(rectangleOfSize: lifePowerup.size)
            lifePowerup.physicsBody?.usesPreciseCollisionDetection = true
            lifePowerup.physicsBody?.categoryBitMask = ColliderType.Shield.rawValue
            lifePowerup.physicsBody?.contactTestBitMask = ColliderType.Platypus.rawValue
            lifePowerup.physicsBody?.collisionBitMask = ColliderType.Platypus.rawValue
            lifePowerup.physicsBody?.usesPreciseCollisionDetection = true
            lifePowerup.physicsBody?.mass = 1
            if (!self.impulseSlower) {
                let vector = CGVectorMake(0, 0.0 - 3.0 - (self.level.CGFloatValue / 2.0))
                lifePowerup.physicsBody?.applyImpulse(vector)
            }
            else {
                let vector = CGVectorMake(0, -3.0)
                lifePowerup.physicsBody?.applyImpulse(vector)
            }
            self.addChild(lifePowerup)

        }

    }

    func didBeginContact(contact: SKPhysicsContact!) {
        NSLog("\(self.hits)")
        let bodyA = contact.bodyA
        let bodyB = contact.bodyB
        var typeA: ColliderType = ColliderType(rawValue: bodyA.categoryBitMask)!
        var typeB: ColliderType = ColliderType(rawValue: bodyB.categoryBitMask)!

        if (typeA == ColliderType.Rock) && (typeB == ColliderType.Rock) {
            bodyA.node?.addChild(self.newSpark())
            bodyB.node?.addChild(self.newSpark())
        } else if (typeA == .Rock || typeB == .Rock) && (typeA != .Platypus && typeB != .Platypus) {
            bodyA.node?.addChild(self.newSpark())
            bodyB.node?.addChild(self.newSpark())
        } else if (typeA == .Rock || typeB == .Rock) && (typeA == .Platypus || typeB == .Platypus) {
            typeA == .Rock ? bodyA.node?.addChild(newSpark()) : bodyB.node?.addChild(newSpark())
            if !self.invincible {
                hits++
                if hits < 4 {
                    self.handleInvincibility()
                } else {
                    self.shouldAcceptFurtherCollisions = false
                    self.shouldMakeMoreRocks = false
                }
            }
        } else if (typeA == .Life || typeB == .Life) && (typeA == .Platypus || typeB == .Platypus) {
            hits--
            typeA == .Life ? bodyA.node?.removeFromParent() : bodyB.node?.removeFromParent()
        } else if (typeA == .Gravity || typeB == .Gravity) && (typeA == .Platypus || typeB == .Platypus) {
            self.handleSlow()
            typeA == .Gravity ? bodyA.node?.removeFromParent() : bodyB.node?.removeFromParent()
        } else if (typeA == .Shield || typeB == .Shield) && (typeA == .Platypus || typeB == .Platypus) {
            self.handleInvincibility()
            typeA == .Shield ? bodyA.node?.removeFromParent() : bodyB.node?.removeFromParent()
        }



    }

    /**
    *  Implements the functionality of the gravity powerup
    *
    *  @return Void
    */
    func handleSlow() {
        self.impulseSlower = true
        let block = SKAction.runBlock({self.impulseSlower = false})
        let delay = SKAction.waitForDuration(6.0)
        let sequence = SKAction.sequence([delay, block])
        self.runAction(sequence)


    }

    /**
    *  Creates a new spark
    *
    *  @return Void
    */
    func newSpark() -> SKEmitterNode {
        let path = NSBundle.mainBundle().pathForResource("spark", ofType: "sks")
        let node: SKEmitterNode = NSKeyedUnarchiver.unarchiveObjectWithFile(path!) as SKEmitterNode
        return node
    }

    /**
    *  Sets the inviniciblity status and causes the platypus to fade in and out
    *
    *  @return Void
    */
    func handleInvincibility() {
        self.invincible = true
        let node = self.childNodeWithName("PlatypusBody") as SKSpriteNode
        let fadeout = SKAction.fadeOutWithDuration(0.25)
        let fadeIn = SKAction.fadeInWithDuration(0.25)
        let block = SKAction.runBlock({self.invincible = false})
        let sequence = SKAction.sequence([fadeout, fadeIn, fadeout, fadeIn, fadeout, fadeIn, fadeout, fadeIn, fadeout,fadeIn, fadeout, fadeIn, block])
        node.runAction(sequence)

    }

    /**
    *  Handles the game over sequence
    *
    *  @return Void
    */
    func gameOver() {
        
        var point: CGPoint
        if let pointTwo = self.childNodeWithName("PlatypusBody")?.position {
            point = pointTwo
        }
        else {
            point = CGPointZero
        }
        self.timer.stop()
        self.removeAllActions()
        self.removeAllChildren()
        self.addChild(self.stars)
        self.stars.advanceSimulationTime(6.0)
        let path = NSBundle.mainBundle().pathForResource("MyExplosion", ofType: "sks")
        let node = NSKeyedUnarchiver.unarchiveObjectWithFile(path!) as SKEmitterNode
        node.position = point 
        
        self.addChild(node)

        let label = SKLabelNode(fontNamed: "Helvetica")
        label.text = self.timerLabel.text
        label.fontSize = 36
        label.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
        label.hidden = true
        label.name = "label"
        let finalBlock: () -> () = ({

            self.doGameCenter()
            let scene = WelcomeScene(size: self.size)
            let transition = SKTransition.doorsCloseHorizontalWithDuration(0.5)
            self.scene?.view?.presentScene(scene, transition: transition)

            })
        self.addChild(label)
        let delay = SKAction.waitForDuration(1.0)
        //let block = SKAction.runBlock { (Double) -> number in
        //    self.childNodeWithName("label"?.hidden = false)
        //}
        let actionBlock: (Int, Int) -> dispatch_block_t = {(one: Int, two: Int) -> dispatch_block_t in
            self.childNodeWithName(String("label"))?.hidden = false
            return ({()->Void in return})
        }
        
        let block = SKAction.runBlock(actionBlock(2, 3))
        let delay2 = SKAction.waitForDuration(2.0)
        let block2 = SKAction.runBlock(finalBlock)
        let sequence = SKAction.sequence([delay, block, delay2, block2])
        self.runAction(sequence)
    }

    /**
    *  Reports all scores and updates all achievements
    *
    *  @return Void
    */
    func doGameCenter() {
        if gameCenterEnabled {
            self.reportAchievement("Play_Space_Platypus_Once", additionalCompletion: 100.0)
            self.reportAchievement("Play_10_Games_of_Space_Platypus", additionalCompletion: 10.0)
            let score: Int64 = Int64(self.seconds)
            self.reportScore(score, leaderboardID: "Highest0Time0Without0Hitting0A0Rock000000001")

            if motionEnabled {
                if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
                    self.reportScore(score, leaderboardID: "HighestTimeiPhoneAccelerometer")
                } else {
                    self.reportScore(score, leaderboardID: "HighestTimeiPadAccelerometer")
                }
            }
            if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
                self.reportScore(score, leaderboardID: "HightestTimeiPhone")
            } else {
                self.reportScore(score, leaderboardID: "HighestTimeiPad")
            }
        }
    }

    /**
    *  Loads the leaderboard info
    *
    *  @return Void
    */
    func loadLeaderboardInfo() {
        GKLeaderboard.loadLeaderboardsWithCompletionHandler({(array, error) in if (array != nil) {self.leaderboards = array}})
    }

    /**
    *  Reports a given score to Game Center
    *
    *  @param Int64  The Score
    *  @param String The leaderboard ID
    *
    *  @return Void
    */
    func reportScore(score: Int64, leaderboardID: String) {
        let sendScore = GKScore(leaderboardIdentifier: leaderboardID)
        sendScore.value = score
        var error = NSError()
        GKScore.reportScores([sendScore], withCompletionHandler: { (error) -> Void in
            return
        })

    }

    /**
    *  Loads the Acheivements
    *
    *  @return Void
    */
    func loadAchievements() {
        GKAchievement.loadAchievementsWithCompletionHandler({(array, error) in
            if !(error != nil) {
                for thing: AnyObject in array {
                    self.achievementsDictionary.setValue(thing, forKey: thing.identifier)
                }
            }
            })
    }

    /**
    *  Reports the achievement
    *
    *  @param String  Identifier of achievement to report
    *  @param CDouble The ammount of additional completion to report
    *
    *  @return Void
    */
    func reportAchievement(identifier: String, additionalCompletion: CDouble) {
        let achievement: GKAchievement = self.getAchievementForIdentifier(identifier)
        if achievement.percentComplete != 100.0 {
            achievement.percentComplete += additionalCompletion
            GKAchievement.reportAchievements([achievement], withCompletionHandler: nil)
        }
    }
    
    /**
    *  Gets the achievement for the given identifier
    *
    *  @param String The identifier of the achievement
    *
    *  @return The achievement object
    */
    func getAchievementForIdentifier(identifier: String) -> GKAchievement {
        if (self.achievementsDictionary.valueForKey(identifier) != nil) {
            return self.achievementsDictionary.valueForKey(identifier) as GKAchievement
        } else {
            let achievement = GKAchievement(identifier: identifier)
            self.achievementsDictionary.setValue(achievement, forKey: identifier)
            return achievement
        }
    }
    
}
