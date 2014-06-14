//
//  GetGKPlayer.m
//  Space Platypus Swift
//
//  Created by Andrew Paterson on 6/5/14.
//  Copyright (c) 2014 Andrew Paterson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GetGKPlayer.h"

GKLocalPlayer *getLocalPlayer(void) {
    return [GKLocalPlayer localPlayer];
}