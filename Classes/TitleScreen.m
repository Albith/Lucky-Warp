//
//  TitleScreen.m
//  WaveProject
//
//  Created by Game Developer on 9/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TitleScreen.h"
#import "GameScene.h"
#import "EndScene.h"

//For sounds
#import "SimpleAudioEngine.h"
#import "GameSoundManager.h"

#import "GameConstants.h"

@implementation TitleScreen
@synthesize allLevelsUnlocked;

+(id) scene
{
	// 'Scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'Layer' is an autorelease object.
	TitleScreen *layer = [TitleScreen node];
	
	// Add layer as a child to scene
	[scene addChild: layer];
	
	// Return the scene
	return scene;
}

- (void) onEnterTransitionDidFinish
{
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:1 swallowsTouches:YES];
}


// on "init" we initialize our class.
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init] )) {
        
        [[CCDirector sharedDirector] setDisplayFPS:NO];
        
		//First, enabling touches
		self.isTouchEnabled = YES;
		
		//Load all of the game's artwork up front.
		CCSpriteFrameCache* frameCache = [CCSpriteFrameCache sharedSpriteFrameCache];
		[frameCache addSpriteFramesWithFile:@"playerSprites.plist"];		
		
        isInStageSelect=FALSE;
        
        //Turning on Sounds.
        if  ([GameSoundManager sharedManager].soundEngine.isBackgroundMusicPlaying )	
            [[GameSoundManager sharedManager].soundEngine  stopBackgroundMusic];	
        
        if(![GameSoundManager sharedManager].soundEngine.mute)
            areSoundsOn=TRUE;
        else
            areSoundsOn=FALSE;
              
//0.Checking for saved data
        [self getCurrentLevel];
		
        
//1.Preparing our Title Screen Node.
        [self prepareTitleScreenNode];
		     
//2.Preparing our Stage Select Node.
        [self prepareStageSelectNode];        
        [self enlargeNodeContentSize];

        
//3.Setting the titleSplash bouncing effect and running it.
		//The title screen scrolls into view, disappears for a third of a second,
		//then comes back with a halo that encircles '1p start' and '2p start' blinking.
		
		id oldSchoolScroll= [CCEaseOut actionWithAction: 
                             
                             [CCMoveBy actionWithDuration:0.5f position:ccp(0,-503)]
                             
                                                   rate:1.2f];
		
        id jumpAction=[CCJumpBy actionWithDuration:0.5f position:ccp(0,0) height:140 jumps:1];
        
		
		
		id blinkTitleScreen	= [CCBlink actionWithDuration:0.05f blinks:1];																	
        
		id showTitleScreen= [CCShow action];
		
		id callGameModes=[CCCallBlock actionWithBlock:
                          ^{
                              gameStartTxt.visible=YES;								
                              optionsModeTxt.visible=YES;
                          
                                  continueTxt.visible=YES;
                                    creditsTxt.visible=YES;
                                
                                companyLogo.visible=YES;
                          
                          }];
		
		id blinkGameSelector=[CCCallBlock actionWithBlock:
                              ^{
                                  
                                  id blinkAction= [CCBlink actionWithDuration:30 blinks:140];
                                  [blinkAction setTag:GAME_MODE_TAG];
                                  
                                  [gameModeSelector runAction:blinkAction];
                                  
                              }];		
		
		
		[titleSplash runAction:
         [CCSequence actions: oldSchoolScroll, jumpAction, blinkTitleScreen, showTitleScreen, callGameModes, blinkGameSelector, nil] ];
		
        
        
        
	}
	return self;
}

//This function merely enlarges the size of some sprites in the titleScreen.
-(void)enlargeNodeContentSize
{

    //loop through all touchable elements in both nodes, and increase their content size by 10%
    
    [gameStartTxt setContentSize:CGSizeMake(gameStartTxt.contentSize.width*1.3f, gameStartTxt.contentSize.height*1.3f)]; 
    [optionsModeTxt setContentSize:CGSizeMake(optionsModeTxt.contentSize.width*1.3f, optionsModeTxt.contentSize.height*1.3f)];
    
    [continueTxt setContentSize:CGSizeMake(continueTxt.contentSize.width*1.3f, continueTxt.contentSize.height*1.3f)];
    [backToMainTxt setContentSize:CGSizeMake(backToMainTxt.contentSize.width*1.3f, backToMainTxt.contentSize.height*1.3f)];

    [creditsTxt setContentSize:CGSizeMake(creditsTxt.contentSize.width*1.3f, creditsTxt.contentSize.height*1.3f)];

    
    //Looping through all the stage numbers in the stage select.
    for(int count=0; count< [[stageNumbers children] count]; count++)
    {
        
        CCSprite* numberSprite= (CCSprite*)[stageNumbers getChildByTag:count];
        
        //Enlarging sprite contentSize by 30 percent.
        
        [numberSprite setContentSize:CGSizeMake(numberSprite.contentSize.width*2, numberSprite.contentSize.height*2)];
        
        //NSLog(@"bounding box of numberSprite %d is %@.",count, NSStringFromCGRect(numberSprite.boundingBox));    
    
    }
    
}


