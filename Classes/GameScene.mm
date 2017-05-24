//
//  GameScene.m
//  WaveProject
//
//  Created by Albith Delgado on 11. 7. 10..
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//


// Import the interfaces
#import "GameScene.h"
#import "GameConstants.h"

#import "TitleScreen.h"
#import "EndScene.h"

#import "GameSoundManager.h"


@implementation GameScene

//I don't remember what synthesize variables are, are they globals?
@synthesize myTileMapHandler , currentLevel, isOnPauseMenu;
@synthesize doesLevelHaveAKey, doesLevelHavePlatforms, doesLevelHaveSpikes;
@synthesize numberOfPlatforms, numberOfFallingPlatforms;
@synthesize gameLayer, interfaceLayer;

//Creating a singleton Gamescene instance.
static GameScene* instanceOfGameScene;
+(GameScene*) sharedGameScene;
{
	//NSAssert(instanceOfGameScene != nil, @"GameScene instance not yet initialized!");
	if(instanceOfGameScene == nil)
        return nil;
    else return instanceOfGameScene;
}

//Loading a new level.
+(id) sceneWithLevel:(int)levelNumber
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];

	// 'layer' is an autorelease object.
	GameScene *layer = [GameScene node];
    [layer initWithLevel:levelNumber];

    // Add layer as a child to scene
	[scene addChild: layer];

	// return the scene
	return scene;
}


//-------------**********-----------

-(void)setupJoystickAndButtons
{
	//Initializing our joystick object.

		leftJoy = [[[SneakyJoystickSkinnedBase alloc] init] autorelease];
		leftJoy.position = ccp(64,264);

//------

    leftJoy.backgroundSprite = [CCSprite spriteWithSpriteFrameName:@"joystickBase.png"];
    leftJoy.thumbSprite = [CCSprite spriteWithSpriteFrameName:@"joystick.png"];

    leftJoy.backgroundSprite.opacity=128;
    leftJoy.thumbSprite.opacity=128;

    //An alternate version of this, creating our sprites out of cocos2d graphics functions.
		//leftJoy.backgroundSprite = [ColoredCircleSprite circleWithColor:ccc4(255, 0, 0, 128) radius:64];
		//leftJoy.thumbSprite = [ColoredCircleSprite circleWithColor:ccc4(0, 0, 255, 200) radius:32];

//-----

        leftJoy.joystick = [[SneakyJoystick alloc] initWithRect:CGRectMake(0,0,128,128)];
		leftJoy.joystick.isDPad=YES;
		leftJoy.joystick.numberOfDirections=2;

		leftJoystick= [leftJoy.joystick retain];

		//Note: Remember to specify the z plane for the joystick.
             //(the higher the z value, the closer to the screen.
		    [interfaceLayer addChild: leftJoy z:1];


	//---Setting up our button object.

		float buttonRadius = 50;
		CGSize screenSize = [[CCDirector sharedDirector] winSize];

		jumpButton = [[[SneakyButton alloc] initWithRect:CGRectZero] autorelease];
		jumpButton.isHoldable = YES;

		skinJumpButton = [[[SneakyButtonSkinnedBase alloc] init] autorelease];
		skinJumpButton.position = CGPointMake(screenSize.width - buttonRadius * 1.5f, buttonRadius * 1.5f+200);

    //-------Setting up our jump button graphics.

    skinJumpButton.defaultSprite = [CCSprite spriteWithSpriteFrameName:@"buttonUp.png"];
    skinJumpButton.pressSprite = [CCSprite spriteWithSpriteFrameName:@"buttonDown.png"];

    skinJumpButton.defaultSprite.opacity=128;
    skinJumpButton.pressSprite.opacity=128;

    //An alternate version of this, creating our sprites out of cocos2d graphics functions.
        //skinJumpButton.defaultSprite = [ColoredCircleSprite circleWithColor:ccc4(255, 0, 0, 128) radius:50];
		//skinJumpButton.pressSprite = [ColoredCircleSprite circleWithColor:ccc4(255, 255, 0, 128) radius:50];

        //The jumpButton object is attached to the skinButton object.
        skinJumpButton.button = jumpButton;

        //Finally, attaching the jump button to the cocos2d layer.
		[interfaceLayer addChild:skinJumpButton z:1];

}


//Setting up the World and the TileMap
-(void) setupTileMap
    {

        //Drawing the tilemap tiles.
        myTileMapHandler= [[TileMapHandler alloc] init:self];
        [myTileMapHandler drawBodyTiles];

    }


//Player-specific initialization;
-(void)initPlayerAtPosition:(CGPoint)spawnPosition;
 {

    //****------0. Starting off the animation...
        //[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"playerSprites.plist"];
        CCSpriteFrame* playerFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"jumpFall.png"];
        playerSpriteBatch = [CCSpriteBatchNode batchNodeWithTexture:playerFrame.texture];
        [self addChild:playerSpriteBatch];


    //----Initializing our animation.
        //Note: the initial animation for the player is the character falling.

     [self setUpAnimation];

    //-------****------
        //1.First, Initialize the player's sprite.
        //Create the sprite and add it to the layer
        playerSprite = [CCSprite spriteWithSpriteFrameName:@"jumpFall.png"];
        playerSprite.tag=PLAYER_TAG;

        //Enlarging the sprite slightly.
        playerSprite.scale=1.1;

        //Initializing our position variables.
            playerSpawnPosition= spawnPosition;
            playerSprite.position = spawnPosition;
            //This variable is a temporary variable used to calculate position data,
                //in conjunction with the gravity and velocity variables.
            playerPosition = playerSprite.position;

            playerVelocity.x = 0;
            playerVelocity.y = 0;


        //Setting up our status flags.
            isOnMovingPlatform=NO;
            isOnFallingPlatform=NO;
            isFallingMoveDone=NO;

            spikeIsTouched=FALSE;
            doingResettingAction= FALSE;

            sparkIsTouched=FALSE;
            doingKnockedBackAction=FALSE;

            inNumberedPlatformCheck=FALSE;
            inMovingPlatformCheck=FALSE;

        currentNumberedPlatformInCheck=0;
        hasKey=NO;

        //Attaching the player to the scene.
        [gameLayer addChild:playerSprite];

        //setting the player's sound variable.
        playerWalkSoundId=-1;

        //Setting up a size variable.
        playerSpriteSize.width= 24;
        playerSpriteSize.height= 40;


        //Reducing content size, that is,
            //the bounding box(not the image) of the playerSprite.
        [playerSprite setContentSize:playerSpriteSize];

//-----Setting up our collision variables and containers.
        playerRect= playerSprite.boundingBox;

        //Setting initial collision state.
        isOnFloor=FALSE;
        isOnCeiling=FALSE;

        hitCeilingOfMovingPlatform=FALSE;

        collisionOcurred=FALSE;

        hasLeftSideCollision=FALSE;
        hasRightSideCollision=FALSE;

        spikeIsTouched=FALSE;

     //Setting additional collision variables.
        old_playerVelocity=playerVelocity.y;
        zeroVelocityReached=TRUE;

     //Set Jumping vars.
         jumpButtonWasActive=FALSE;

     //Setting the initial animation state.
         [self setAnimationIsJumpStarting];

    }


//Reset function for the player variables,
    //in case the player dies.
-(void)resetPlayerAndVars
{
    playerSprite.position = playerSpawnPosition;
    playerPosition = playerSprite.position;

    playerVelocity.x = 0;
    playerVelocity.y = 0;

    isOnFloor=NO;

    sparkIsTouched=FALSE;
    spikeIsTouched=FALSE;

    isOnMovingPlatform=NO;
    isOnFallingPlatform=NO;
    isFallingMoveDone=NO;

    inNumberedPlatformCheck=FALSE;
    inMovingPlatformCheck=FALSE;

    [self setAnimationIsJumpZeroAndFalling];
}

//Spawning the door object.
-(void)initDoorAtPosition:(CGPoint)doorPosition
{

    //First off, sprite initialization.
        // Create sprite and add it to the layer

    if(doesLevelHaveAKey)
        doorSprite = [CCSprite spriteWithSpriteFrameName:@"doorSprite.png"];
    else
        doorSprite = [CCSprite spriteWithSpriteFrameName:@"openedDoorSprite.png"];

    //Setting anchor point, position and other information.
    [doorSprite setAnchorPoint:ccp(0.5,0)];

    doorSprite.position = ccp(doorPosition.x , doorPosition.y);
    doorSprite.tag=DOOR_TAG;

    doorBoundingBox= CGRectMake(doorPosition.x-5, doorPosition.y+20, 10, 10);

    [gameLayer addChild:doorSprite];
}


//Loads the key object.
-(void)initKeyAtPosition:(CGPoint)keyPosition
{
    //First off, sprite initialization.
    // Create sprite and add it to the layer
    keySprite = [CCSprite spriteWithSpriteFrameName:@"keySprite.png"];
    [keySprite setAnchorPoint:ccp(0.5,0)];

    keySprite.position = ccp(keyPosition.x , keyPosition.y);
    keySprite.tag=KEY_TAG;

    [gameLayer addChild:keySprite];
}

//Setting up our platform variables.
-(void)initMovingPlatforms:(int)tempNumberOfPlatforms
       andFallingPlatforms:(int)tempNumberOfFallingPlatforms
        andDoBPlatformsExist:(BOOL)Bexists;
{

//0.Defining our batch node and adding it to the gameLayer.
    //spriteBatches load multiple instances of a sprite efficiently.

    CCSprite* tempImage;

    if(Bexists)
        tempImage= [CCSprite spriteWithSpriteFrameName:@"verticalMovingPlatform96.png"];
    else
        tempImage= [CCSprite spriteWithSpriteFrameName:@"movingPlatform96.png"];

    platformsBatch = [CCSpriteBatchNode batchNodeWithTexture:tempImage.texture];
    [gameLayer addChild: platformsBatch];

//----MOVING PLATFORMS INITIALIZATION
    numberOfPlatforms=tempNumberOfPlatforms;

//1.adding our platforms to the batch.

    for(int i=0; i<numberOfPlatforms; i++)
    {
        CCSprite * tempPlatform;

        if(Bexists)
            tempPlatform= [CCSprite spriteWithSpriteFrameName:@"verticalMovingPlatform96.png"];
        else
            tempPlatform= [CCSprite spriteWithSpriteFrameName:@"movingPlatform96.png"];


        if(currentLevel==7)
            tempPlatform.anchorPoint=ccp(0.5,0);
        else
            tempPlatform.anchorPoint=ccp(0,0);

        tempPlatform.visible= NO;
        tempPlatform.tag= i;    //I will iterate through the batch sprites later.

        [platformsBatch addChild:tempPlatform];
    }

    //2.Allocing our arrays of Moving Platform data.

        platformInitialPosArray=(CGPoint*) malloc(numberOfPlatforms*sizeof(CGPoint));
        platformFinalPosArray=(CGPoint*) malloc(numberOfPlatforms*sizeof(CGPoint));

        platformVelocityArray=(float*) malloc(numberOfPlatforms*sizeof(int));

        isPlatformPathHorizontalArray= (BOOL*) malloc(numberOfPlatforms*sizeof(BOOL));
        isPlatformPathReversedArray= (BOOL*) malloc(numberOfPlatforms*sizeof(BOOL));

//-------FALLING PLATFORMS INITIALIZATION

    numberOfFallingPlatforms=tempNumberOfFallingPlatforms;

    //adding our platforms to the batch.
    for(int i=0; i<tempNumberOfFallingPlatforms; i++)
    {

        CCSprite * tempPlatform= [CCSprite spriteWithSpriteFrameName:@"woodenplatform32_128.png"];

        tempPlatform.visible= NO;
        tempPlatform.tag= i+FALLING_PLATFORM_TAG_OFFSET;    //By offsetting this we can tell the platform in question is a Falling Platform.


        [platformsBatch addChild:tempPlatform];

    }

    //Allocing our arrays of Falling Platform Positions.
    fallingPlatformsInitialYPosArray=(int*) malloc(numberOfFallingPlatforms*sizeof(int));

}



