//
//  GameConfig.h
//  WaveProject
//
//  Created by Albith Delgado on 11. 7. 10..
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#ifndef __GAME_CONFIG_H
#define __GAME_CONFIG_H

//This file defines several constants
    //to configure the engine's performance in the device.
    //(specifically related to auto-rotation).

//
// Supported Autorotations:
//		None,
//		UIViewController,
//		CCDirector
//
#define kGameAutorotationNone 0
#define kGameAutorotationCCDirector 1
#define kGameAutorotationUIViewController 2

//
// Define here the type of autorotation that you want for your game
//
#define GAME_AUTOROTATION kGameAutorotationNone


#endif // __GAME_CONFIG_H