-(void)toGameStart{
    
	[[CCDirector sharedDirector] replaceScene:[GameScene sceneWithLevel:0]];
	
}

-(void)toStageSelect{
    
    //Lowering opacity for all sprites in titleScreenNode.
        //Because CCNode has no opacity information!
    
//1.Creating our Fade In and Fade Out actions.
    id fadeInAction= [CCFadeIn actionWithDuration:0.3f ];
    

//2.Fading out the Title Screen Node.    
    for(CCLabelBMFont *tempTxt in [titleScreenNode children])
        tempTxt.opacity=100;  //opacity set to less than half.  Max opacity is 255.
     
    companyLogo.opacity=0;

//3.Fading IN the Stage Select Node
    
    [chooseAStageTxt runAction:fadeInAction]; 
    [backToMainTxt runAction:[[fadeInAction copy] autorelease]];
    
    if(allLevelsUnlocked)   //if the game has been cleared, render all the numbers  with 100% opacity.
        [stageNumbers runAction:[[fadeInAction copy] autorelease]];
    
    else  
    {
        
        //if we're not in Debug Mode, show only up to the current Level at 100% opacity; 
        //the rest of the levels (unbeaten levels) are shown at 50%
        
        //Show the numbers for the cleared levels at 100% opacity
        for(int index=0; index < howManyNumberSpritesToShow; index++)
        {
            
            CCSprite * tempSprite= (CCSprite*)[stageNumbers getChildByTag:index];
            [tempSprite runAction:[[fadeInAction copy] autorelease] ];
            
        }
        
        //Show the numbers for unexplored levels at 50% opacity
        for(int index=howManyNumberSpritesToShow; index < [[stageNumbers children] count]; index++)
        {
            
            CCSprite * tempSprite= (CCSprite*)[stageNumbers getChildByTag:index];
            tempSprite.opacity= 128;
            
        }
        
    
        
        
    }
    
    //After rendering the stage select, set the game logic flag.
    isInStageSelect=TRUE;
    
}

-(void)toCredits{
    
    //This function takes the player to the credits screen directly from the titleScreen.
	[[CCDirector sharedDirector] replaceScene:[EndScene loadEndSceneCreditsOnly:TRUE]];
	
}


//This function takes the user from the stage select back to the title screen.
-(void)backToTitleScreen{
    
    
    //2.Fading out the Stage Select Node.    
    for(CCLabelBMFont *stageSelTxt in [stageSelectNode children])
        stageSelTxt.opacity=0;  //opacity set to less than half.  Max opacity is 255.
    
    
    //3.Fading in the Title Screen Node
    for(CCLabelBMFont *titleScreenTxt in [titleScreenNode children])
        [titleScreenTxt setOpacity:255];
    
        
    //Running the blinking cursor action again.
        [gameModeSelector runAction:[CCBlink actionWithDuration:15 blinks:70]];    
        isInStageSelect=FALSE; 
}