//Adding our platforms to the scene.
-(void)addPlatformAtPosition:(CGPoint)platformPosition
                   withOffset:(CGPoint)platformMovementOffset
                    andIndex:(int)platformIndex
{

//To get our platforms from an array index, we need to get the batch's children.
    CCSprite* tempPlatform= (CCSprite *)[platformsBatch getChildByTag:platformIndex];

    //tempPlatform.anchorPoint=ccp(0.5,0);

    tempPlatform.visible= YES;
    tempPlatform.position= platformPosition;

//Initializing variables needed for the movement.
        CGPoint platformInitialPos= platformPosition;
        CGPoint platformFinalPos= ccpAdd(platformPosition, platformMovementOffset);

        BOOL isPlatformPathReversed=NO;
        BOOL isPlatformPathHorizontal;
        int platformVelocity;

    if (platformMovementOffset.y == 0)
    {
        //Platform Path is Horizontal
        isPlatformPathHorizontal=YES;

        if (platformMovementOffset.x <0 )
            platformVelocity= (-1)*platformSpeed;
        else
            platformVelocity= platformSpeed;

    }
    else if (platformMovementOffset.x == 0)
    {

        //Platform Path is Vertical
        isPlatformPathHorizontal=NO;

        if (platformMovementOffset.y <0 )
            platformVelocity= (-1)*platformSpeed;
        else
            platformVelocity= platformSpeed;

    }

    //Storing platform attributes (positions, speed).
        //into our arrays.
        platformInitialPosArray[platformIndex] =  platformInitialPos;
        platformFinalPosArray[platformIndex] = platformFinalPos;

        isPlatformPathHorizontalArray[platformIndex] = isPlatformPathHorizontal;
        isPlatformPathReversedArray[platformIndex] = isPlatformPathReversed;


    //Setting Platform Velocities according to the current game level.

    float platformVelocityMultiplier;

    switch (currentLevel) {
        case 6:
            platformVelocityMultiplier= 1.2f;
            break;

        case 7:
            platformVelocityMultiplier= 1.1f;
            break;

        case 14:
            platformVelocityMultiplier= 1.1f;
            break;

        case 15:
            platformVelocityMultiplier= 1.2f;
            break;

        case 18:
            platformVelocityMultiplier= 1.2f;
            break;

        case 19:
            platformVelocityMultiplier= 0.9f;
            break;

        default:
            platformVelocityMultiplier=1;
    }

        platformVelocityArray[platformIndex] = platformVelocity*platformVelocityMultiplier;

}

//Note: there doesn't seem to be falling platforms in the current game levels.
-(void)addFallingPlatformAtPosition:(CGPoint)platformPosition
                           andIndex:(int)platformIndex
{
    //To get our platforms from an array index, we need to get the batch's children.
    CCSprite* tempPlatform= (CCSprite *)[platformsBatch getChildByTag:platformIndex];

    tempPlatform.visible= YES;
    tempPlatform.position= platformPosition;

//adding data to falling positions array.
    fallingPlatformsInitialYPosArray[(platformIndex-FALLING_PLATFORM_TAG_OFFSET)]=tempPlatform.position.y;


}

-(void) collapseFallingPlatform
{

    //NSLog(@"Collapsing the platform.");
    CCSprite* tempFallingPlatform= (CCSprite *)[platformsBatch getChildByTag:currentActivePlatform];

    //2.--->move the platform Sprite offscreen with a CCAction
    //3.----->Let's do this in a CCSequence. With a delay in front.


    id delayAction= [CCDelayTime actionWithDuration:0.1f];

    id dropPlatformAction=[CCMoveBy actionWithDuration:4 position:ccp(0, -1024) ];


    id turnPlatformInvisibleAction=[CCCallBlock actionWithBlock:
                                    ^{
                                        tempFallingPlatform.visible=FALSE;
                                    }];


    [tempFallingPlatform runAction: [CCSequence actions: delayAction,
                                                         dropPlatformAction,
                                                         turnPlatformInvisibleAction, nil]];

}


//-------*****----Platform timer functions-----
    //These functions are played in the game loop, at the update() function.

//Note: not being used in the game currently.
-(void) fallingPlatformsTimer:(ccTime)dt
{

    if ( (isOnFallingPlatform) && (!isFallingMoveDone) )
    {

        CCSprite* tempFallingPlatform= (CCSprite *)[platformsBatch getChildByTag:currentActivePlatform];


        //updating the position position
         [tempFallingPlatform setPosition:
                     ccp(tempFallingPlatform.position.x ,
                         (tempFallingPlatform.position.y + fallingPlatformSpeed * dt) )];

        if(
           ( fallingPlatformsInitialYPosArray[(currentActivePlatform-FALLING_PLATFORM_TAG_OFFSET)] - tempFallingPlatform.position.y )

            >  fallingPlatformOffset  )
            isFallingMoveDone=TRUE;

    }


}


//This function moves the moving platforms
    //from an initial to a final point, and viceversa.
-(void) movingPlatformsTimer:(ccTime)dt
{
  //This timer moves All the moving platforms.
  //Therefore we need to loop through our elements.

for(int index=0; index < numberOfPlatforms; index++)
{

    CCSprite* tempPlatform= (CCSprite *)[platformsBatch getChildByTag:index];

    if(!isPlatformPathHorizontalArray[index])
    {
        //Vertical Scroll Case

        if(!isPlatformPathReversedArray[index])
        {
            //Vertical Path is not reversed.

            if(platformVelocityArray[index] > 0)
            {

              //Platform is going up.

                    if(tempPlatform.position.y >= platformFinalPosArray[index].y)
                        {
                            //Action done. We must reverse movement.
                            isPlatformPathReversedArray[index]=YES;
                            platformVelocityArray[index]= (-1)*platformVelocityArray[index];
                        }

                    else
                        {
                                //We keep moving along the Y axis.

                                [tempPlatform setPosition:
                                      ccp( tempPlatform.position.x, (tempPlatform.position.y + platformVelocityArray[index] * dt)  )];
                        }

            }

            else if(platformVelocityArray[index] < 0)
            {

               //Platform is going down.
                    if(tempPlatform.position.y <= platformFinalPosArray[index].y)
                        {
                            //Action done. We must reverse movement.
                            isPlatformPathReversedArray[index]=YES;
                            platformVelocityArray[index]= (-1)*platformVelocityArray[index];

                        }

                    else
                        {
                                //We keep moving along the Y axis.

                            [tempPlatform setPosition:
                                    ccp( tempPlatform.position.x, (tempPlatform.position.y + platformVelocityArray[index] * dt)  )];

                        }


            }


        } //end of unreversed vertical path.
        else
        {

            //Vertical Path is reversed.
            if(platformVelocityArray[index] > 0)
            {

                //Platform is going up.
                    if(tempPlatform.position.y >= platformInitialPosArray[index].y)
                        {
                            //Action done. We must unreverse movement.
                            isPlatformPathReversedArray[index]=NO;
                            platformVelocityArray[index]= (-1)*platformVelocityArray[index];

                        }

                    else
                        {
                            //We keep moving along the Y axis.

                            [tempPlatform setPosition:
                             ccp( tempPlatform.position.x, (tempPlatform.position.y + platformVelocityArray[index] * dt)  )];

                        }

            }

            else if(platformVelocityArray[index] < 0)
            {

                //Platform is going down.
                    if(tempPlatform.position.y <= platformInitialPosArray[index].y)
                        {
                            //Action done. We must unreverse movement.
                            isPlatformPathReversedArray[index]=NO;
                            platformVelocityArray[index]= (-1)*platformVelocityArray[index];


                        }

                    else
                        {

                            //We keep moving along the Y axis.
                            [tempPlatform setPosition:
                             ccp( tempPlatform.position.x, (tempPlatform.position.y + platformVelocityArray[index] * dt)  )];

                        }

            }


        }



    } //end of Vertical Scrolling Platforms code.

    else

    {
        //Horizontal Scroll Case


        if(!isPlatformPathReversedArray[index])
        {
            //Horizontal Path is not reversed.

            if(platformVelocityArray[index] > 0)
            {

                //Platform is going right.

                    if(tempPlatform.position.x >= platformFinalPosArray[index].x)
                        {
                                //Action done. We must reverse movement.
                                isPlatformPathReversedArray[index]=YES;
                                platformVelocityArray[index]= (-1)*platformVelocityArray[index];

                        }

                    else
                        {

                            //We keep moving along the X axis.
                            [tempPlatform setPosition:
                             ccp( (tempPlatform.position.x + platformVelocityArray[index] * dt) , tempPlatform.position.y   )];

                        }


            }

            else if(platformVelocityArray[index] < 0)
            {

                //Platform is going left.


                    if(tempPlatform.position.x <= platformFinalPosArray[index].x)
                        {
                                //Action done. We must reverse movement.
                                isPlatformPathReversedArray[index]=YES;
                                platformVelocityArray[index]= (-1)*platformVelocityArray[index];

                        }

                    else
                    {

                        //We keep moving along the X axis.
                        [tempPlatform setPosition:
                         ccp( (tempPlatform.position.x + platformVelocityArray[index] * dt) , tempPlatform.position.y   )];

                    }


            }




        }
        else
        {

            //Horizontal Path is reversed.

            if(platformVelocityArray[index] > 0)
            {

                //Platform is going right.
                    if(tempPlatform.position.x >= platformInitialPosArray[index].x)
                        {
                                //Action done. We must unreverse movement.
                                isPlatformPathReversedArray[index]=NO;
                                platformVelocityArray[index]= (-1)*platformVelocityArray[index];

                        }

                    else
                        {

                                //We keep moving along the X axis.

                                [tempPlatform setPosition:
                                 ccp( (tempPlatform.position.x + platformVelocityArray[index] * dt) , tempPlatform.position.y   )];

                        }




            }

            else if(platformVelocityArray[index] < 0)
            {

                //Platform is going left.


                    if(tempPlatform.position.x <= platformInitialPosArray[index].x)
                        {
                                //Action done. We must unreverse movement.
                                isPlatformPathReversedArray[index]=NO;
                                platformVelocityArray[index]= (-1)*platformVelocityArray[index];

                        }

                    else
                        {

                                //We keep moving along the X axis.
                                [tempPlatform setPosition:
                                 ccp( (tempPlatform.position.x + platformVelocityArray[index] * dt) , tempPlatform.position.y   )];

                        }


                    }

                }


            } //end of Horizontal Scrolling Platform Code.



        } //end of huge FOR loop.


}


//Note: this function is not used in the game.
    //Right now, sparks instantly kill the player,
    //and the player then has to restart.
-(void)playerKnockedBackBySpark{

//       NSLog(@"doing knocked action.");
//
//       if(playerSprite.flipX)
//           playerVelocity.x -= 60.0f;
//
//        else
//            playerVelocity.x += 60.0f;
//
//            playerVelocity.y  += 200.0f;

}

//When the player collects a key, the door exit unlocks.
-(void)keyCollected
{

    hasKey=YES;
    keySprite.visible=NO;

    [[GameSoundManager sharedManager].soundEngine  playEffect:@"warpGetKey.aif"];

    [doorSprite setDisplayFrame:
     [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"openedDoorSprite.png"]];

}


