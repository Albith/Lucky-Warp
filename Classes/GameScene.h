//
//  GameScene.h
//  Lucky Warp
//
//  Created by Albith Delgado on 11. 7. 10..
//  Copyright __Albith Delgado__ 2011. All rights reserved.
//

//The main game management class.
    //It handles all game logic, display, animation and state changes.

#import "cocos2d.h"
#import "TileMapHandler.h"

//Including Joystick files...
    #import "ColoredCircleSprite.h"
    #import "SneakyJoystick.h"
    #import "SneakyJoystickSkinnedBase.h"
    #import "SneakyButton.h"
    #import "SneakyButtonSkinnedBase.h"

@class TileMapHandler;

// HelloWorld Layer
@interface GameScene : CCLayer
{   
    
//-------Joystick classes.------------->
	SneakyJoystick *leftJoystick;
	SneakyJoystickSkinnedBase *leftJoy;	
	
    SneakyButton *jumpButton;
	SneakyButtonSkinnedBase *skinJumpButton;				
										
    
//--------Player information----------->
    CCSpriteBatchNode *playerSpriteBatch;
    
//---------Sound related variables------->   
    int playerWalkSoundId;
    
    
//---****----Player Animation-specific variables--******---
    id walkAction;
    
    id deathAnimation1;
    id deathAnimation2;
    
    id standingAnimation;
    
    BOOL isWalking;
    BOOL isStill;
    BOOL isJumping;
    BOOL isJumpZeroStarted;
    
    //storing previous status of jump button.
    BOOL jumpButtonWasActive;

//---****----END OF: Player Animation-specific variables--******---
    CCSprite* playerSprite;

    CGPoint playerSpawnPosition;
    
    CGPoint playerPosition;
    CGPoint playerVelocity;
    
    float old_playerVelocity;
    
    //Convenience variables for collision.
    CGSize playerSpriteSize;
    CGRect playerRect;
    
    
    int numberOfCollisionRects;
    CGRect *collisionRectsArray;
    
//---*****----Collision State Variables.
    BOOL collisionOcurred;
    
    BOOL isOnFloor;
    BOOL isOnCeiling;
    BOOL hasLeftSideCollision;
    BOOL hasRightSideCollision;
    
    
    BOOL hitCeilingOfMovingPlatform;
        
    BOOL zeroVelocityReached;    
    
//Objects:
    
    //-------CheckPoint------->this is not used at the moment.
    //BOOL isCheckPointPassed;
    //CGPoint checkPoint;
        
    
    //-------Door object------>    
   
    CCSprite* doorSprite;
    CGRect doorBoundingBox;
    
    //-------Key object------>
        
    BOOL hasKey;
    CCSprite* keySprite;
    
    
    //-------Spark objects---->
    
    CCSpriteBatchNode* sparksBatch;
    
    BOOL sparkIsTouched;
    BOOL doingKnockedBackAction;
    
    int numberOfSparks;
    
    id sparkAnimation;
    
    //-------Bumper objects--->
    
    //CCSpriteBatchNode* bumpersBatch;
    
    //-------Spike objects--->
    
    int numberOfSpikeRects;
    
    BOOL spikeIsTouched;
    BOOL doingResettingAction;
    
    CGRect* spikeRectsArray;
    
    
    //------Numbered Platforms objects--->
    
        //Temporary Fix. NSArray of CCSprites.
        NSMutableArray * numberedPlatformsArray;
        int numberOfNumberedPlatforms;
    
        int numberOfVisibleNumberedPlatforms;
        BOOL inNumberedPlatformCheck;
        int currentNumberedPlatformInCheck;
    
//------Platforms!------->
        
    
        //Platform Status Information.
        BOOL isOnMovingPlatform;
        BOOL isOnFallingPlatform;
        
        BOOL inMovingPlatformCheck;
    
        int currentActivePlatform;
    
    
        //Platform Information Arrays.
        CGPoint * platformInitialPosArray;
        CGPoint * platformFinalPosArray;    
    
        float * platformVelocityArray;
    
        BOOL * isPlatformPathHorizontalArray;
        BOOL * isPlatformPathReversedArray;
    
    
    //Platforms Dynamic Version
        CCSpriteBatchNode* platformsBatch;
        
        BOOL isFallingMoveDone;
        int *fallingPlatformsInitialYPosArray;
    
    
//-----------Teleport Data Structures.
    
        CGRect *teleportRectsArray;
        int numberOfTeleports;
        
        //gives index of connected teleport
        int * teleportDestinationsArray;
        
        //positional data of where I'm supposed to teleport
        float * teleportPlayerNewLocationsArray;
        
        //tells you where the teleport is: on the right or left walls, 
                                        // on the ceiling or the floor.
        int * typeOfTeleportsArray;
   
        
        //offset between teleporters.
        float * teleportersOffsetsArray;
    
        
    
//-------Pause Menu elements.---
    CCSprite *pauseButton, *grayBox;
    CCLabelBMFont *levelText, *resumeText, *soundsText, *backToMainTxt;
 
