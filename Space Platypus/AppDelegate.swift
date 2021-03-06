//
//  AppDelegate.swift
//  Space Platypus Swift
//
//  Created by Andrew Paterson on 6/4/14.
//  Copyright (c) 2014 Andrew Paterson. All rights reserved.
//

import Crashlytics
import UIKit
import SpriteKit
import GameKit

/**
*  The Extension on Double that defines a property CGFloatValue
*/
extension Double {
    /**
    *  The number as a CGFloat
    */
    var CGFloatValue: CGFloat {
    get {
        return CGFloat(self)
    }
    }
}

/**
*  The Extension on Int that defines a property CGFloatValue
*/
extension Int {
    /**
    *  The number as a CGFloat
    */
    var CGFloatValue: CGFloat {
    get {
        return CGFloat(self)
    }
    }
}

/**
*  The Enumeration Defining the Types of Platypus
*/
enum kPlatypusColor: Int {
        case kPlatypusColorDefault = 1,
        kPlatypusColorRed,
        kPlatypusColorYellow,
        kPlatypusColorGreen,
        kPlatypusColorPurple,
        kPlatypusColorPink,
        kPlatypusColorDareDevil,
        kPlatypusColorSanta,
        kPlatypusColorElf,
        kPlatypusColorChirstmasTree,
        kPlatypusColorRaindeer,
        kPlatypusColorFire
    }

/**
*  Converts a Platypus Type into an image name
*
*  @param kPlatypusColor The Platypus Type you want an image name for
*
*  @return The image name for the given platypus type
*/
func imageNameForPlatypusColor(color: kPlatypusColor) -> String {
    switch color {
    case .kPlatypusColorDefault:
        return "hullImage"
    case .kPlatypusColorRed:
        return "redHull"
    case .kPlatypusColorGreen:
        return "greenHull"
    case .kPlatypusColorPink:
        return "pinkHull"
    case .kPlatypusColorPurple:
        return "purpleHull"
    case .kPlatypusColorYellow:
        return "yellowHull"
    case .kPlatypusColorDareDevil:
        return "daredevilhull"
    case .kPlatypusColorSanta:
        return "santaPlatypus"
    case .kPlatypusColorElf:
        return "elfPlatypus"
    case .kPlatypusColorChirstmasTree:
        return "christmastreeplatypus"
    case .kPlatypusColorRaindeer:
        return "raindeerPlatypus"
    case .kPlatypusColorFire:
        return "firePlatypus"
    }

}

/**
*  Converts a Platypus Type to the name used to store preferences in NSUserDefaults
*
*  @param kPlatypusColor The Platypus Type for which you would like the defaults value
*
*  @return The Value for NSUser Defaults for the given platypus type
*/
func stringForPlatypusType(type: kPlatypusColor) -> String {
    switch type {
    case .kPlatypusColorDefault:
        return "default"
    case .kPlatypusColorRed:
        return "red"
    case .kPlatypusColorGreen:
        return "green"
    case .kPlatypusColorPink:
        return "pink"
    case .kPlatypusColorPurple:
        return "purple"
    case .kPlatypusColorYellow:
        return "yellow"
    case .kPlatypusColorDareDevil:
        return "dareDevil"
    case .kPlatypusColorSanta:
        return "santa"
    case .kPlatypusColorElf:
        return "elf"
    case .kPlatypusColorChirstmasTree:
        return "tree"
    case .kPlatypusColorRaindeer:
        return "raindeer"
    case .kPlatypusColorFire:
        return "fire"
    }
}

/**
*  The Global Platypus Color: Auto updates NSUserDefaults upon setting
*/
var platypusColor: kPlatypusColor = .kPlatypusColorDefault{
    willSet{
        NSUserDefaults.standardUserDefaults().setObject(stringForPlatypusType(newValue), forKey: "platypusColor")
    }
}

/**
*  The Global Determination of wheter or not motion control is enabled: Auto updates NSUserDefaults upon setting
*/
var motionEnabled: Bool = false {
    willSet {
        NSUserDefaults.standardUserDefaults().setBool(newValue, forKey: "motion")
    }
}

var gameCenterEnabled: Bool = true {
    willSet {
        if !NSUserDefaults.standardUserDefaults().boolForKey("value") {
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "value")
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "gk")
        }
        else {
            NSUserDefaults.standardUserDefaults().setBool(newValue, forKey: "gk")
        }
    }
}


//import Crashlytics
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    override init() {
        
        // Get Stored Values from NSUserDefaults 
        
        motionEnabled = NSUserDefaults.standardUserDefaults().boolForKey("motion")
        //gameCenterEnabled = NSUserDefaults.standardUserDefaults().boolForKey("gk")
        // if NSUserDefaults.standardUserDefaults().objectForKey("test") as String != "yes" {
        // gameCenterEnabled = true
        //    NSUserDefaults.standardUserDefaults().setObject("yes", forKey: "test")
        // }
        gameCenterEnabled = NSUserDefaults.standardUserDefaults().boolForKey("gk")
        if let colorString:NSString = NSUserDefaults.standardUserDefaults().objectForKey("platypusColor") as? NSString {
            switch colorString {
            case "red":
                platypusColor = .kPlatypusColorRed
            case "yellow":
                platypusColor = .kPlatypusColorYellow
            case "green":
                platypusColor = .kPlatypusColorGreen
            case "pink":
                platypusColor = .kPlatypusColorPink
            case "purple":
                platypusColor = .kPlatypusColorPurple
            case "dareDevil":
                platypusColor = .kPlatypusColorDareDevil
            case "santa":
                platypusColor = .kPlatypusColorSanta
            case "elf":
                platypusColor = .kPlatypusColorElf
            case "tree":
                platypusColor = .kPlatypusColorChirstmasTree
            case "fire":
                platypusColor = .kPlatypusColorFire
            case "raindeer":
                platypusColor = .kPlatypusColorRaindeer
            default:
                platypusColor = .kPlatypusColorDefault
            }
        } else {
            platypusColor = .kPlatypusColorDefault
        }
        

        super.init()
    }



    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: NSDictionary?) -> Bool {
        // Override point for customization after application launch.
       Crashlytics.startWithAPIKey("1c6d125161cfd6155af441bc83d21a64632d815c")
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