// Initializing the current level.
-(id) initWithLevel:(int)levelNumber;
{
	if( (self=[super init])) {

        //updates the singleton instance.
		currentLevel=levelNumber;
        instanceOfGameScene = self;
        levelPassed=FALSE;

    //-----0.Setting up music, according to the game level.
        if(![GameSoundManager sharedManager].soundEngine.isBackgroundMusicPlaying)
        {
            if(currentLevel>9)
            {
                [[GameSoundManager sharedManager].soundEngine  playBackgroundMusic:@"backgroundTune2.mp3"];
                //NSLog(@"Game starting, playing second track of music.");
            }

            else
            {

                [[GameSoundManager sharedManager].soundEngine  playBackgroundMusic:@"backgroundTune1.mp3"];
                //NSLog(@"Game starting, playing first track of music.");
            }
                }

        else
        {
            //Music is playing already .

            if(currentLevel==10)
            {
                [[GameSoundManager sharedManager].soundEngine  stopBackgroundMusic];
                [[GameSoundManager sharedManager].soundEngine  playBackgroundMusic:@"backgroundTune2.mp3"];
                //NSLog(@"You passed level 9,now the track changes.");

            }
            else
            {

                //NSLog(@"The music stays the same as before.");
                //Continue playing music.

            }

        }

     //----End of music setup.

//-------****-----1. Loading animation frames for the player.
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"playerSprites.plist"];

		//Enable touches
		self.isTouchEnabled = YES;

        //Initial Platform Values (before loading platforms);
            numberOfPlatforms=0;
            numberOfFallingPlatforms=0;
            numberOfNumberedPlatforms=0;

        //Teleports information
            numberOfTeleports=0;


//-------####------2. Setting up our gameScene's layers.
        interfaceLayer= [CCLayer node];
		gameLayer= [CCLayer node];

		[self addChild:gameLayer];
		[self addChild:interfaceLayer];


//-------###-------2a. Setting up the Pause Button and Pause Menu;

        isOnPauseMenu=FALSE;


            //Gray Box that darkens the entire screen.
            grayBox = [CCSprite node];
            [grayBox setTextureRect:CGRectMake(0, 0, screenWidth,screenHeight)];
            [grayBox setColor:ccBLACK];
            [grayBox setOpacity:100];
            grayBox.anchorPoint=ccp(0,0);
            grayBox.visible=NO;
            [interfaceLayer addChild:grayBox];


            //Resume Text
            resumeText=[CCLabelBMFont labelWithString:@"Resume" fntFile:@"menu_64Font.fnt"];
            resumeText.scale=0.8;
            resumeText.position=ccp(screenWidth*0.5f,screenHeight*0.5f+50);
            [interfaceLayer addChild:resumeText];

            resumeText.visible=NO;

            //Back To Main Text
            backToMainTxt=[CCLabelBMFont labelWithString:@"Back to Main Menu" fntFile:@"menu_64Font.fnt"];
            backToMainTxt.scale=0.6;
            backToMainTxt.position=ccp(screenWidth*0.5f,screenHeight*0.5f-60);
            [interfaceLayer addChild:backToMainTxt];

            backToMainTxt.visible=NO;


            //Sounds Text
            soundsText=[CCLabelBMFont labelWithString:@"sounds on" fntFile:@"menu_64Font.fnt"];

            if([GameSoundManager sharedManager].soundEngine.mute)
            {

                [soundsText setString:@"sounds off"];
                [soundsText setColor:ccGRAY];
                soundsText.tag=0;   //0 means sounds are OFF.  SOUND CONTROL VARIABLE.
            }

            else
                soundsText.tag=1; //1 means sounds are ON.  SOUND CONTROL VARIABLE.


            soundsText.scale=0.6;
            soundsText.position=ccp(screenWidth*0.5f,screenHeight*0.5f-10);
            [interfaceLayer addChild:soundsText];

            soundsText.visible=NO;


            //Pause Button
            pauseButton= [CCSprite spriteWithSpriteFrameName:@"pauseButton.png"];
            pauseButton.position=ccp(screenWidth-16, screenHeight-16);
            pauseButton.opacity=100;

            [pauseButton setContentSize:CGSizeMake(pauseButton.contentSize.width*1.4f , pauseButton.contentSize.height*1.4f )];
            [interfaceLayer addChild:pauseButton];


//--------#####-------3.Creating the TileMap and the Box2d World

        [self setupTileMap];

//--------3.5 ---creating Joystick and Timers

        [self setupJoystickAndButtons];

//-------4.----- Special check: IF we are in level 0,
        //add a brief explanation at the bottom of the screen:
        if(currentLevel==0)
        {
            //add intro level sentence.
            CCLabelBMFont *level0_Intro= [CCLabelBMFont labelWithString:kTutorialString1 fntFile:@"menu_64Font.fnt"];

            //level0_Intro.scale= 1.3;
            level0_Intro.position=ccp(384, 920);
            //level0_Intro.opacity=0;
            [gameLayer addChild:level0_Intro];

            //add arrows and an explanation for the controls.
            //have the explanations Blink (they're really just 1 word per button)
            CCSprite *arrowLeft= [CCSprite spriteWithFile:@"flecha.png"];
            arrowLeft.position=ccp(180, 190);
            arrowLeft.scale=0.6;
            [gameLayer addChild:arrowLeft];

            CCSprite *arrowRight= [CCSprite spriteWithTexture:arrowLeft.texture];
            arrowRight.flipX=YES;
            arrowRight.position=ccp(588, 190);
            arrowRight.scale=0.6;
            [gameLayer addChild:arrowRight];

            //Our text in the introduction consists of text saved as image files.
            CCSprite *moveText= [CCSprite spriteWithFile:@"move.png"];
            moveText.position=ccp(230, 115);
            moveText.scale=0.7;
            moveText.color=ccBLUE;
            [gameLayer addChild:moveText];

            CCSprite *jumpText= [CCSprite spriteWithFile:@"jump.png"];
            jumpText.position=ccp(538, 115);
            jumpText.scale=0.7;
            jumpText.color=ccYELLOW;
            [gameLayer addChild:jumpText];


            //Next, create and run blinking actions for 'move' and 'jump'.
            id colorChangeAction1= [CCCallBlock actionWithBlock:
                                    ^{

                                        moveText.color= ccYELLOW;
                                        jumpText.color= ccBLUE;

                                    }];

            id colorChangeAction2= [CCCallBlock actionWithBlock:
                                    ^{

                                        moveText.color= ccBLUE;
                                        jumpText.color= ccYELLOW;

                                    }];


            [self runAction:[CCRepeatForever actionWithAction:
                             [CCSequence actions:   colorChangeAction1 ,
                                                    [CCDelayTime actionWithDuration:0.85f],
                                                    colorChangeAction2,
                                                    [CCDelayTime actionWithDuration:0.85f],
                                nil]]  ];

        }   //end of explanations addition to the first level.

//-----Preparing the loops to call for gameplay.
    id levelTextFinal;
    id callLoopsBlock= [CCCallBlock actionWithBlock:
                            ^{

                                //Game Level Logic is launched here. Important!

                                [self schedule: @selector(gameLoop:)];
                                [self schedule:@selector(animationCheck)];

                                //--------creating Platforms.

                                if (doesLevelHavePlatforms)
                                    [self schedule: @selector(movingPlatformsTimer:)];

                                //Teleports
                                if(numberOfTeleports>0)
                                    [self schedule: @selector(checkForTeleportsTimer)];



                            }];

//--------If currentLevel is greater than 0,
        //setup the filename of the next level to call.
    //Also, isplay the current level number at the start of the level.
    if(currentLevel >0 )
    {
        NSString* levelString;

        id delayAction;

        if(currentLevel<NUMBER_OF_LEVELS)
        {
            levelString= [NSString stringWithFormat:@"Level %d", currentLevel];
            delayAction= [CCDelayTime actionWithDuration:0.3f];
        }
        else
        {
            levelString= [NSString stringWithFormat:@"Last Level!", currentLevel];
            delayAction= [CCDelayTime actionWithDuration:0.45f];
        }

        levelText= [CCLabelBMFont labelWithString:levelString fntFile:@"menu_64Font.fnt"];
        levelText.position= ccp(screenWidth*0.5f, screenHeight*0.5f+150);
        levelText.opacity= 0;

        [interfaceLayer addChild:levelText];

        //Creating animations for the new level transition.

        id fadingText= [CCFadeIn actionWithDuration:0.3f];
        id dropinText= [CCMoveBy actionWithDuration:0.3f position:ccp(0, -150)];

        id fadingOutText= [CCFadeOut actionWithDuration:0.3f];
        id dropOutText= [CCMoveBy actionWithDuration:0.2f position:ccp(0, -150)];

        id levelTextInSequence= [CCSpawn actions:fadingText, dropinText, nil];
        id levelTextOutSequence= [CCSpawn actions:fadingOutText, dropOutText, nil];

        levelTextFinal=[CCSequence actions:levelTextInSequence, delayAction, levelTextOutSequence, nil];

    }

        //Now let's run all our actions.
            //These include:
                //Setting up the game loops, that will start running as soon
                    //as the level loads.
                //Executing the level start animations,
                    //which consist of showing the level number briefly, before fading this out.

        if(currentLevel==0)
            [self runAction:callLoopsBlock ];
        else
            [levelText runAction:[CCSpawn actions: levelTextFinal, callLoopsBlock, nil]   ];


	}
	return self;

}   //end of the level initialization function.



//------*********------:GAME LOOP-----------
-(void) gameLoop: (ccTime) dt
{


//    if (playerVelocity.y == 0.0f)
//        NSLog(@"Velocity Y is 0. Player X is %f, Y is %f.",playerPosition.x, playerPosition.y);


//------1. First, check for collision with spikes, if the level has spikes.
    if(doesLevelHaveSpikes)
        [self checkForContactWithSpikes];

    if(numberOfSparks>0)
        [self checkForPlayerCollidingWithSpark];


//------2. Check if the level's winning condition is satisfied.
    if (!doesLevelHaveAKey)
        [self checkForWinCondition];
    else
        [self checkForWinConditionWithKey];

//-------3.Next, perform the Position and Collision Logic check.
    //Testing the player's X and Y coordinates,
        //if We are colliding with something, update the player's state and position.
    [self updatePlayerPosition:dt];

    //Performing this check in this particular level, in case a bug occurs.
    if(currentLevel==7)
    {
        if (playerSprite.position.y<  -50)
            [self resetPlayerAndVars];
    }

}

//If the level features numbered platforms, create them here.
-(void)createNumberedPlatformsWithArray:(NSMutableArray*)numberedPlatformsMutableArray
{

//First: We sort the numbered platforms array,
    //because we have no idea if the numbered platforms are sorted.
    [numberedPlatformsArray sortUsingDescriptors:[NSArray arrayWithObject:[[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES] autorelease]]];

//Setting the amount of numbered platforms in view.
    numberOfNumberedPlatforms= [numberedPlatformsMutableArray count];
    if(numberOfNumberedPlatforms > kMaxNumberedPlatforms)
        numberOfNumberedPlatforms= kMaxNumberedPlatforms;

    //Initially there is only one visible numbered platform.
    numberOfVisibleNumberedPlatforms=1;

//Let's allocate our array of Visible Numbered Platforms.
    numberedPlatformsArray= [NSMutableArray arrayWithCapacity:numberOfNumberedPlatforms];

    //Placing the numbered platforms in the gameScene.
    for(int index=0; index<numberOfNumberedPlatforms; index++)
    {
        CCSprite* tempNumberedPlatform=[CCSprite spriteWithSpriteFrameName:
                                        [NSString stringWithFormat:@"p%d.png", (index+1) ]
                                        ];
        tempNumberedPlatform.anchorPoint= ccp(0,0);

        //All platforms except the first one start out as invisible.
        if(index!=0)
            tempNumberedPlatform.visible=NO;

        //Getting position information from Original Mutable Array.
        int x = [[[numberedPlatformsMutableArray objectAtIndex:index] valueForKey:@"x"] intValue];
        int y = [[[numberedPlatformsMutableArray objectAtIndex:index] valueForKey:@"y"] intValue];
        [tempNumberedPlatform setPosition:ccp(x,y)];

        //Attaching our array.
        [numberedPlatformsArray insertObject:tempNumberedPlatform atIndex:index];
        [gameLayer addChild:tempNumberedPlatform];

        //NSLog(@"index for numbered platform init is %d", index);
    }

    //I don't remember why I'm performing a retain call on this array.
    [numberedPlatformsArray retain];

//Checking the contents of our array.  Not performing this check right now.
        //NSLog(@"Original mutable array description:%@" ,[numberedPlatformsMutableArray description]);
        //NSLog(@" Mutable array with CCSprites description:%@" ,[numberedPlatformsArray description]);

    //Testing our Mutable Array of CCSprites.
        //    CCSprite *tempPlatform=(CCSprite*)[numberedPlatformsArray objectAtIndex:0] ;
        //
        //    CGRect tempPlatformBoundingBox= tempPlatform.boundingBox;
        //
        //    NSLog(@"from mutable array: the first platform is located at: X %f, Y %f",
        //          tempPlatformBoundingBox.origin.x, tempPlatformBoundingBox.origin.y);

}

