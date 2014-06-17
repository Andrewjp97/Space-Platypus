//
//  Space_PlatypusTests.swift
//  Space PlatypusTests
//
//  Created by Andrew Paterson on 6/14/14.
//  Copyright (c) 2014 Karl Paterson. All rights reserved.
//

import XCTest

class Space_PlatypusTests: XCTestCase, TimerDelegate {

    var seconds = 0
    var timer = Timer()

    func timerDidChangeTime(value: Int, valueString: String) {
        seconds = value
        NSLog(self.timer.timeElapsedString)
    }

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        self.timer.delegate = self
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()

    }
    
    func testExample() {
        // This is an example of a functional test case.


    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }
    
}

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