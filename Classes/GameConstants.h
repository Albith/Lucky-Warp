//
//  GameConstants.h
//  Lucky Warp
//
//  Created by Albith Delgado on 7/27/11.
//  Copyright __Albith Delgado__ 2011. All rights reserved.
//

#ifndef WaveProject_GameConstants_h
#define WaveProject_GameConstants_h

//This file contains constants used 
    //to process the game logic and the game display.

//------:Main Menu Tag

#define GAME_MODE_TAG 5

//Stage Select Variables

const int stageNumberSpacingX = 95;
const int stageNumberSpacingY = 60;

const int numberMaxWidth=32;
const int numberHeight= 44;

const int stagesPerRow=5;


//------:About the number of levels:-------

const int START_LEVEL=0; 
const int NUMBER_OF_LEVELS= 19;


//------:Physics World Constants

//However, I'm not using a physics simulation in the game.
    #define PTM_RATIO 32

//------:Tutorial strings:-----------

    #define kTutorialString1 @"Go through the door\n           to escape!"
    #define kTutorialString2 @"to escape!"

//The following are older tutorial messages.
    //    #define kTutorialStringTeleport @"Move the Player off-screen to Warp."
    //    #define kTutorialStringTeleport2 @"Go up to warp."
    //
    //    #define kTutorialStringKey @"Sometimes you need a Key to open the Door."

//------:Game Scene Important Variables:----

    //The gravity that affects our main character.
    const float GRAVITY= -1100.0f; 

    const float JUMP_YVELOCITY= 550.0f;
    const float JOYSTICK_VELOCITY_MULTIPLIER = 190.0f;
    const float MY_TIME_STEP= 0.017;    


    //Minimum Falling Velocity.  
        //After this value is reached, the player's downward acceleration will remain constant.
    const float kMinVelocity= -500.0f;

    //zeroPoint comparison buffer 
    const int kBuffer=20;

//------:Status Variables

    //-----------------: Player Collision Status Variables

    
//Player Move Condition flags

        //For vertical movement    
        #define GOING_UP 11
        #define GOING_DOWN  12

        //For horizontal movement 
        #define NOT_MOVING 13
        #define GOING_LEFT 14
        #define GOING_RIGHT 15


//For referencing Edge Points in Player Sprite

        #define UPPER_LEFT_EDGE      0
        #define LOWER_LEFT_EDGE      1

        #define UPPER_RIGHT_EDGE    2
        #define LOWER_RIGHT_EDGE    3

    //-----------------: CCSprite object tags

    #define PLAYER_TAG 81
    #define DOOR_TAG 82
    #define WAVE_TAG 83
    #define KEY_TAG 84
    
    #define FALLING_PLATFORM_TAG_OFFSET 20
    

//-----TELEPORTS!-----: Teleport types constants.
    //Every teleporting area has one of these attributes.
    
    #define LEFT_WALL 0
    #define RIGHT_WALL 1
    #define CEILING 2
    #define FLOOR 3

    const int teleportMinSize= 1;


//------:This sets the speed of the spark elements in the game.   
    const float sparkMoveSpeed=1.3f; 

//------:Platform Speed and Falling Offset
    const int platformSpeed = 70;
    const float fallingPlatformSpeed = -180;
    const int fallingPlatformOffset= 50;


//------:Numbered Platforms.
    //These are special platforms that must be unlocked in order.
    const int kMaxNumberedPlatforms= 9;


//------:About the tilemap width and height---
    const int tileMapWidth=32;  //these are the pixel dimensions of each tile.
    const int tileMapHeight=32;

//------:About the screen dimensions:------
    const int screenWidth= 768;
    const int screenHeight= 1024;


#endif