//When the player jumps on a numbered platform,
    //the next one in the array appears.
-(void)makeNextNumberedPlatformVisible
{
  if(currentNumberedPlatformInCheck == (numberOfVisibleNumberedPlatforms-1 )  )
     {
      if (numberOfVisibleNumberedPlatforms < numberOfNumberedPlatforms)
        {

            //NSLog(@"showing next platform. Number of visible platforms is %d", numberOfVisibleNumberedPlatforms);

            numberOfVisibleNumberedPlatforms++;

            ((CCSprite*)[numberedPlatformsArray objectAtIndex:(numberOfVisibleNumberedPlatforms-1)]).visible= YES;

            [[GameSoundManager sharedManager].soundEngine  playEffect:@"warpPlatformStep.aif"];
        }

    }


}


//Setting up the spark obstacles.
    //These obstacles spin around different platforms at a high speed.
    //The player must avoid them.
-(void)prepareSparkAnimationOfType:(int)sparkType
{
    NSMutableArray *sparkFrames = [NSMutableArray array];

    int sparkNumberOfFrames;

    switch (sparkType) {
        case 1:
            sparkNumberOfFrames=4;
            break;
        case 2:
            sparkNumberOfFrames=5;
            break;
        case 3:
            sparkNumberOfFrames=8;
            break;

        default:
            sparkNumberOfFrames=8;
            NSLog(@"Warning: Incorrect sparkType entered.  prepareSparkAnimationOfType.");
            break;
    }

    //Fetching the animation frames and storing them in a mutable array.
    for (int i =0 ; i < sparkNumberOfFrames; i++) {

        CCSpriteFrame *frame;
       // NSLog(@"%@", [NSString stringWithFormat:@"chispa%d_%d.png", sparkType, i ]);
            frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
                     [NSString stringWithFormat:@"chispa%d_%d.png", sparkType, i ]];
            [sparkFrames addObject:frame];

    }

    //After fetching our animation frames, add the animation to the spark object.
    CCAnimation* temp_sparkAnimate = [[CCAnimation animationWithFrames:sparkFrames delay:0.1f] retain] ;
    sparkAnimation = [[CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:temp_sparkAnimate restoreOriginalFrame:NO]] retain];

}


//Placing the Spark objects in the scene.
-(void)createSparkRectsWithMutableArray:(NSMutableArray*)sparkRectsMutableArray
{
    numberOfSparks= [sparkRectsMutableArray count];

    //1.allocate our spark CCSpriteBatchNode.
        int sparkType;

        //Check For Spark Type. There are 3 different types of spark sprites.
        if(currentLevel < 8)
            sparkType=1;
        else if(currentLevel <14)
            sparkType=2;
        else
            sparkType=3;

    //Add the spark animation frames to the gameScene.
    CCSprite *tempImage= [CCSprite spriteWithSpriteFrameName:@"chispa2_0.png"];
    sparksBatch = [CCSpriteBatchNode batchNodeWithTexture:tempImage.texture];
    [gameLayer addChild: sparksBatch];

        //Prepare the spark animation (by fetching the right frames) and run it.
        [self prepareSparkAnimationOfType:sparkType];
        NSLog(@"finished preparing Spark Animations.");

    int order=1;
    int index=0;

    //2.Next, define the path that each spark object will take.
        //This is done by fetching the platform each spark is associated with.
        //The spark object will then move along the perimeter of this platform.

        //In this same loop, add the spark objects one by one to the gameScene,
            //and run each object's animation loop.
    for (NSDictionary* currentSparkInfo in sparkRectsMutableArray)
    {
        //A. Add a sprite to the batch Node.
            CCSprite * tempSpark= [CCSprite spriteWithTexture:tempImage.texture];

            //B. Give the spark a position.
            CGPoint sparkStartPosition;
            int sparkTravelWidth, sparkTravelHeight;


                sparkStartPosition.x = [[currentSparkInfo valueForKey:@"x"] intValue];
                sparkStartPosition.y = [[currentSparkInfo valueForKey:@"y"] intValue];

                tempSpark.position= sparkStartPosition;
                tempSpark.tag=index;

                //getting width and height values of CGrect
                    sparkTravelWidth= [[currentSparkInfo valueForKey:@"width"] intValue];
                    sparkTravelHeight= [[currentSparkInfo valueForKey:@"height"] intValue];

        //3.create the actions for each spark and run them.
            //This is kind of long.
        id goUpAction1, goRightAction2, goDownAction3, goLeftAction4;

        float horizSparkSpeed, verticalSparkSpeed;

//Note: this commented-out section is an older way of setting the spark's path.
    //        if(currentLevel==13)
    //        {
    //
    //            goUpAction1=[CCMoveBy actionWithDuration:sparkMoveSpeed position:ccp(0, sparkTravelHeight)];
    //            goRightAction2=[CCMoveBy actionWithDuration:sparkMoveSpeed*0.25f position:ccp(sparkTravelWidth,0) ];
    //            goDownAction3=[CCMoveBy actionWithDuration:sparkMoveSpeed position:ccp(0, -sparkTravelHeight) ];
    //            goLeftAction4=[CCMoveBy actionWithDuration:sparkMoveSpeed*0.25f position:ccp(-sparkTravelWidth,0) ];
    //
    //
    //        }
    //
    //        else if ( (currentLevel==14) || (currentLevel==4) || (currentLevel==5) ){
    //
    //            goUpAction1=[CCMoveBy actionWithDuration:sparkMoveSpeed*0.25f position:ccp(0, sparkTravelHeight)];
    //            goRightAction2=[CCMoveBy actionWithDuration:sparkMoveSpeed position:ccp(sparkTravelWidth,0) ];
    //            goDownAction3=[CCMoveBy actionWithDuration:sparkMoveSpeed*0.25f position:ccp(0, -sparkTravelHeight) ];
    //            goLeftAction4=[CCMoveBy actionWithDuration:sparkMoveSpeed position:ccp(-sparkTravelWidth,0) ];
    //
    //        }
    //
    //        else{
    //
    //        goUpAction1=[CCMoveBy actionWithDuration:sparkMoveSpeed position:ccp(0, sparkTravelHeight)];
    //        goRightAction2=[CCMoveBy actionWithDuration:sparkMoveSpeed*1.5f position:ccp(sparkTravelWidth,0) ];
    //        goDownAction3=[CCMoveBy actionWithDuration:sparkMoveSpeed position:ccp(0, -sparkTravelHeight) ];
    //        goLeftAction4=[CCMoveBy actionWithDuration:sparkMoveSpeed*1.5f position:ccp(-sparkTravelWidth,0) ];
    //
    //        }

        //Increasing the speed of the spark's movement according to the game's level.
        switch (currentLevel) {

            case 4:
                verticalSparkSpeed= sparkMoveSpeed*0.25f;
                horizSparkSpeed= sparkMoveSpeed;
                break;

            case 5:
                verticalSparkSpeed= sparkMoveSpeed*0.25f;
                horizSparkSpeed= sparkMoveSpeed;
                break;

            case 6:
                verticalSparkSpeed= sparkMoveSpeed*0.45f;
                horizSparkSpeed= sparkMoveSpeed*0.6f;
                break;

            case 13:
                verticalSparkSpeed= sparkMoveSpeed;
                horizSparkSpeed= sparkMoveSpeed*0.25f;
                break;

            case 14:
                verticalSparkSpeed= sparkMoveSpeed*0.25f;
                horizSparkSpeed= sparkMoveSpeed;
                break;

            case 17:
                verticalSparkSpeed= sparkMoveSpeed*0.6f;
                horizSparkSpeed= sparkMoveSpeed;
                break;

            default:
                verticalSparkSpeed= sparkMoveSpeed;
                horizSparkSpeed= sparkMoveSpeed*1.5f;
                break;
        }


        //Defining the spark's movement pattern and speed.
        goUpAction1=[CCMoveBy actionWithDuration:verticalSparkSpeed position:ccp(0, sparkTravelHeight)];
        goRightAction2=[CCMoveBy actionWithDuration:horizSparkSpeed position:ccp(sparkTravelWidth,0) ];
        goDownAction3=[CCMoveBy actionWithDuration:verticalSparkSpeed position:ccp(0, -sparkTravelHeight) ];
        goLeftAction4=[CCMoveBy actionWithDuration:horizSparkSpeed position:ccp(-sparkTravelWidth,0) ];


        id sparkMoveAction;
        order *= -1;

        //Setting a clockwise or counter-clockwise movement pattern.
        if(order > 0)
            sparkMoveAction= [CCRepeatForever actionWithAction:[CCSequence actions: goUpAction1, goRightAction2,
                                 goDownAction3, goLeftAction4, nil] ];
        else
            sparkMoveAction= [CCRepeatForever actionWithAction:[CCSequence actions: goRightAction2, goUpAction1,
                                               goLeftAction4, goDownAction3, nil] ];


        [tempSpark runAction:sparkMoveAction];

        if(index==0)
            [tempSpark runAction:sparkAnimation ];
        else
            [tempSpark runAction:[[sparkAnimation copy] autorelease]   ];

        //Finally: CCSrites that use images from a batchNode get attached to the batchNode,
            //not to the gameScene directly.
        [sparksBatch addChild:tempSpark];

        index++;
    }

}


//If the player's rectangle collides with any of the sparks' collision boxes,
    //the player is reset.
-(void)checkForPlayerCollidingWithSpark
{
    //NSLog(@"have we any spark collisions?");

   //Verifying no spark death sequence is already occurring.
    if(!sparkIsTouched)
    {
      for (int i=0; i< numberOfSparks; i++)
       {

           CCSprite* sparkSprite= (CCSprite*)[sparksBatch getChildByTag:i];

           if (CGRectIntersectsRect(sparkSprite.boundingBox, playerSprite.boundingBox))
               {

                   //knock the playerBack
                   sparkIsTouched=TRUE;
                   break;
               }

       }

    if( (!doingKnockedBackAction) && (sparkIsTouched) )
        {
            if(isWalking)
                [playerSprite stopAction:walkAction];

            else if(isStill)
                [playerSprite stopAction:standingAnimation];

            //The doingKnockedBackAction state means the player character sprite will change to a death animation,
                //and then its position will be reset to the level's spawn point.
                //While this is happening, the player doesn't have control of the player character.
            doingKnockedBackAction=TRUE;

            //if(isOnFloor)
                //[playerSprite stopAllActions];

            //Reset the player position and delay the calling of that action.
            id resetPlayerPosition=[CCCallBlock actionWithBlock:
                                    ^{
                                        //NSLog(@"death animation 2 done.");
                                        [self resetPlayerAndVars];
                                    }];

            id resetPlayerDone=[CCCallBlock actionWithBlock:
                                ^{
                                    doingKnockedBackAction=FALSE;
                                }];

            //Run the player's death animation, and the player object's reset.
            [playerSprite runAction:[CCSequence actions:deathAnimation2,
                                    resetPlayerPosition, resetPlayerDone, nil]];

            if(currentLevel<14)
                [[GameSoundManager sharedManager].soundEngine  playEffect:@"warpElectrocute.aif"];
            else
                [[GameSoundManager sharedManager].soundEngine  playEffect:@"warpBlade.aif"];

         }

    }

} //end of the player-spark collision check.