-(void)prepareTitleScreenNode
{
    
//1. Creating our Title Screen Node and attaching all the UI elements to it.
    titleScreenNode= [CCNode node];
    [self addChild:titleScreenNode];
      
    //Adding a title screen and a 'bouncing into view' action.
    //Just like old platform games!
    
    titleSplash=[CCSprite spriteWithFile:@"titleScreen.png"];
    [titleSplash setAnchorPoint:ccp(0,0)];
    titleSplash.position=ccp(55, 1024);     //Later title drops down to 171.
    [titleScreenNode addChild:titleSplash];
    
    
    //The Game Mode Text, plus the Game Mode Selector, are not visible at the beginning.
    
    
    //Game Start
    //gameStartSprite=[CCSprite spriteWithFile:@"gameStart.png"];
    gameStartTxt=[CCLabelBMFont labelWithString:@"Game Start" fntFile:@"menu_64Font.fnt"];
    
    [gameStartTxt setAnchorPoint:ccp(0,0)];
    
    gameStartTxt.position=ccp(240,324);
    [titleScreenNode addChild:gameStartTxt];
    gameStartTxt.visible=NO;
    
    
    
//Checking for Saved Data so we can show the Continue option.            
    //Continue
    continueTxt=[CCLabelBMFont labelWithString:@"Continue" fntFile:@"menu_64Font.fnt"];
    
    [continueTxt setAnchorPoint:ccp(0,0)];
    
    continueTxt.position=ccp(276,246);
    [titleScreenNode addChild:continueTxt];
    continueTxt.visible=NO;
    
    //Options
    optionsModeTxt=[CCLabelBMFont labelWithString:@"sounds on" fntFile:@"menu_64Font.fnt"];
    [optionsModeTxt setAnchorPoint:ccp(0,0)];
    optionsModeTxt.scale=0.7;
    
    if(!areSoundsOn)
    {
        
        [optionsModeTxt setString:@"sounds off"];
        [optionsModeTxt setColor:ccGRAY];
        
    }
    
    
    optionsModeTxt.position=ccp(300,198);
    [titleScreenNode addChild:optionsModeTxt];
    optionsModeTxt.visible=NO;
    
    
    //Game Credits
    creditsTxt=[CCLabelBMFont labelWithString:@"credits" fntFile:@"menu_64Font.fnt"];
    creditsTxt.scale=0.8;
    [creditsTxt setColor:ccYELLOW];
    
    creditsTxt.visible=NO;
    
    creditsTxt.position=ccp(418,180);
    [titleScreenNode addChild:creditsTxt];
    
    
    
//Adding the GameModeSelector and the company logo.        
    
    //gameModeSelector
    gameModeSelector=[CCSprite spriteWithFile:@"gameModeSelector.png"];
    gameModeSelector.scale=0.95;
    
    gameModeSelector.position=ccp(400,265);
    [titleScreenNode addChild:gameModeSelector];
    gameModeSelector.visible=NO;
    
    
    //Company Logo
    companyLogo=[CCLabelBMFont labelWithString:@"©2011 Albith Delgado" fntFile:@"menu_64Font.fnt"];
    companyLogo.scale=0.75;
    companyLogo.visible=NO;
    
    companyLogo.position=ccp(384,50);
    [titleScreenNode addChild:companyLogo];
    

}


-(void)prepareStageSelectNode
{
    

//1.Create Stage Select Node.    
    stageSelectNode= [CCNode node]; 
    [self addChild:stageSelectNode];
      
//2a.Set the Stage Select title.     
    chooseAStageTxt= [CCLabelBMFont labelWithString:@"Choose a Stage!" fntFile:@"menu_64Font.fnt"];
    [chooseAStageTxt setScale:1.5f];
    
    chooseAStageTxt.anchorPoint=ccp(0,0);
    chooseAStageTxt.position=ccp(44, 905);
    chooseAStageTxt.opacity=0;
    
    
    [stageSelectNode addChild:chooseAStageTxt];

    
//2b.Set the 'back to Main' text.     
    backToMainTxt= [CCLabelBMFont labelWithString:@"back to Main Menu" fntFile:@"menu_64Font.fnt"];
    [backToMainTxt setScale:0.9f];
    
    backToMainTxt.anchorPoint=ccp(0,0);
    backToMainTxt.position=ccp(154, 55);
    backToMainTxt.opacity=0;
    
    [stageSelectNode addChild:backToMainTxt];
    
    
//2c.Create CCLabelBMFont objects for all the Stage Numbers.
    
    NSMutableString* tempString= [NSMutableString string];
    
    //Number objects will be created only up to the current level of play.
    for(int stageNumber=1; stageNumber<=NUMBER_OF_LEVELS; stageNumber++) 
        {
        
            [tempString appendString:[NSString stringWithFormat:@"%d", stageNumber]];
        
        }
    
    stageNumbers= [CCLabelBMFont labelWithString:tempString fntFile:@"stageSelectFont.fnt"];
    
    stageNumbers.anchorPoint=ccp(0,0);
    stageNumbers.position=ccp(0,0);
    stageNumbers.opacity=0;
    
    [stageSelectNode addChild:stageNumbers];
    //Note: the title has a 30 pixel border on the sides and a 58 pixel border from the top.   
    
//3.Formatting the Numbers in the CCLabelBMFont.
    
    //numbers have an 84 pixel border on the sides
    //a 95 pixel horizontal gap,
    //and a 100 pixel vertical gap, between each other.
    
    //This is the point on the screen from where stage numbers will begin to appear.
    CGPoint startPoint=ccp(134, 796); 
    
    int spriteCount = 0; 
    CGPoint currentPoint;
    
    while (spriteCount<[[stageNumbers children] count])
        {
            //Displaying numbers for levels 0-9.
            if(spriteCount < 9)
            {
                
                currentPoint=ccp( startPoint.x + (numberMaxWidth + stageNumberSpacingX)*(spriteCount%stagesPerRow ) , 
                                 
                                 startPoint.y - (numberHeight + stageNumberSpacingY)*(int)((spriteCount-spriteCount % stagesPerRow)/stagesPerRow)
                                 
                                 );
                
                CCSprite * tempSprite= (CCSprite*)[stageNumbers getChildByTag:spriteCount];
                
                tempSprite.anchorPoint=ccp(0,0);
                tempSprite.position= currentPoint;
                
                spriteCount++;
                
            }
            
            //Displaying numbers for levels 10 and over.
            else
            {
                
                currentPoint=ccp( startPoint.x + (numberMaxWidth + stageNumberSpacingX)*(((spriteCount-1)%(stagesPerRow*2))/2) , 
                                 
                                  startPoint.y - (numberHeight + stageNumberSpacingY)*(int)((spriteCount-spriteCount % (stagesPerRow*2))/(stagesPerRow*2) +1)
                                 
                                 );
                
                
                CCSprite * tempSpriteA= (CCSprite*)[stageNumbers getChildByTag:spriteCount];
                CCSprite * tempSpriteB= (CCSprite*)[stageNumbers getChildByTag:(spriteCount+1)];
                
                //These numbers should stick together.
                
                tempSpriteA.anchorPoint=ccp(0,0);
                tempSpriteB.anchorPoint=ccp(0,0);

                //tuning opacity
                //[tempSpriteA setOpacity:0];
                //[tempSpriteB setOpacity:0];
                
                tempSpriteA.position= ccp(currentPoint.x-numberMaxWidth, currentPoint.y);
                tempSpriteB.position= currentPoint;

                
                spriteCount+=2;
                
            }
            
            
        } //end of the while loop that renders the level number sprites.

}


