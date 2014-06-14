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

// Base Class

class GameScene: SKScene, SKPhysicsContactDelegate {

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
    var motion = motionEnabled
    var motionManager: CMMotionManager?
    var impulseSlower = false

    enum ColliderType: UInt32 {
        case Rock = 1
        case Life = 2
        case Platypus = 4
        case Gravity = 8
        case Shield = 16
    }

    init(size: CGSize) {

        super.init(size: size)
        
    }


    override func didMoveToView(view: SKView) {

        if !contentCreated {

            if motion {
                motionManager = CMMotionManager()
                motionManager!.startAccelerometerUpdates()
            }
            createSceneContent()
            contentCreated = true

            self.physicsWorld.contactDelegate = self
            self.physicsWorld.gravity = CGVectorMake(0, -1.5)

            loadAchievements()

        }
    }

    func createSceneContent() {



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

}
