//If the player's rectangle collides with any of the spikes' collision boxes,
    //the player is reset.
-(void) checkForContactWithSpikes
{

    if(!spikeIsTouched)
    {

        for (int index=0; index<numberOfSpikeRects; index++)
        {


            if( CGRectIntersectsRect(playerSprite.boundingBox, spikeRectsArray[index] ) )
            {
                spikeIsTouched= TRUE;
                break;
            }

        }


    }

    if( (!doingResettingAction) && (spikeIsTouched) )
    {

        if(isWalking)
            [playerSprite stopAction:walkAction];

        else if(isStill)
            [playerSprite stopAction:standingAnimation];



        doingResettingAction= TRUE;


        //Reset the player position and delay the calling of that action.
        id resetPlayerPosition=[CCCallBlock actionWithBlock:
                                ^{

                                    //NSLog(@"death animation 1 done.");
                                    [self resetPlayerAndVars];
                                }];

        id resetPlayerDone=[CCCallBlock actionWithBlock:
                                ^{

                                    doingResettingAction=FALSE;

                                }];


        [playerSprite runAction:[CCSequence actions:deathAnimation1,
                                resetPlayerPosition, resetPlayerDone, nil]];


        [[GameSoundManager sharedManager].soundEngine  playEffect:@"warpYell.aif"];


    }

}


//Checking if:
    //the level's key has been collected (if there's a key in this level).
    //once the first condition is met, the player has entered th door object.
-(void)checkForWinConditionWithKey
{

    if(hasKey)
    {
        //We have the key. Check if we are in contact with the Door.
        if( CGRectIntersectsRect(playerSprite.boundingBox, doorBoundingBox) )
           {
                   [self levelCompleted];
           }
    }

    //don't have the Key yet? then check for a collision with the Key.

    else
    {
        if( CGRectIntersectsRect(playerSprite.boundingBox, keySprite.boundingBox) )
           {
               [self keyCollected];
           }

    }

}

//If there's not a key in this level,
    //just verify if the player has entered the door object.
-(void)checkForWinCondition
{
        if( CGRectIntersectsRect(playerSprite.boundingBox, doorBoundingBox) && !levelPassed )
        {
                levelPassed=TRUE;
                [self levelCompleted];
        }
}


//-------********------:Player collision check and updating the player's position.----

-(void)updatePlayerPosition:(ccTime)dt
{

//------------------1. Updating playerPosition on the X axis.

    //If the player is not currently being reset:
   if((!doingResettingAction)&&(!doingKnockedBackAction))
    {
        //Get the joystick input, multiply it by a velocity vector.
        CGPoint scaledVelocity = ccpMult(leftJoystick.velocity, JOYSTICK_VELOCITY_MULTIPLIER);

        //Update the player's X axis:
        playerPosition.x += (scaledVelocity.x + playerVelocity.x )* MY_TIME_STEP;

        //Flipping the player sprite, based on joystick input.
        if (leftJoystick.velocity.x < 0)
            playerSprite.flipX=TRUE;
        else if (leftJoystick.velocity.x > 0)
            playerSprite.flipX=FALSE;

   }
// ----------------2. Let's update playerPosition.Y.

    //A. adding the force of gravity. Gravity will always push the player down.
        playerVelocity.y += GRAVITY * MY_TIME_STEP;

        //Checking if playerVelocity.y has gone from positive to zero.
            //Meaning, was the player rising and is now suspended in the air?
            //(and about to fall?)
        if ( (old_playerVelocity>0) && (playerVelocity.y<0) )
        {
            zeroVelocityReached=TRUE;
        }
        else
            zeroVelocityReached=FALSE;


        //9.19.2011: Capping the falling velocity to a minimum value.
            //This way, the player doesn't become too quick to tunnel through objects.
        if (playerVelocity.y < kMinVelocity)
                         playerVelocity.y= kMinVelocity;

        //Updating the old Player Velocity value.
        old_playerVelocity=playerVelocity.y;

        //Updating the player's Y axis:
        if ((!doingResettingAction)&&(!doingKnockedBackAction))
            playerPosition.y += playerVelocity.y * MY_TIME_STEP;



    //B. Check if the player is jumping. Modify playerPosition.y if he's jumping.

        if ( (jumpButton.active)&&(!jumpButtonWasActive)&&(!sparkIsTouched)&&(!spikeIsTouched) )
          if(isOnFloor)
            {

                [self setAnimationIsJumpStarting];

                isOnFloor=FALSE;

                playerVelocity.y= JUMP_YVELOCITY + fabsf(playerVelocity.x);
                playerPosition.y += playerVelocity.y * MY_TIME_STEP;

                jumpButtonWasActive=TRUE;

                [[GameSoundManager sharedManager].soundEngine  playEffect:@"warpJump.aif"];

            }

        //If the player quickly releases the jump button, cut the jump short.
            //This is done by reducing the player's Y velocity.
            //This gives the player finer control over the character's jump, just like in the Mario games.
        if((jumpButtonWasActive)&&(!jumpButton.active)&&(playerVelocity.y>0))
        {
            //cutting the jump short when jump button isn't pressed.
            if(playerVelocity.y > 350.0f)
                playerVelocity.y=50;
        }

        //Checking if the player has released the jump button.
        if(!jumpButton.active)
            jumpButtonWasActive=FALSE;
        else
            jumpButtonWasActive=TRUE;

//3. --------Testing for collisions between the player and the level's tilemap.
        //Update the player's position if there is a collision.

    //Calculating the player Rect in its current position,
        //before testing for collisions.
    playerRect=CGRectMake(playerPosition.x-playerSpriteSize.width*0.5,
                                playerPosition.y-playerSpriteSize.height*0.5,
                                 playerSpriteSize.width,
                                 playerSpriteSize.height);

    //---COLLISION LOGIC:--------------
    int numberOfCollisions=0;

    //A. Checking for level tilemap collisions.
        //Looping through every collision box in the tilemap and doing the following:
    for (int index=0; index<numberOfCollisionRects; index++)
    {

        //Checking: does the playerRect intersect with this current tilemap rect?
        CGRect intersectionResult= CGRectIntersection(playerRect, collisionRectsArray[index]);

        //if not, do nothing.
        if ( CGRectIsNull(intersectionResult) )
        {
            //do nothing
        }

        //if true, reposition the playerRect.
        else
        {
            [self repositionPlayerWithIntersection:intersectionResult ];
            //increase the number of collisions.
            numberOfCollisions++;
        }

    }

    //B.Checking for collisions with the numbered platforms.

  //If there are any numbered platforms in this level:
  if(numberOfNumberedPlatforms  > 0)
  {
        inNumberedPlatformCheck= TRUE;

        for (int index=0; index<numberOfVisibleNumberedPlatforms; index++)
        {

            //Perform the same rectangle intersection check as before.
            CGRect tempPlatformBoundingBox= ((CCSprite*)[numberedPlatformsArray objectAtIndex:index]).boundingBox;
            CGRect intersectionResult= CGRectIntersection(playerRect, tempPlatformBoundingBox);

            if ( CGRectIsNull(intersectionResult) )
            {
                //do nothing
            }

            else
            {

                [self repositionPlayerWithIntersection:intersectionResult ];
                numberOfCollisions++;
            }

            currentNumberedPlatformInCheck++;

        }

    inNumberedPlatformCheck=FALSE;
    currentNumberedPlatformInCheck=0;

  }


    //C.Check for collisions with moving platform.
    if(doesLevelHavePlatforms)
    {
        inMovingPlatformCheck=TRUE;

        for (int index=0; index<numberOfPlatforms; index++)
        {
            //Perform the same rectangle intersection check as before.

            CCSprite* tempPlatform= (CCSprite *)[platformsBatch getChildByTag:index];
            CGRect intersectionResult= CGRectIntersection(playerRect, tempPlatform.boundingBox);

            if ( CGRectIsNull(intersectionResult) )
            {

                //do nothing
            }

            else
            {
                [self repositionPlayerWithIntersection:intersectionResult];
                numberOfCollisions++;

                if(isOnMovingPlatform)
                        currentActivePlatform=index;

                //NSLog(@"isOnFloor is %d, isOnCeiling is %d and  isOnMovingPlatform is %d " ,
                      //isOnFloor, isOnCeiling, isOnMovingPlatform);
            }

        }

        inMovingPlatformCheck=FALSE;

    }

    //--After all the collision checks have been performed,
        //set the collision flags according to what has happened.

    if(numberOfCollisions>0)
    {
        collisionOcurred=TRUE;

    }

    else
    {
        //If there have been no collisions,
            //we assume the player is in the air.
        collisionOcurred=FALSE;

        isOnFloor=FALSE;
        isOnCeiling=FALSE;

        hasRightSideCollision=FALSE;
        hasLeftSideCollision=FALSE;
        isOnMovingPlatform=FALSE;

        sparkIsTouched=FALSE;
        //NSLog(@"Is on air.");
    }


//C. Is the Player on a Moving Platform? Then add a Platform Velocity Factor.
    //This will make the player move properly with the platform.
    if(isOnMovingPlatform)
    {  //Adding Velocity Vector of Moving Platform to the Player

      if (!isPlatformPathHorizontalArray[currentActivePlatform])
      {
          //Platform scrolls vertically
          playerPosition.y += platformVelocityArray[currentActivePlatform] * dt;

      }

      else
      {
          //Platform scrolls horizontally
          playerPosition.x += platformVelocityArray[currentActivePlatform] * dt;
      }

  }

//---END OF:-- COLLISION LOGIC-----


//Finally: After the playerRect's position has been adjusted
    //according to the collisions, ipdate the Player Position.'

        [playerSprite setPosition:playerPosition];

    if (collisionOcurred)
        if( isOnFloor || isOnCeiling )
        {
            if(hitCeilingOfMovingPlatform)
                playerVelocity.y=-80;
            else
                playerVelocity.y=0;

            hitCeilingOfMovingPlatform=FALSE;
        }

    //Debug information calls:
        //NSLog(@"isOnFloor is %d, isOnCeiling is %d, hasRightSideCollision is %d  and  hasLefSideCollision is %d",
            //isOnFloor, isOnCeiling, hasRightSideCollision, hasLeftSideCollision);
        //NSLog(@"playerSpritePosition is X  %f, Y  %f.", playerSprite.position.x, playerSprite.position.y);

}

//This method changes the player's current animation,
    //based on the player's status flags.
-(void)animationCheck
{
    //Checking if the character is walking to the left or right.
    if ( (leftJoystick.velocity.x < 0) || (leftJoystick.velocity.x > 0) )
    {
        if (playerVelocity.y == 0)
            if(!isWalking)
                [self setAnimationIsWalking];
            else
            {
                //Do nothing. Carry on as before.
            }
    }

    //Checking if the character is sitting still, idle.
    if  (leftJoystick.velocity.x == 0)
    {
        if (playerVelocity.y == 0)
            if(isStill)
            {
                //Do nothing. Carry on as before.
            }
            else
                [self setAnimationIsStill];
    }

    //Checking if the player is on the air, either jumping or falling.
    if (playerVelocity.y < 0)
    {
        if (isOnFloor)
        {
            //Do nothing. Carry on as before.
        }
        else if(!isJumpZeroStarted)
            [self setAnimationIsJumpZeroAndFalling];

    }

}