//Toggle the sounds in the game on or off.
-(void)toggleSound{
	
    if(areSoundsOn)
    {
        
    [[GameSoundManager sharedManager].soundEngine  setMute:YES];	
        [optionsModeTxt setString:@"sounds off"];
        [optionsModeTxt setColor:ccGRAY];
        
        areSoundsOn=FALSE;
        
    }

    else
    {
        
    [[GameSoundManager sharedManager].soundEngine  setMute:NO];	
        [optionsModeTxt setString:@"sounds on"];
        [optionsModeTxt setColor:ccWHITE];

        
        areSoundsOn=TRUE;
        
        [[GameSoundManager sharedManager].soundEngine  playEffect:@"warpGetKey.aif"];	

        
    }

}

//Processing the user's touches.

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    
    //We will process the touch event in the 'ccTouchEnded' function,
        //so we will accept all touch events in this function.
    
	return YES;
    
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    //1. First, fetch the touch's coordinates.
    
	CGPoint location= [touch locationInView: [touch view]];
	CGPoint touchPoint= [[CCDirector sharedDirector] convertToGL:location];
    
    //2. Next, fetch the CGRect for the button's dimensions.
    //   Then we'll check if the touchPoint is indeed inside the button's location.
    //   If it's not inside the button's range, then don't do anything.
    
    //NOTE: Must fix the CGRects to 1pGame area and 2pGame area, respectively.
    
    //NSLog(@"Touch Registered.");
    
    //Processing touches made while in the Title Screen.
    if(!isInStageSelect)
    {	
            if (  CGRectContainsPoint([gameStartTxt boundingBox], touchPoint) )
            {
                //NSLog(@"1p Game will start.");
                [[GameSoundManager sharedManager].soundEngine  playEffect:@"enterTheMaze.aif"];	
                [gameModeSelector stopActionByTag:GAME_MODE_TAG];
        
                id goToGame=[CCCallBlock actionWithBlock:
                             ^{
                                 [self toGameStart];
                             }];		
        
                [gameStartTxt runAction:[CCSequence actions:
                                            [CCBlink actionWithDuration:1.7f blinks:10],
                                            goToGame, nil]];	
        
                
            }
    
            //Going to the Stage Select Mode.
            else if (  CGRectContainsPoint([continueTxt boundingBox], touchPoint) )
            {
 
                [gameModeSelector stopActionByTag:GAME_MODE_TAG];
                [continueTxt runAction:[CCCallFunc actionWithTarget:self selector:@selector(toStageSelect)]];	
        
        
            }
 
            //Going to the Options Mode.
            else if (  CGRectContainsPoint([optionsModeTxt boundingBox], touchPoint) )
            {
         
                //[gameModeSelector stopActionByTag:GAME_MODE_TAG];
                [optionsModeTxt runAction:[CCCallFunc actionWithTarget:self selector:@selector(toggleSound)]];	
                   
            }
            
            //Going to the game credits.
            else if (  CGRectContainsPoint([creditsTxt boundingBox], touchPoint) )
            {
                
                //[gameModeSelector stopActionByTag:GAME_MODE_TAG];
                [creditsTxt runAction:[CCCallFunc actionWithTarget:self selector:@selector(toCredits)]];	
                                
            }
        
        
        
    }    
  
    else
    {
        //Checking for touches inside the Stage Select.
        
        if (  CGRectContainsPoint([backToMainTxt boundingBox], touchPoint) )
            [self backToTitleScreen];
        
        [self checkForStageSelectedWithPoint:touchPoint];
        
    }
    
    
}

