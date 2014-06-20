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

protocol TimerDelegate {
    func timerDidChangeTime(value: Int, valueString: String)
}

class Timer: SKNode {
    var timeElapsed: Int = 0 {
    willSet {
        self.timeElapsedString = "\(newValue)"
    }
    }
    var timeElapsedString: String = "0"
    var shouldContinue: Bool = false
    var delegate: TimerDelegate?

    /// Starts the Timer
    func start() {
        self.shouldContinue = true
        let performBlock = SKAction.runBlock({self.addTime()})
        let delay = SKAction.waitForDuration(1.0)
        let action = SKAction.sequence([delay, performBlock])
        self.runAction(action)
    }

    func addTime() {
        self.timeElapsed++
        if let del = self.delegate {
            del.timerDidChangeTime(self.timeElapsed, valueString: self.timeElapsedString)
        }
        if self.shouldContinue {
            let performBlock = SKAction.runBlock({self.addTime()})
            let delay = SKAction.waitForDuration(1.0)
            let action = SKAction.sequence([delay, performBlock])
            self.runAction(action)
        }
    }

    /// Stops the Timer
    func stop() {
        self.shouldContinue = false
    }


    func clear() {
        self.timeElapsed = 0
    }
}

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
            self.gameOver()
        }
    }
    }
    var leaderboards: AnyObject[] = []
    var shouldAcceptFurtherCollisions = true
    var shouldMakeMoreRocks = true
    var level = 0
    var achievementsDictionary = [:]
    var motionManager: CMMotionManager?
    var impulseSlower = false
    var timer: Timer = Timer()
    var timerLabel: SKLabelNode

    enum ColliderType: UInt32 {
        case Rock = 1
        case Life = 2
        case Platypus = 4
        case Gravity = 8
        case Shield = 16
    }

    init(size: CGSize) {

        self.timerLabel  = SKLabelNode(fontNamed: "Helvetica")
        self.timerLabel.text = "0:00"
        self.stars = SKEmitterNode()
        super.init(size: size)
        self.stars = makeStars()
        self.addChild(self.stars)


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

    func processUserMotionForUpdate(currentTimeInterval: NSTimeInterval) {
        if self.shouldAcceptFurtherCollisions {
            let ship = self.childNodeWithName("PlatypusBody")
            let data = self.motionManager?.accelerometerData

            if let datas = data {

                let positionY: Double = ship.position.y.bridgeToObjectiveC().doubleValue
                let positionX: Double = ship.position.x.bridgeToObjectiveC().doubleValue
                let accelerometerX: Double = datas.acceleration.x as Double * 15.0
                let accelerometerY: Double = datas.acceleration.y as Double * 15.0
                let height: Double = CGRectGetMaxY(self.frame).bridgeToObjectiveC().doubleValue
                let width: Double = CGRectGetMaxX(self.frame).bridgeToObjectiveC().doubleValue

                let horizontalNotNegative: Bool = positionX + accelerometerX >= 0.0
                let horizontalNotPastScreen: Bool = positionX + accelerometerX <= width
                let verticalNotNegative: Bool = positionY + accelerometerY >= 0.0
                let verticalNotPastScreen: Bool = positionY + accelerometerY <= height

                let horizontal: Bool = horizontalNotNegative && horizontalNotPastScreen
                let vertical: Bool = verticalNotNegative && verticalNotPastScreen

                if horizontal && vertical {

                    let newX = positionX + accelerometerX
                    let newY = positionY + accelerometerY

                    let newPostion = CGPointMake(newX.bridgeToObjectiveC().floatValue, newY.bridgeToObjectiveC().floatValue)

                    ship.position = newPostion

                }

            }
        }



    }

    func createSceneContent() {

        self.makePlatypus()
        self.addRocks()
        self.timer.start()
        self.makeLifeBar()



    }

    func makeLifeBar() {

        let node = SKSpriteNode(imageNamed: "LifeBarFull")
        node.name = "lifeBar"
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            node.position = CGPointMake(self.view.frame.size.width - 70, self.view.frame.size.height - 15)
        } else {
            node.position = CGPointMake(self.view.frame.size.width - 70, self.view.frame.size.height - 35)
        }
        self.addChild(node)

    }

    override func didSimulatePhysics() {

        let block: (SKNode!, CMutablePointer<ObjCBool>) -> Void = ({(node, stop) in
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

    override func touchesBegan(touches: NSSet!, withEvent event: UIEvent!) {

        super.touchesBegan(touches, withEvent: event)

        if motionEnabled {
            return
        }

        if self.shouldAcceptFurtherCollisions {

            let hull = self.childNodeWithName("PlatypusBody")
            let touch: UITouch = touches.anyObject() as UITouch
            let move = SKAction.moveTo(CGPointMake(touch.locationInNode(self).x, touch.locationInNode(self).y + 50), duration:0.05);

            hull.runAction(move)

        }

    }

    override func touchesMoved(touches: NSSet!, withEvent event: UIEvent!) {

        super.touchesMoved(touches, withEvent: event)

        if motionEnabled {
            return
        }

        if self.shouldAcceptFurtherCollisions {

            let hull = self.childNodeWithName("PlatypusBody")
            let touch: UITouch = touches.anyObject() as UITouch
            let move = SKAction.moveTo(CGPointMake(touch.locationInNode(self).x, touch.locationInNode(self).y + 50), duration:0.05);

            hull.runAction(move)

        }

    }


    func addRock() {
        let rock = SKSpriteNode(color: SKColor(red: 0.67647, green:0.51568, blue:0.29216, alpha:1.0), size: CGSizeMake(8, 8))

        let width: CGFloat = CGRectGetWidth(self.frame)
        let widthAsDouble: Double = width.bridgeToObjectiveC().doubleValue
        let randomNum = randomNumberFunction(widthAsDouble)
        let randomNumAsCGFloat: CGFloat = randomNum.bridgeToObjectiveC().floatValue
        let point = CGPointMake(randomNumAsCGFloat, CGRectGetHeight(self.frame))

        rock.position = point
        rock.name = "rock"
        rock.physicsBody = SKPhysicsBody(rectangleOfSize: rock.size)
        rock.physicsBody.usesPreciseCollisionDetection = true
        rock.physicsBody.categoryBitMask = ColliderType.Rock.toRaw()
        rock.physicsBody.contactTestBitMask = ColliderType.Rock.toRaw() | ColliderType.Shield.toRaw()
        rock.physicsBody.collisionBitMask = ColliderType.Rock.toRaw() | ColliderType.Platypus.toRaw()

        self.addChild(rock)
        rock.physicsBody.applyImpulse(CGVectorMake(0, -0.75 * (self.impulseSlower ? 0.5 : 1.0) * (1.0 + (self.seconds.bridgeToObjectiveC().floatValue / 100.0))))


    }

    func makeStars() -> SKEmitterNode {

        let path = NSBundle.mainBundle().pathForResource("Stars", ofType: "sks")
        let stars: SKEmitterNode = NSKeyedUnarchiver.unarchiveObjectWithFile(path) as SKEmitterNode
        stars.particlePosition = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame))
        stars.particlePositionRange = CGVectorMake(CGRectGetWidth(self.frame), 0)
        stars.zPosition = -2
        stars.advanceSimulationTime(3.0)
        return stars

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

    func makePlatypus() {

        let imageName = imageNameForPlatypusColor(platypusColor)
        var platypusBody = SKSpriteNode(imageNamed: imageName)
        platypusBody.name = "PlatypusBody"

        platypusBody.physicsBody = SKPhysicsBody(texture: platypusBody.texture, size: platypusBody.size)
        platypusBody.physicsBody.dynamic = false
        platypusBody.physicsBody.contactTestBitMask = ColliderType.Rock.toRaw() | ColliderType.Life.toRaw()
        platypusBody.physicsBody.categoryBitMask = ColliderType.Platypus.toRaw()
        platypusBody.physicsBody.collisionBitMask = ColliderType.Rock.toRaw()
        if platypusColor == kPlatypusColor.kPlatypusColorFire {

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

        platypusBody.position = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 3.0)

        self.addChild(platypusBody)


    }

    func addRocks() {
        if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Phone {
            let duration = 0.16
            let makeRocks = SKAction.runBlock({self.addRock()})
            let delay = SKAction.waitForDuration(duration)
            let sequence = SKAction.sequence([makeRocks, delay])
            let repeat = SKAction.repeatActionForever(sequence)

            self.runAction(repeat)
        } else {
            let duration = 0.12
            let makeRocks = SKAction.runBlock({self.addRock()})
            let delay = SKAction.waitForDuration(duration)
            let sequence = SKAction.sequence([makeRocks, delay])
            let repeat = SKAction.repeatActionForever(sequence)

            self.runAction(repeat)
        }
        let makeRocks = SKAction.runBlock({self.addPowerup()})
        let delay = SKAction.waitForDuration(10.0, withRange: 5.0)
        let sequence = SKAction.sequence([delay, makeRocks])
        let repeat = SKAction.repeatActionForever(sequence)

        self.runAction(repeat)
    }


    func addPowerup() {

        var random = arc4random()
        let width: CGFloat = CGRectGetWidth(self.frame)
        let widthAsDouble: Double = width.bridgeToObjectiveC().doubleValue
        let randomNum: Double = randomNumberFunction(widthAsDouble) as Double
        let randomNumAsCGFloat: CGFloat = randomNum.bridgeToObjectiveC().floatValue
        let point = CGPointMake(randomNumAsCGFloat, CGRectGetHeight(self.frame) + 50)
        random = random % 3
        if random == 0 {
            let lifePowerup = SKSpriteNode(imageNamed: "healthPowerup")
            lifePowerup.position = point
            lifePowerup.name = "life"
            lifePowerup.physicsBody = SKPhysicsBody(rectangleOfSize: lifePowerup.size)
            lifePowerup.physicsBody.usesPreciseCollisionDetection = true
            lifePowerup.physicsBody.categoryBitMask = ColliderType.Life.toRaw()
            lifePowerup.physicsBody.contactTestBitMask = ColliderType.Platypus.toRaw()
            lifePowerup.physicsBody.collisionBitMask = ColliderType.Platypus.toRaw()
            lifePowerup.physicsBody.usesPreciseCollisionDetection = true
            lifePowerup.physicsBody.mass = 1
            if (!self.impulseSlower) {
                let vector = CGVectorMake(0, 0.0 - 3.0 - (self.level.bridgeToObjectiveC().floatValue / 2.0))
                lifePowerup.physicsBody.applyImpulse(vector)
            }
            else {
                let vector = CGVectorMake(0, -3.0)
                lifePowerup.physicsBody.applyImpulse(vector)
            }
            self.addChild(lifePowerup)


        }
        if (random == 1) {
            let lifePowerup = SKSpriteNode(imageNamed: "gravityPowerup")
            lifePowerup.position = point
            lifePowerup.name = "gravity"
            lifePowerup.physicsBody = SKPhysicsBody(rectangleOfSize: lifePowerup.size)
            lifePowerup.physicsBody.usesPreciseCollisionDetection = true
            lifePowerup.physicsBody.categoryBitMask = ColliderType.Gravity.toRaw()
            lifePowerup.physicsBody.contactTestBitMask = ColliderType.Platypus.toRaw()
            lifePowerup.physicsBody.collisionBitMask = ColliderType.Platypus.toRaw()
            lifePowerup.physicsBody.usesPreciseCollisionDetection = true
            lifePowerup.physicsBody.mass = 1
            if (!self.impulseSlower) {
                let vector = CGVectorMake(0, 0.0 - 3.0 - (self.level.bridgeToObjectiveC().floatValue / 2.0))
                lifePowerup.physicsBody.applyImpulse(vector)
            }
            else {
                let vector = CGVectorMake(0, -3.0)
                lifePowerup.physicsBody.applyImpulse(vector)
            }
            self.addChild(lifePowerup)


        }
        if (random == 2) {
            let lifePowerup = SKSpriteNode(imageNamed: "invinciblePowerup")
            lifePowerup.position = point
            lifePowerup.name = "invincible"
            lifePowerup.physicsBody = SKPhysicsBody(rectangleOfSize: lifePowerup.size)
            lifePowerup.physicsBody.usesPreciseCollisionDetection = true
            lifePowerup.physicsBody.categoryBitMask = ColliderType.Shield.toRaw()
            lifePowerup.physicsBody.contactTestBitMask = ColliderType.Platypus.toRaw()
            lifePowerup.physicsBody.collisionBitMask = ColliderType.Platypus.toRaw()
            lifePowerup.physicsBody.usesPreciseCollisionDetection = true
            lifePowerup.physicsBody.mass = 1
            if (!self.impulseSlower) {
                let vector = CGVectorMake(0, 0.0 - 3.0 - (self.level.bridgeToObjectiveC().floatValue / 2.0))
                lifePowerup.physicsBody.applyImpulse(vector)
            }
            else {
                let vector = CGVectorMake(0, -3.0)
                lifePowerup.physicsBody.applyImpulse(vector)
            }
            self.addChild(lifePowerup)

        }

    }

    func didBeginContact(contact: SKPhysicsContact!) {
        NSLog("\(self.hits)")
        let bodyA = contact.bodyA
        let bodyB = contact.bodyB
        var typeA: ColliderType = ColliderType.fromRaw(bodyA.categoryBitMask)!
        var typeB: ColliderType = ColliderType.fromRaw(bodyB.categoryBitMask)!

        if (typeA == .Rock) && (typeB == .Rock) {
            bodyA.node.addChild(self.newSpark())
            bodyB.node.addChild(self.newSpark())
        } else if (typeA == .Rock || typeB == .Rock) && (typeA != .Platypus && typeB != .Platypus) {
            bodyA.node.addChild(self.newSpark())
            bodyB.node.addChild(self.newSpark())
        } else if (typeA == .Rock || typeB == .Rock) && (typeA == .Platypus || typeB == .Platypus) {
            typeA == .Rock ? bodyA.node.addChild(newSpark()) : bodyB.node.addChild(newSpark())
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
            typeA == .Life ? bodyA.node.removeFromParent() : bodyB.node.removeFromParent()
        } else if (typeA == .Gravity || typeB == .Gravity) && (typeA == .Platypus || typeB == .Platypus) {
            self.handleSlow()
            typeA == .Gravity ? bodyA.node.removeFromParent() : bodyB.node.removeFromParent()
        } else if (typeA == .Shield || typeB == .Shield) && (typeA == .Platypus || typeB == .Platypus) {
            self.handleInvincibility()
            typeA == .Shield ? bodyA.node.removeFromParent() : bodyB.node.removeFromParent()
        }



    }

    func handleSlow() {
        self.impulseSlower = true
        let block = SKAction.runBlock({self.impulseSlower = false})
        let delay = SKAction.waitForDuration(6.0)
        let sequence = SKAction.sequence([delay, block])
        self.runAction(sequence)


    }

    func newSpark() -> SKEmitterNode {
        let path = NSBundle.mainBundle().pathForResource("spark", ofType: "sks")
        let node: SKEmitterNode = NSKeyedUnarchiver.unarchiveObjectWithFile(path) as SKEmitterNode
        return node
    }

    func handleInvincibility() {
        self.invincible = true
        let node = self.childNodeWithName("PlatypusBody") as SKSpriteNode
        let fadeout = SKAction.fadeOutWithDuration(0.25)
        let fadeIn = SKAction.fadeInWithDuration(0.25)
        let block = SKAction.runBlock({self.invincible = false})
        let sequence = SKAction.sequence([fadeout, fadeIn, fadeout, fadeIn, fadeout, fadeIn, fadeout, fadeIn, fadeout,fadeIn, fadeout, fadeIn, block])
        node.runAction(sequence)

    }

    func gameOver() {
        let point = self.childNodeWithName("PlatypusBody").position
        self.timer.stop()
        self.removeAllActions()
        self.removeAllChildren()
        self.addChild(self.stars)
        self.stars.advanceSimulationTime(6.0)
        let path = NSBundle.mainBundle().pathForResource("MyExplosion", ofType: "sks")
        let node = NSKeyedUnarchiver.unarchiveObjectWithFile(path) as SKEmitterNode
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
            self.scene.view.presentScene(scene, transition: transition)

            })
        self.addChild(label)
        let delay = SKAction.waitForDuration(1.0)
        let block = SKAction.runBlock({self.childNodeWithName("label").hidden = false})
        let delay2 = SKAction.waitForDuration(2.0)
        let block2 = SKAction.runBlock(finalBlock)
        let sequence = SKAction.sequence([delay, block, delay2, block2])
        self.runAction(sequence)
    }


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

    func loadLeaderboardInfo() {
        GKLeaderboard.loadLeaderboardsWithCompletionHandler({(array, error) in if array {self.leaderboards = array}})
    }

    func reportScore(score: Int64, leaderboardID: String) {
        let reporter = GKScore(leaderboardIdentifier: leaderboardID)
        reporter.value = score
        reporter.context = 0
        reporter.reportScoreWithCompletionHandler(nil)
    }

    func loadAchievements() {
        GKAchievement.loadAchievementsWithCompletionHandler({(array, error) in
            if !error {
                for thing: AnyObject in array {
                    self.achievementsDictionary.setValue(thing, forKey: thing.identifier)
                }
            }
            })
    }

    func reportAchievement(identifier: String, additionalCompletion: CDouble) {
        let achievement: GKAchievement = self.getAchievementForIdentifier(identifier)
        if achievement != nil && achievement.percentComplete != 100.0 {
            achievement.percentComplete += additionalCompletion
            GKAchievement.reportAchievements([achievement], withCompletionHandler: nil)
        }
    }
    
    func getAchievementForIdentifier(identifier: String) -> GKAchievement {
        if self.achievementsDictionary.valueForKey(identifier) {
            return self.achievementsDictionary.valueForKey(identifier) as GKAchievement
        } else {
            let achievement = GKAchievement(identifier: identifier)
            self.achievementsDictionary.setValue(achievement, forKey: identifier)
            return achievement
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}