//Helper function for collision check:
    //Creating Collision Rectangles and storing them in an array of CGrects.
-(void)createCollisionRectsWithArray:(NSMutableArray*)collisionRectsMutableArray
{
    //Initializing our CGRect array and our array.
    numberOfCollisionRects= [collisionRectsMutableArray count];
    collisionRectsArray = (CGRect*) malloc(numberOfCollisionRects*sizeof(CGRect));

    NSDictionary* currentCGRectInfo;

    int index=0;

    //Extracting the CGRect data from mutable array in the tiled map.
    for (currentCGRectInfo in collisionRectsMutableArray)
         {

             int x = [[currentCGRectInfo valueForKey:@"x"] intValue];
             int y = [[currentCGRectInfo valueForKey:@"y"] intValue];

             float width = [[currentCGRectInfo valueForKey:@"width"] floatValue];
             float height = [[currentCGRectInfo valueForKey:@"height"] floatValue];

             collisionRectsArray[index]= CGRectMake(x, y, width, height);

             index++;

         }

}


//----Repositioning the player object due to collisions.

-(void)repositionPlayerWithIntersection:(CGRect)intersectRect
{

    //Testing player position and intersect data.
    //NSLog(@"playerPosition.y is %f and intersectRect is %@", playerPosition.y, NSStringFromCGRect(intersectRect));

    //The intersectRect equals the common area shared by two rectangles.
        //In this case the 2 rectangles are:
            //the playerRect and the platform or tileMap area that it collides with.
        //The intersectRect is useful to compute collisions because:
            //It gives us both width and height data
            //we can use to offset the player object, so that the player is always
                //bumping into walls and solid objects (as it should be!)

//----Note: 
    //The algorithm may look redundant. It could be simplified, but it works as is.
        //It checks for collisions between the player and horizontal and vertical walls.
        
        //It also checks for collisions with corners, that is, rects that don't cover the 
            //entire width or height of the character.
//----

    //Let's verify from which direction the collision is coming from.

    //If the IntersectRect's left side is on the same position as the playerRect's left side:
        //The collision is coming from the left side of the playerRect.
    if( CGRectGetMinX(intersectRect) == CGRectGetMinX(playerRect) )
    {
        //Testing Case 1: check if the player is colliding with an object on its left side.
        if( roundf(intersectRect.size.height)==  playerRect.size.height)
            {
                //Push the player on the X axis.
                playerPosition.x += intersectRect.size.width;

                hasLeftSideCollision=TRUE;
                isOnCeiling=FALSE;

                //NSLog(@"In case 1.");
            }
        //Checking for Y-axis collisions.
        else if(intersectRect.size.width == playerRect.size.width)
        {
             //Testing Case 2: check if the player is colliding with an object -below- it.
            if( CGRectGetMinY(intersectRect) ==  CGRectGetMinY(playerRect) )
            {
                //Push the player downward on the Y axis.
                playerPosition.y += intersectRect.size.height;

                //NSLog(@"In case 2.");

                //We can say then that the player has hit the floor.
                hasLeftSideCollision=FALSE;
                hasRightSideCollision=FALSE;

                //Player is on the Floor.
                isOnFloor=TRUE;
                isOnCeiling=FALSE;

                doingKnockedBackAction= FALSE;

                //if the player is hitting a platform, turn on the flags.
                if(inNumberedPlatformCheck)
                    [self makeNextNumberedPlatformVisible];
                else if(inMovingPlatformCheck)
                    isOnMovingPlatform=TRUE;

                //jumpTurnCounter=0;
            }

            //Testing Case 3: check if the player is colliding with an object -above- it.
            else if(  CGRectGetMaxY(intersectRect)== CGRectGetMaxY(playerRect) )
                {
                    //Push the player's Y position to a position below the object.
                    playerPosition.y -= intersectRect.size.height;

                    //NSLog(@"In case 3.");

                    hasLeftSideCollision=FALSE;
                    hasRightSideCollision=FALSE;

                    //Player is on the Ceiling.
                    isOnFloor=FALSE;
                    isOnCeiling=TRUE;

                    if(inMovingPlatformCheck)
                        hitCeilingOfMovingPlatform=TRUE;

                }

        } //End of left-side collision check.

       //Checking for corner collision cases.  Collisions happening below the player.
        else if (CGRectGetMinY(intersectRect)==CGRectGetMinY(playerRect) )    //Testing Case 5
        {

            if(!hasLeftSideCollision)
            {
                //Checking for a collision on the playerRect's left corner.
                if( ( CGRectGetWidth(intersectRect) < 3.3f) && (CGRectGetHeight(intersectRect) > 5.00f) )
                {

                    //NSLog(@"Case 5, pushing X. Intersect rect Width is %f and Height is %f.", CGRectGetWidth(intersectRect), CGRectGetHeight(intersectRect));
                    playerPosition.x += intersectRect.size.width;

                    //NSLog(@"In case 5 special case, pushing X.");
                    hasLeftSideCollision=TRUE;

                }

                else
                    {
                    //If width  of the intersectRect is larger, and height is smaller, push the player object up.
                        //NSLog(@"Case 5, pushing Y. Intersect rect Width is %f and Height is %f.", CGRectGetWidth(intersectRect), CGRectGetHeight(intersectRect));
                        playerPosition.y += intersectRect.size.height;

                        //NSLog(@"In case 5, pushing Y.");

                        //Player is on the Floor
                        isOnFloor=TRUE;
                        isOnCeiling=FALSE;

                        doingKnockedBackAction=FALSE;

                        if(inNumberedPlatformCheck)
                            [self makeNextNumberedPlatformVisible];

                        if(inMovingPlatformCheck)
                            isOnMovingPlatform=TRUE;

                        //jumpTurnCounter=0;

                    }

            }

            else
            {
                //Default case: push the player to the right, on the X axis.
                playerPosition.x += intersectRect.size.width;
            }

                            }


        //Testing Case 6: Corner case, This time looking at the upper right corner of the playerRect.
        else if(CGRectGetMaxY(intersectRect)==CGRectGetMaxY(playerRect))    
        {
            //NSLog(@"Case 6. Intersect rect Width is %f and Height is %f.", CGRectGetWidth(intersectRect), CGRectGetHeight(intersectRect));
            if(!hasLeftSideCollision)
            {

                //If the intersection's height is large enough, push the player back in the X axis.
                if(intersectRect.size.height > 4.0f)
                {
                    playerPosition.x += intersectRect.size.width;
                    //NSLog(@"In case 6 special case, pushing X.");
                    hasLeftSideCollision=TRUE;

                }
                else
                    {
                        //Else, push the player downward.
                        playerPosition.y -= intersectRect.size.height;

                        //NSLog(@"In case 6, lessening Y.");

                        //Player is on the Ceiling.
                        isOnFloor=FALSE;
                        isOnCeiling=TRUE;

                        if(inMovingPlatformCheck)
                            hitCeilingOfMovingPlatform=TRUE;
                    }

            }

            else
            {

                playerPosition.x += intersectRect.size.width;


            }
                            }

         //Default logic for a left side collision: push the player object to the right side.
        else                                                       
        {
            //NSLog(@"In case 7.");

            hasLeftSideCollision=TRUE;
            playerPosition.x += intersectRect.size.width;

        }
                                                                    }

    //Next, we will check if the intersect Rect is coming from the right side of the player.                                                                
    else if(CGRectGetMaxX(intersectRect) == CGRectGetMaxX(playerRect) ) 
    {
        //Testing Case 4: Checking if the height of the intersection is the same as 
            //the height of the player.  
        //In this case, we assume we've hig a wall on the right.
            //The player gets pushed back, to the left.
        if(roundf(intersectRect.size.height) == playerRect.size.height)     
        {
            playerPosition.x -= intersectRect.size.width;

            hasRightSideCollision=TRUE;
            isOnCeiling=FALSE;

            //NSLog(@"In case 4.");
        }

        //Testing Case 8: the intersectRect's minimum Y position 
            //is the player's lower right corner Y position. (A corner case.)
        else if( CGRectGetMinY(intersectRect) == CGRectGetMinY(playerRect) )  
        {

            //NSLog(@"Case 8. Intersect rect Width is %f and Height is %f.", CGRectGetWidth(intersectRect), CGRectGetHeight(intersectRect));
           if(!hasRightSideCollision)
           {
               //If the intersectRect is tall enough and narrow enough on X, push the player back on X axis.
               if( (CGRectGetHeight(intersectRect) > 5.0f) && ( CGRectGetWidth(intersectRect) < 3.3f) )
               {
                   playerPosition.x -= intersectRect.size.width;

                   hasRightSideCollision=TRUE;

                   //NSLog(@"In case 8 special case, lessening X.");


               }

               //Case 9: Else, push the player up on the Y axis.
               else
                    {
                        playerPosition.y += intersectRect.size.height;

                        //NSLog(@"In case 8, pushing Y.");

                        //Player is on the Floor
                        isOnFloor=TRUE;
                        isOnCeiling=FALSE;

                        if(inNumberedPlatformCheck)
                            [self makeNextNumberedPlatformVisible];

                        if(inMovingPlatformCheck)
                            isOnMovingPlatform=TRUE;

                        doingKnockedBackAction=FALSE;

                        //jumpTurnCounter=0;

                        }

           }

           else //Default case 10: 
           {
              //when having a lower corner right-side collision: push the player back to the left.
               playerPosition.x -= intersectRect.size.width;

           }

                            }//end of lower right-side corner collision check.

        //Testing Case 11: Collisions coming from the top right corner.
        else if( CGRectGetMaxY(intersectRect) == CGRectGetMaxY(playerRect) )  
        {
            //Testing the output.
            //NSLog(@"Intersect Rect has Width %f and Height %f.",intersectRect.size.width, intersectRect.size.height);
            if(!hasRightSideCollision)
            {
                //If the intersectRect is tall enough, push the player back on X.
                if(intersectRect.size.height > 4.0f)
                {
                    playerPosition.x -= intersectRect.size.width;
                    //NSLog(@"In case 9 special case, lessening X.");
                    hasRightSideCollision=TRUE;

                }
                else
                {
                    //Case 12: Else, push the player down.
                    playerPosition.y -= intersectRect.size.height;
                    //NSLog(@"In case 9, lessening Y.");

                    //Player is on the Ceiling.
                    isOnFloor=FALSE;
                    isOnCeiling=TRUE;

                    if(inMovingPlatformCheck)
                        hitCeilingOfMovingPlatform=TRUE;

                }

            }

            //Case 13: default case in an upper right corner collision: push the player back on X.
            else{

                playerPosition.x -= intersectRect.size.width;

                }

        } //end of the top right corner collision check.
        
        //Testing Case 14:
        else                                                                
        {
            //when having a right-side collision, 
                //the default logic is to push the player back in X. 
            hasRightSideCollision=TRUE;

            playerPosition.x -= intersectRect.size.width;

            //NSLog(@"In case 10.");
        }
                                }  //End of the right-side collision check.


}  //End of the collision check.



// -----*********------:Animation Status Control Functions

//Executes the player's idle animation, and updates the game state.
-(void) setAnimationIsStill
{

    if((!doingResettingAction)&&(!doingKnockedBackAction))
    {
        if(isWalking)
        {
            [playerSprite stopAction: walkAction];

            //stop sound.
            if(playerWalkSoundId != -1)
            {
                [[GameSoundManager sharedManager].soundEngine stopEffect:playerWalkSoundId ];
                playerWalkSoundId=-1;
            }

        }

        isStill=TRUE;
        isWalking=FALSE;
        isJumping=FALSE;
        isJumpZeroStarted=FALSE;

        [playerSprite runAction:standingAnimation];
    }

}