-(void)checkForStageSelectedWithPoint:(CGPoint)touchPoint
{
    
    int numberCount = 0; 
    int levelToGoTo= 1;
    
    int howManyStagesToCheck;
    
    if(allLevelsUnlocked)   //check for all stages if this flag is on.
        howManyStagesToCheck= [[stageNumbers children] count];
    else
        howManyStagesToCheck= howManyNumberSpritesToShow;

    while (numberCount< howManyStagesToCheck )
    {
           
        if(numberCount < 9)
        {
            
            CGRect numberRect= [stageNumbers getChildByTag:numberCount].boundingBox;
            
            if(CGRectContainsPoint(numberRect, touchPoint) )
               {
                   //NSLog(@"Touched numberSprite #%d", numberCount);
                   
                   [[CCDirector sharedDirector] replaceScene:[GameScene sceneWithLevel:levelToGoTo]];
                   //Play a warp sound effect.
                   [[GameSoundManager sharedManager].soundEngine  playEffect:@"warpGameStartSelect.aif"];	
                   
                   break;
                   
               }
            
            else
            {
                numberCount++;
                levelToGoTo++;
            }
                
        }
        
        else 
        {
            
            CGRect numberRectA= [stageNumbers getChildByTag:numberCount].boundingBox;
            CGRect numberRectB= [stageNumbers getChildByTag:(numberCount+1)].boundingBox;

            //Checking if the player has touched any of the number's rects for levels 10 and over.
            if ( (CGRectContainsPoint(numberRectA, touchPoint) ) || (CGRectContainsPoint(numberRectB, touchPoint) )    )
            {
                
                NSLog(@"Touched numberSprite(s) #%d", numberCount);

                [[CCDirector sharedDirector] replaceScene:[GameScene sceneWithLevel:levelToGoTo]];
                //Play a sound effect.
                [[GameSoundManager sharedManager].soundEngine  playEffect:@"warpGameStartSelect.aif"];	

                break;
                
            }
            
            
            else
            {
                numberCount+=2;
                levelToGoTo++;
            }    
        }
                  
        
    } //End of the stage select touch processing loop.
    
 
}




-(void)getCurrentLevel{
    
    //This method fetches the currentLevel, a variable 
        //which is stored in the NSUserDefaults (similar to the browser's cookies.)
    NSUserDefaults *playerDefaults=[NSUserDefaults standardUserDefaults]; 
    currentLevel = [playerDefaults integerForKey:@"currentLevel"];
        
        if(currentLevel>NUMBER_OF_LEVELS)
            currentLevel=NUMBER_OF_LEVELS;
    
        if(currentLevel==0)
            currentLevel=1;
    
        //NSLog(@"currentLevel is %d", currentLevel);
    
    //2.Setting the value of the allLevelsUnlocked flag.
            if (currentLevel== NUMBER_OF_LEVELS) {
        
                allLevelsUnlocked=TRUE;
            }
            else
                allLevelsUnlocked=FALSE;
    
    //3.Setting the value of number of Stages to show only the cleared levels as highlighted.                
    
            if(currentLevel < 10)
                howManyNumberSpritesToShow=currentLevel;
            else  //each level after 10 is composed of 2 sprites, hence why we multiply by 2.
                howManyNumberSpritesToShow= 2*currentLevel  - 9;
                
}


// On "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	 [[CCDirector sharedDirector] purgeCachedData];
    
	// don't forget to call "super dealloc"
	[super dealloc];
}


@end
