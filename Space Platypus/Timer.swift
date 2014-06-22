//
//  Timer.swift
//  Space Platypus
//
//  Created by Andrew Paterson on 6/21/14.
//  Copyright (c) 2014 Karl Paterson. All rights reserved.
//

import UIKit
import SpriteKit

/**
*  The Protocol For Classes implementing a Timer
*/
protocol TimerDelegate {
    
    /**
    *  The Delegate callback method that updates the delegate of the current value of the timer
    *
    *  @param Int    The number of seconds counted
    *  @param String The number of seconds counted as a string
    *
    *  @return Void
    */
    func timerDidChangeTime(value: Int, valueString: String)
}
class Timer: SKNode {
    /**
    *  The Time Elapsed in seconds
    */
    var timeElapsed: Int = 0 {
    willSet {
        self.timeElapsedString = "\(newValue)"
    }
    }
    /**
    *  The scale of time: 1.0 means 1 second real time == 1 second on the timer, 2.0 means 2 seconds real time = 1 second on the timer
    */
    var scale: Double = 1.0
    /**
    *  The Time Elapsed in seconds as a string
    */
    var timeElapsedString: String = "0"
    /**
    *  The Value of whether or not the timer should continue to count
    */
    var shouldContinue: Bool = false
    /**
    *  The timers delegate, and optional value but required to recieve callbacks when the timer changes
    */
    var delegate: TimerDelegate?
    
    /**
    *  Starts the timer
    *
    *  @return Void
    */
    func start() {
        self.shouldContinue = true
        let performBlock = SKAction.runBlock({self.addTime()})
        let delay = SKAction.waitForDuration(1.0 * self.scale)
        let action = SKAction.sequence([delay, performBlock])
        self.runAction(action)
    }
    
    /**
    *  Adds 1 Second to the timer: Recursive
    *
    *  @return Void
    */
    func addTime() {
        self.timeElapsed++
        if let del = self.delegate {
            del.timerDidChangeTime(self.timeElapsed, valueString: self.timeElapsedString)
        }
        if self.shouldContinue {
            let performBlock = SKAction.runBlock({self.addTime()})
            let delay = SKAction.waitForDuration(1.0 * self.scale)
            let action = SKAction.sequence([delay, performBlock])
            self.runAction(action)
        }
    }

    /**
    *  Stops the Timer
    *
    *  @return Void
    */
    func stop() {
        self.shouldContinue = false
    }
    
    /**
    *  Clears the Timer
    *
    *  @return Void
    */
    func clear() {
        self.timeElapsed = 0
    }
}