//Executes the player's walking animation, and updates the game state.
-(void) setAnimationIsWalking
{

    if((!doingResettingAction)&&(!doingKnockedBackAction))
    {

        if(isOnFloor)
            [playerSprite stopAction: standingAnimation];

        isStill=FALSE;
        isWalking=TRUE;
        isJumping=FALSE;
        isJumpZeroStarted=FALSE;

        [playerSprite runAction: walkAction];

     //play Sound
        if(isOnFloor)
            playerWalkSoundId= [[GameSoundManager sharedManager].soundEngine playEffectInLoop:@"warpPlayerWalk.aif" ];

    }
}

//Executes the player's rising jump animation (until player starts falling),
        //and updates the game state.
-(void) setAnimationIsJumpStarting
{

    if((!doingResettingAction)&&(!doingKnockedBackAction))
    {

        //Stop the current animation and any sound effects playing.
        if(isWalking)
        {
            [playerSprite stopAction: walkAction];

            if(playerWalkSoundId != -1)
            {
                [[GameSoundManager sharedManager].soundEngine stopEffect:playerWalkSoundId ];
                playerWalkSoundId=-1;

            }

        }
        else
            [playerSprite stopAction:standingAnimation];

        isStill=FALSE;
        isWalking=FALSE;
        isJumping=TRUE;
        isJumpZeroStarted=FALSE;

        [playerSprite setDisplayFrame:
            [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"jumpStart.png"]];

    }

}

//Executes the player's falling animation (when player's velocity reaches 0, and drops below that),
        //and updates the game state.
-(void)setAnimationIsJumpZeroAndFalling
{

    if((!doingResettingAction)&&(!doingKnockedBackAction))
    {

        if(!isJumping)
        {

            if(isWalking)
                [playerSprite stopAction:walkAction];

            else if(isStill)
                [playerSprite stopAction:standingAnimation];

            isStill=FALSE;
            isWalking=FALSE;
            isJumping=FALSE;
            isJumpZeroStarted=TRUE;

            //stop sound effect.
            if(playerWalkSoundId != -1)
            {
                [[GameSoundManager sharedManager].soundEngine stopEffect:playerWalkSoundId ];
                playerWalkSoundId=-1;

            }

        }

//Execute the CCAction, which displays two frames of animation. 
    //So it is possible to not perform an animation in cocos2d, but to merely swap out sprites.
    [playerSprite runAction: [CCSequence actions:

                                [CCCallBlock actionWithBlock:
                                        ^{
                                            isJumpZeroStarted=TRUE;

                                            [playerSprite setDisplayFrame:
                                            [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"jumpZero.png"]];
                                                   }],

                                [CCDelayTime actionWithDuration:0.1f],

                                [CCCallBlock actionWithBlock:
                                        ^{

                                            [playerSprite setDisplayFrame:
                                            [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"jumpFall.png"]];

                                                                    }], nil]];


    }


}


//This method sets up the player's walking, idle, and death animations.
-(void)setUpAnimation
{
    //1.Setting up the idle animation.
    NSMutableArray *tempFrames = [NSMutableArray array];


    for (int i =0 ; i < 13; i++) {

        CCSpriteFrame *frame;

        frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
                 [NSString stringWithFormat:@"stand%d.png", i]];

        [tempFrames addObject:frame];

    }

    id standing = [CCAnimation animationWithFrames:tempFrames delay:0.2f] ;
    standingAnimation = [[CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:standing restoreOriginalFrame:NO]] retain];



    //2. Setup the walking animation.
    [tempFrames removeAllObjects];

    for (int i =0 ; i < 7; i++) {

        CCSpriteFrame *frame;

        frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
                     [NSString stringWithFormat:@"walk%d.png", i]];

        [tempFrames addObject:frame];

    }

    id walkAnimation = [CCAnimation animationWithFrames:tempFrames delay:0.1f]  ;
    walkAction = [[CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:walkAnimation restoreOriginalFrame:NO]] retain];


    //3.Setting up the death animations. There are three of them specified here.
    [tempFrames removeAllObjects];

    for (int i =0 ; i < 6; i++) {

        CCSpriteFrame *frame;

        frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
                 [NSString stringWithFormat:@"death1_%d.png", i]];

        [tempFrames addObject:frame];

    }

    id death1 = [CCAnimation animationWithFrames:tempFrames delay:0.07f] ;
    deathAnimation1= [[CCAnimate actionWithAnimation:death1 restoreOriginalFrame:YES] retain];

    //The second death animation.
    [tempFrames removeAllObjects];

    id death2;

    if(currentLevel<14)
    {
            for (int i =0 ; i < 2; i++) {

        CCSpriteFrame *frame;

        frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
                 [NSString stringWithFormat:@"death2_%d.png", i]];

        [tempFrames addObject:frame];

            }

    death2 = [CCAnimation animationWithFrames:tempFrames delay:0.06f] ;
    deathAnimation2= [[CCRepeat  actionWithAction:[CCAnimate actionWithAnimation:death2 restoreOriginalFrame:YES] times:4 ]retain];

    }

    //Here's a third kind of death animation.
    else
    {
        for (int i =0 ; i < 9; i++) {

            CCSpriteFrame *frame;

            frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
                     [NSString stringWithFormat:@"death3_%d.png", i]];

            [tempFrames addObject:frame];

        }

        death2 = [CCAnimation animationWithFrames:tempFrames delay:0.06f] ;
        deathAnimation2= [[CCAnimate actionWithAnimation:death2 restoreOriginalFrame:YES] retain];

    }


}


//Adding the spike objects' CGRects to each level.
    //The spike images are already present in the tileMap,
    //but their presence needs to be added to the game logic.
-(void)createSpikeRectsWithArray:(NSMutableArray*)spikesRectsMutableArray
{

    doesLevelHaveSpikes= TRUE;

    //initializing our cgrect count and  our array.
    numberOfSpikeRects= [spikesRectsMutableArray count];
    spikeRectsArray = (CGRect*) malloc(numberOfSpikeRects*sizeof(CGRect));


    NSDictionary* currentCGRectInfo;

    int index=0;

    for (currentCGRectInfo in spikesRectsMutableArray)
    {

        int x = [[currentCGRectInfo valueForKey:@"x"] intValue];
        int y = [[currentCGRectInfo valueForKey:@"y"] intValue];

        float width = [[currentCGRectInfo valueForKey:@"width"] floatValue];
        float height = [[currentCGRectInfo valueForKey:@"height"] floatValue];

        spikeRectsArray[index]= CGRectMake(x, y, width, height);

        index++;

    }

}

//---The next two functions set up the teleportation areas that exist in different
    //parts of each level, namely in the edges of the screen, when there are no 
    //walls to keep the player inside.

//--The way these teleports are setup are often maze-like.
    //Meaning, walking off one part of the screen may take the player 
    //into another unexpected side of the screen.

-(void)initTeleports:(int)_numberOfTeleports
{

    numberOfTeleports=_numberOfTeleports;

    teleportRectsArray = (CGRect*) malloc(numberOfTeleports*sizeof(CGRect));

    teleportDestinationsArray= (int*) malloc(numberOfTeleports*sizeof(int));
    teleportPlayerNewLocationsArray= (float*) malloc(numberOfTeleports*sizeof(float));
    typeOfTeleportsArray= (int*) malloc(numberOfTeleports*sizeof(int));

    //and the offsets.  Teleportation areas that are linked may be at different heights
        //or widths from each other, hence the offset value to keep track of this.
    teleportersOffsetsArray= (float*) malloc(numberOfTeleports*sizeof(float));

}

//Placing the teleport areas in the level.
-(void)createTeleportsWithMutableArray:(NSMutableArray*)teleportsData;
{

    int index=0;
    NSDictionary* currentTeleport;

    for( currentTeleport in teleportsData )
    {
        //Obtaining the following data for each teleport
            //specified in the tileMap:

            //1. The type of teleport.
            typeOfTeleportsArray[index] = [[currentTeleport valueForKey:@"type"] intValue];

            //2. The teleport's size and coordinates.
            int teleportX = [[currentTeleport valueForKey:@"x"] intValue];
            int teleportY = [[currentTeleport valueForKey:@"y"] intValue];
            int teleportWidth = [[currentTeleport valueForKey:@"width"] intValue];
            int teleportHeight = [[currentTeleport valueForKey:@"height"] intValue];

        //Creating the CGRects that describe each teleport.
        switch (typeOfTeleportsArray[index]) {
            case LEFT_WALL:
                teleportRectsArray[index]=
                CGRectMake(teleportX-teleportMinSize, teleportY, teleportMinSize, teleportHeight);
                break;
            case RIGHT_WALL:
                teleportRectsArray[index]=
                CGRectMake(teleportX, teleportY, teleportMinSize, teleportHeight);
                break;
            case CEILING:
                teleportRectsArray[index]=
                CGRectMake(teleportX, teleportY-teleportMinSize, teleportWidth, teleportMinSize);
                break;
            case FLOOR:
                teleportRectsArray[index]=
                CGRectMake(teleportX, teleportY, teleportWidth, teleportMinSize);
                break;
            default:
                NSLog(@"Warning: error at teleporter CGRect creation.");
                break;
        }



            //3. Specifying the teleporting person's new location.  
                //That is, if somebody were to teleport here,
                //the value in teleportPlayerNewLocationsArray.

                //Note: only describing one teleport location axis.
                    //For the left-right teleports: the X axis is described.
                    //For the up-down teleports: the Y axis is described.

            switch (typeOfTeleportsArray[index]) {
                case LEFT_WALL:
                    teleportPlayerNewLocationsArray[index]= playerSprite.contentSize.width/2;
                    break;
                case RIGHT_WALL:
                    teleportPlayerNewLocationsArray[index]= screenWidth-playerSprite.contentSize.width/2 ;
                    break;
                case CEILING:
                    teleportPlayerNewLocationsArray[index]= screenHeight- playerSprite.contentSize.height/2- teleportMinSize;
                    break;
                case FLOOR:
                    teleportPlayerNewLocationsArray[index]= playerSprite.contentSize.height/2+teleportMinSize;
                    break;
                default:
                    NSLog(@"Warning: error at teleporter CGRect creation.");
                    break;
            }


        //4.Next, linking teleport locations.
            //4a. Determine the given teleport's pair, meaning, where do I get to from this teleport?
                //This information is stored in the tileMap group data, under the 'name' field.
                //The id refers to the type of teleport (situated to the left, right, upper, lower part of screen)
                int currentId= [[currentTeleport valueForKey:@"name"] intValue];
                //Calling a function that will return the corresponding pair of the teleport 
                    int pairId= [self getTeleportIdPair:currentId];

                //Now let's see what element has this id. and get that element's index in the array.
                int result;
                BOOL wasResultFound=FALSE;

                //Given the type of teleport and its pair, fetch the array index in which the
                    //pair element is located.
                for (int i=0; i <numberOfTeleports; i++)
                    {

                        if( [ [ [ teleportsData objectAtIndex:i]  objectForKey:@"name"] intValue ] == pairId  )
                        {
                            result=i;
                            wasResultFound=TRUE;
                        }

                    }

                    if(!wasResultFound)
                    {

                        result= -1;
                        NSLog(@"Warning:Pair id teleport location was not found.");

                    }
                    //Storing the index of the destination teleport, for the current teleport.
                    teleportDestinationsArray[index]=result;



            //2. Calculate the given pair's offset(coordinate difference), if any, between each other.
                    //The offset is defined as follows:

                    //offset X= Floor_teleport.x - Ceiling_teleport.x;

                    //offset Y= Right Wall_teleport.y - Left Wall_teleport.y;

                    //do this if the pair id is the rightmost or the floor teleport

                    CGPoint pairID_Teleport_Point;

                    pairID_Teleport_Point.x=
                        [  [ [teleportsData objectAtIndex:teleportDestinationsArray[index] ]
                                                                        valueForKey:@"x"] intValue];

                    pairID_Teleport_Point.y=
                        [  [ [teleportsData objectAtIndex:teleportDestinationsArray[index] ]
                                                                        valueForKey:@"y"] intValue];
                    
                    //Storing offset data in the teleports' arrays.                                                       
                    if( pairId%2==0 )
                        {
                            if(typeOfTeleportsArray[index]<2) //if(currentTeleportType is Wall)
                                teleportersOffsetsArray[index]=
                                           pairID_Teleport_Point.y-[[currentTeleport valueForKey:@"y" ] intValue];
                            else
                                teleportersOffsetsArray[index]=
                                            pairID_Teleport_Point.x-[[currentTeleport valueForKey:@"x" ] intValue];


                                }
                    else
                        {
                            if(typeOfTeleportsArray[index]<2) //if(currentTeleportType is Wall)
                                teleportersOffsetsArray[index]=
                                            [[currentTeleport valueForKey:@"y" ] intValue]-pairID_Teleport_Point.y;
                            else
                                teleportersOffsetsArray[index]=
                                            [[currentTeleport valueForKey:@"x" ] intValue]-pairID_Teleport_Point.x;

                                }
        index++;


    }


}

