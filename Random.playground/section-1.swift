// Playground - noun: a place where people can play

import UIKit

var lastRandom: Double = 0

func randomNumberFunction(max: Double) -> Double {
    if lastRandom == 0 {
        lastRandom = NSDate.timeIntervalSinceReferenceDate()
    }
    var newRand =  ((lastRandom * M_PI * 97236.72) * 11048.6954) % max
    lastRandom = newRand
    return newRand
}

for var i = 0; i <= 100; i++ {
    randomNumberFunction(1000.0)
    arc4random() % 1000
}

var arr: Double[] = []
for var i = 0; i <= 1000; i++ {
    let num = randomNumberFunction(680)
    arr.append(num)
    num

}
arr
arr.sort({$0 == $1})
arr
for num in arr {
    num
}