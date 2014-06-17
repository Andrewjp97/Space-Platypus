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

class Timer: NSObject {
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
        let offset = 1.0
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(offset * Double(NSEC_PER_SEC))), DISPATCH_QUEUE_PRIORITY_HIGH, {
            self.addTime()
            })
    }

    /// Stops the Timer
    func stop() {
        self.shouldContinue = false
    }

    func addTime() {
        self.timeElapsed++
        if let del = self.delegate {
            del.timerDidChangeTime(self.timeElapsed, valueString: self.timeElapsedString)
        }
        if self.shouldContinue {
            let offset = 1.0
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(offset * Double(NSEC_PER_SEC))), DISPATCH_QUEUE_PRIORITY_HIGH, {
                self.addTime()
                })
        }
    }

    func clear() {
        self.timeElapsed = 0
    }
}

class GameScene: SKScene, SKPhysicsContactDelegate, TimerDelegate {

    var contentCreated = false
    var seconds = 0
    var running = true
    var invincible = false
    var hits = 0
    var leaderboards: AnyObject[] = []
    var shouldAcceptFurtherCollisions = true
    var shouldMakeMoreRocks = true
    var level = 0
    var achievementsDictionary = [:]
    var motionManager: CMMotionManager?
    var impulseSlower = false
    var timer: Timer = Timer()
    var timerLabel: SKLabelNode = SKLabelNode(fontNamed: "Helvetica")

    enum ColliderType: UInt32 {
        case Rock = 1
        case Life = 2
        case Platypus = 4
        case Gravity = 8
        case Shield = 16
    }

    init(size: CGSize) {

        super.init(size: size)
        self.timer.delegate = self
        
    }

    func timerDidChangeTime(value: Int, valueString: String) {
        self.seconds = value
        self.timerLabel.text = valueString
    }

    override func didMoveToView(view: SKView) {

        if !contentCreated {

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

        }
    }

    func processUserMotionForUpdate(currentTimeInterval: NSTimeInterval) {

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

    func createSceneContent() {

        self.makeStars()
        self.makePlatypus()
        self.addRocks()
        self.timer.start()



    }

    func didBeginContact(contact: SKPhysicsContact!) {



    }

    override func didSimulatePhysics() {



    }

    override func update(currentTime: NSTimeInterval) {



    }

    func loadAchievements() {

        let handler:(AnyObject[]!, NSError!) -> Void = ({(array, error) in

            if error == nil {
                for acheivement: AnyObject in array {

                }
            }

            })

        GKAchievement.loadAchievementsWithCompletionHandler(handler)

    }


    func addRock() {
        let rock = SKSpriteNode(color: SKColor(red: 0.67647, green:0.51568, blue:0.29216, alpha:1.0), size: CGSizeMake(8, 8))

        let width: CGFloat = CGRectGetWidth(self.frame)
        let widthAsDouble: Double = width.bridgeToObjectiveC().doubleValue
        let randomNum = random(widthAsDouble)
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





































































































}