//Method that teleports the player to the teleport pair's location.
-(void)teleportPlayerTo:(int)teleportDestinationIndex
{

    CGPoint newPlayerPosition;

    //NSLog(@"Teleporting player to Teleport number %d.", teleportDestinationIndex);

    //This function uses the offset data and new spawn point data previously 
    switch (typeOfTeleportsArray[teleportDestinationIndex]) {
        case RIGHT_WALL:
            newPlayerPosition= ccp(teleportPlayerNewLocationsArray[teleportDestinationIndex],
                                   (playerSprite.position.y + teleportersOffsetsArray[teleportDestinationIndex] ));
            break;
        case LEFT_WALL:
            newPlayerPosition= ccp(teleportPlayerNewLocationsArray[teleportDestinationIndex],
                                   (playerSprite.position.y - teleportersOffsetsArray[teleportDestinationIndex] ));
            break;
        case FLOOR:
            newPlayerPosition= ccp( (playerSprite.position.x + teleportersOffsetsArray[teleportDestinationIndex]),
                                   teleportPlayerNewLocationsArray[teleportDestinationIndex] );
            break;
        case CEILING:
            newPlayerPosition= ccp( (playerSprite.position.x- teleportersOffsetsArray[teleportDestinationIndex]),
                                   teleportPlayerNewLocationsArray[teleportDestinationIndex] );
            break;
        default:
            newPlayerPosition=playerSprite.position;
            NSLog(@"Error in Teleport function. Player was not Teleported.");
            break;
    }


    //Finally, update the player's position with this new position.
        playerPosition=newPlayerPosition;
        [playerSprite setPosition:playerPosition];

    //NSLog(@"Player's new position is: X %f, Y %f.", newPlayerPosition.x, newPlayerPosition.y);

}

-(int)getTeleportIdPair:(int)teleportId
{
    //The teleport id refers to its location on the screen.
    //It can be 1 of 4 numbers,referring to one of the 4 sides of the screen.

    //We assume that the pairs start at 1.

    //In this case: 1's pair is 2. 2's pair is 1.
                //  3's pair is 4. 4's pair is 3.
                //  and so on.

    return ( (teleportId % 2)+ teleportId -( ( teleportId +1)%2) );

   // NSLog(@"The Pair id for teleport number %d is %d", teleportId, resultId);
}


//This method sits in the game loop.  It checks to see if the player enters a teleportation area,
    //and if so, it executes the teleportation.
-(void)checkForTeleportsTimer
{
    for (int currentTeleportIndex=0; currentTeleportIndex<numberOfTeleports; currentTeleportIndex++) {

        if( CGRectIntersectsRect( playerSprite.boundingBox , teleportRectsArray[currentTeleportIndex] ) )
            {
                //NSLog(@"teleporting.");
                if((!spikeIsTouched)&&(!sparkIsTouched))
                    [self teleportPlayerTo:teleportDestinationsArray[currentTeleportIndex] ];

                break;
            }
        }

}


//-------********------:End of level and end of game logic---------

-(void)levelCompleted;
{

    NSLog(@"Level %d Completed.", currentLevel);
    //Stop any player sound running.
    if(playerWalkSoundId != -1)
    {
        [[GameSoundManager sharedManager].soundEngine stopEffect:playerWalkSoundId ];
        playerWalkSoundId=-1;
    }
    //Check if the player has completed all levels.
    if( (currentLevel+1) > NUMBER_OF_LEVELS )
        {

         //Playing the End Sequence.
            [[GameSoundManager sharedManager].soundEngine stopBackgroundMusic ];

            //Saving Level Data in the user defaults, if needed.
            NSUserDefaults* playerDefaults = [NSUserDefaults standardUserDefaults];
            NSInteger levelSaved= [playerDefaults integerForKey:@"currentLevel"];

            if(currentLevel > levelSaved)
            {
                [playerDefaults setInteger:currentLevel forKey:@"currentLevel"];
                [playerDefaults synchronize];

                NSLog(@"Saving current Level.");

            }

            NSLog(@"GameScene, levelCompleted():Game Finished.");

        //Playing a warp sound effect and ending music.
            id playWarpEffect=[CCCallBlock actionWithBlock:
                                            ^{
                                                doingResettingAction=TRUE;

                                                //[self unschedule:@selector(gameLoop:)];

                                                [[GameSoundManager sharedManager].soundEngine  playEffect:@"warpLevelFinish.aif"];

                                            }];

            //After playing these sounds, go to the Ending scene.                    
            id playThemeAndEnd=[CCCallBlock actionWithBlock:
                                            ^{

                                                [[GameSoundManager sharedManager].soundEngine  playBackgroundMusic:@"endingTheme.mp3"];
                                                [[CCDirector sharedDirector] replaceScene:[EndScene loadEndSceneCreditsOnly:FALSE]];

                                            }];


            //Run all of these actions.
            [self runAction:[CCSequence actions:playWarpEffect,[CCDelayTime actionWithDuration:1.5f ], playThemeAndEnd ,nil]];

      }
    else
    {

        //The game ending has not yet been reached.

        //Update the saved data, 
            //so that the player can quickly get to the latest level yet to be cleared.
        NSLog(@"saving.");
        NSUserDefaults* playerDefaults = [NSUserDefaults standardUserDefaults];
        NSInteger levelSaved= [playerDefaults integerForKey:@"currentLevel"];


        if(levelSaved < (currentLevel +1 ))
        {
            [playerDefaults setInteger:(currentLevel +1) forKey:@"currentLevel"];
            [playerDefaults synchronize];

        }

            [[GameSoundManager sharedManager].soundEngine  playEffect:@"warpLevelFinish.aif"];

        //Reload this gameScene class with a new level.
        [[CCDirector sharedDirector] replaceScene:[GameScene sceneWithLevel:(currentLevel+1)]];

    }

}


-(void) restartLevel
{
    //NSLog(@"restarting the Level.");
    [[CCDirector sharedDirector] replaceScene:[GameScene sceneWithLevel:(currentLevel)]];
}


//-------Implementing touch events for the pause menu.

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{

    //We will process the touch event in the 'ccTouchEnded' function,
    //so we will accept ALL touch events for now.

	return YES;
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    //NSLog(@"Touch Registered.");
    //1. Let's get the touch's coordinates.

	CGPoint location= [touch locationInView: [touch view]];
	CGPoint touchPoint= [[CCDirector sharedDirector] convertToGL:location];

    //Check if the player is touching the pause menu button on the upper right corner.
    if(!isOnPauseMenu)
    {
        if (  CGRectContainsPoint(pauseButton.boundingBox, touchPoint) )
        {
            [self goToPauseMenu];
        }

    }
    else    
    {
        //The player is in the pause menu.
            //Check if any pause menu options have been selected.

        if (  CGRectContainsPoint(resumeText.boundingBox, touchPoint) )
        {
            //The player returns to the normal game mode.
            isOnPauseMenu=FALSE;
            [self backToGame];
        }

        else if(  CGRectContainsPoint(soundsText.boundingBox, touchPoint) )
        {
            //Pressed the game sound toggle option.

           if(soundsText.tag==1)   //sounds are on, will turn off.
           {

               [soundsText setString:@"sounds off"];
               [soundsText setColor:ccGRAY];

               soundsText.tag=0;

               [[GameSoundManager sharedManager].soundEngine  setMute:YES];

           }
           else             //sounds are off, will turn on.
           {

               [soundsText setString:@"sounds on"];
               [soundsText setColor:ccWHITE];

               soundsText.tag=1;

               [[GameSoundManager sharedManager].soundEngine  setMute:NO];

               if(![GameSoundManager sharedManager].soundEngine.isBackgroundMusicPlaying)
                   [[GameSoundManager sharedManager].soundEngine resumeBackgroundMusic];


           }


        }


        else if(  CGRectContainsPoint(backToMainTxt.boundingBox, touchPoint) )
        {
            //The player is taken back to the game's main menu.
            [[CCDirector sharedDirector] resume ];

            //stop sound.
            if(playerWalkSoundId != -1)
            {
                [[GameSoundManager sharedManager].soundEngine stopEffect:playerWalkSoundId ];
                playerWalkSoundId=-1;
            }

            [[CCDirector sharedDirector] replaceScene: [TitleScreen scene]];
        }

    }


}



-(void)goToPauseMenu
{
    isOnPauseMenu=TRUE;

    //Pausing the game's update methods.
    [[CCDirector sharedDirector] pause ];

    //Showing all the pause menu elements.
    grayBox.visible=YES;
    resumeText.visible=YES;
    soundsText.visible=YES;
    backToMainTxt.visible=YES;

}


-(void)backToGame
{
    //Unpausing the game's update methods.
    [[CCDirector sharedDirector] resume ];

    //2. Hide all the elements in the options menu 

        grayBox.visible=FALSE;

        resumeText.visible=FALSE;
        backToMainTxt.visible=FALSE;
        soundsText.visible=NO;

}


//Preparing the Targeted Touch Delegate
- (void) onEnterTransitionDidFinish
{

	[super onEnterTransitionDidFinish];
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:1 swallowsTouches:NO];

}

- (void) onExit
{
	[super onExit];

  //Stopping the music when exiting this scene.
    if(playerWalkSoundId != -1)
        [[GameSoundManager sharedManager].soundEngine stopEffect:playerWalkSoundId ];

    //[[GameSoundManager sharedManager].soundEngine stopBackgroundMusic ];
   //end of stopping music.

	[[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
}




//-------********------:DEALLOC
- (void) dealloc
{

//Deallocating objects in the gameScene when the scene is exited from.
//There are several things to deallocate here.

//Uncomment animation actions.
    [walkAction release];
    [standingAnimation release];

    [deathAnimation2 release];
    [deathAnimation1 release];

    [sparkAnimation release];




//Freeing my collision detection Arrays.
    if(numberOfCollisionRects>0)
        free(collisionRectsArray);


//If Teleports were created, free the C arrays.

    if(numberOfTeleports>0)
    {

        free(teleportRectsArray);
        free(teleportDestinationsArray);
        free(teleportPlayerNewLocationsArray);
        free(typeOfTeleportsArray);

        free(teleportersOffsetsArray);
    }


//if Moving Platforms were created,	free the C arrays.

    if(numberOfPlatforms>0)
        {
            free(platformInitialPosArray);
            free(platformFinalPosArray);
            free(platformVelocityArray);
            free(isPlatformPathHorizontalArray);
            free(isPlatformPathReversedArray);
        }

//Also free the arrays allocated for platforms data.

    if(numberOfFallingPlatforms>0)
        free(fallingPlatformsInitialYPosArray);

    [numberedPlatformsArray release];

	// don't forget to call "super dealloc"
	[super dealloc];
}



@end