    BOOL levelPassed;
    
}

//-------------:PROPERTIES:------------//

@property (nonatomic, assign) BOOL isOnPauseMenu;

@property (nonatomic, assign) BOOL doesLevelHavePlatforms;
@property (nonatomic, assign) BOOL doesLevelHaveAKey;
@property (nonatomic, assign) BOOL doesLevelHaveSpikes;


@property (nonatomic, assign) int numberOfPlatforms;
@property (nonatomic, assign) int numberOfFallingPlatforms;


//-------8.23.2011: Game and UI Layer Nodes!------>

@property (nonatomic, retain) CCNode* interfaceLayer;
@property (nonatomic, retain) CCNode* gameLayer;


//-------:LEVEL VARIABLE, used to pass the current level.    
@property (nonatomic, assign) int currentLevel;

//-------:The very important Box2d World and the TMX tilemap handler

@property (nonatomic, retain) TileMapHandler* myTileMapHandler;



//-------------:GAME ENGINE FUNCTIONS:------------//
+(GameScene*) sharedGameScene;

//FUNCTIONS CREATED AT TIGJAM

//Functions to show the PauseMenu.
    -(void)goToPauseMenu;
    -(void)backToGame;

//Check Point initialization. This function wasn't created.
    //-(void)createCheckPointAt:(CGPoint)tempCheckPoint;

//Spikes creation and collision checking.
    -(void)createSpikeRectsWithArray:(NSMutableArray*)spikesRectsMutableArray;   
    -(void)checkForContactWithSpikes;

//Sparks management and check.
    -(void)createSparkRectsWithMutableArray:(NSMutableArray*)sparkRectsMutableArray;
    -(void)prepareSparkAnimationOfType:(int)sparkType;
    -(void)playerKnockedBackBySpark;
    -(void)checkForPlayerCollidingWithSpark;

//Numbered Platforms.
    -(void)createNumberedPlatformsWithArray:(NSMutableArray*)numberedPlatformsMutableArray;
    -(void)makeNextNumberedPlatformVisible;


//Gamescene initialization functions.
    +(GameScene*) sharedGameScene;
   
    +(id) sceneWithLevel:(int)levelNumber;
    -(id) initWithLevel:(int)levelNumber;
    -(void) setupTileMap;

//Game Status checks.
    -(void) gameLoop: (ccTime) dt;
    -(void)checkForWinCondition;
    -(void)checkForWinConditionWithKey;
     //-(void)checkForCheckPointPassed;

//9.17.2011 Detecting my own collisions, not using a physics engine.
    //This method checks for collisions AND assigns a status to the Player object.
    -(void)createCollisionRectsWithArray:(NSMutableArray*)collisionRectsMutableArray;    


    //Functions to be called during player collision.
    -(void)updatePlayerPosition:(ccTime)dt;     //handled by Game Logic, which supplies gravity.
    -(void)repositionPlayerWithIntersection:(CGRect)intersectRect;


//Teleport functions
    -(void)initTeleports:(int)_numberOfTeleports;
    -(void)createTeleportsWithMutableArray:(NSMutableArray*)teleportsData;
    -(void)teleportPlayerTo:(int)teleportDestinationIndex;
    -(int)getTeleportIdPair:(int)teleportId;


    //The selector that will check for teleportation.
    -(void)checkForTeleportsTimer;


//Player and door inits.

    -(void)initPlayerAtPosition:(CGPoint)spawnPosition;
    -(void)initDoorAtPosition:(CGPoint)doorPosition;
    -(void)resetPlayerAndVars;

//Game Object calls---->

    -(void)initKeyAtPosition:(CGPoint)keyPosition;
    -(void)keyCollected;


//Moving Platform calls----->
    -(void)initMovingPlatforms:(int)tempNumberOfPlatforms 
           andFallingPlatforms:(int)tempNumberOfFallingPlatforms
          andDoBPlatformsExist:(BOOL)Bexists;

    -(void)addPlatformAtPosition:(CGPoint)platformPosition 
                      withOffset:(CGPoint)platformMovementOffset
                       andIndex:(int)platformIndex;

    -(void) movingPlatformsTimer:(ccTime)dt;

    //9.2.2011: added Falling Platforms
    -(void)addFallingPlatformAtPosition:(CGPoint)platformPosition 
                           andIndex:(int)platformIndex;

    -(void) collapseFallingPlatform;
    -(void) fallingPlatformsTimer:(ccTime)dt;

//Joystick setup Function
    -(void)setupJoystickAndButtons;

//Animation status functions.
    -(void)setAnimationIsStill;
    -(void)setAnimationIsWalking;
    
    -(void)setAnimationIsJumpStarting;
    -(void)setAnimationIsJumpZeroAndFalling;

    -(void)setUpAnimation;
    -(void)animationCheck;
    
//-----***********-----:END OF PLAYER-SPECIFIC CALLBACKS--------->

//Logic to continue to the next level.

-(void)levelCompleted;
-(void)restartLevel;


@end
