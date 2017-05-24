//
//  EndScene.m
//  Lucky Warp
//
//  Created by Albith Delgado on 11/14/11.
//  Copyright 2011 __Albith Delgado__. All rights reserved.
//

#import "EndScene.h"

#import "TitleScreen.h"
#import "GameSoundManager.h"

#define Cinematic_Ypos 400
#define Scroll_Time 40
#define Fade_Kid_Time 1.4

@implementation EndScene

//This method attaches our EndScene layer to the CCScene.
+(id) loadEndSceneCreditsOnly:(BOOL)onlyShowCredits;
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	EndScene *layer = [EndScene node];
    [layer initEndSceneCreditsOnly:onlyShowCredits];
  
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

#pragma mark onEnter and onExit

//Preparing the Targeted Touch Delegate
- (void) onEnterTransitionDidFinish
{
	//EDIT 3.31.2011 
	//Adding this works.
	[super onEnterTransitionDidFinish];    
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:1 swallowsTouches:NO];
}

- (void) onExit
{
	//EDIT 3.31.2011 
	//I add this and it works!!
	[super onExit];    
	[[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
}

#pragma mark Touch Events


- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    
    //We will process the touch event in the 'ccTouchEnded' function,
        //so we will accept ALL touch events for now.
    //This function doesn't do anything at the moment.

    NSLog(@"Touch detected.");  
	return YES;
    
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    
    //1. Let's get the touch's coordinates.
    
	CGPoint location= [touch locationInView: [touch view]];
	CGPoint touchPoint= [[CCDirector sharedDirector] convertToGL:location];
    
    if(isBackToMainShowing)
    {
        
        //Only checking if the player presses the 'back to Main' button.
        if (  CGRectContainsPoint([backToMain boundingBox], touchPoint) )
        {
             [[CCDirector sharedDirector] replaceScene:[TitleScreen scene]];     
        }
             
    }      
    
}


// On "init", we initialize your instance
-(id) initEndSceneCreditsOnly:(BOOL)onlyShowCredits;
{
	// Always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init] )) {
			
        self.isTouchEnabled=YES;
        isBackToMainShowing=FALSE;

		//1. Load all of the game's artwork up front.
		CCSpriteFrameCache* frameCache = [CCSpriteFrameCache sharedSpriteFrameCache];
		[frameCache addSpriteFramesWithFile:@"endSequence2.plist"];		
		
        
        [[CCDirector sharedDirector]setDisplayFPS:FALSE];
    
    //This EndScene class can also be called in the main menu, but -without-
        //the ending sequence (that is, only showing the credits).    
    if(!onlyShowCredits)    
    {    
     
    //Initializing our animated sequence elements.

    endSequence1=[CCNode node];
    [self addChild:endSequence1];
        [self prepareEndNode1];  
        
    
    endSequence2=[CCNode node];
    [self addChild:endSequence2];
        [self prepareEndNode2];   
        
    
    creditsNode=[CCNode node];
    [self addChild:creditsNode];    
        [self prepareCreditsNode];
        
    //preparing white Box.
        whiteBackground = [CCSprite node];
        [whiteBackground setTextureRect:CGRectMake(0, 0, 768, 400)];
        [whiteBackground setColor:ccWHITE];
        whiteBackground.anchorPoint=ccp(0,0);
        whiteBackground.opacity=0;
        
        whiteBackground.position=ccp(0, Cinematic_Ypos);
        
        [self addChild:whiteBackground z:1];    
        
        //After initializing and attaching all our scenes,
            //run the end sequence.  Note that all scenes are run simultaneously,
            //but with delays in between, 
                //so that the first scene can finish before the second one starts, and so on.
        [self runAction:[CCSequence actions:[CCCallFunc actionWithTarget:self selector:@selector(runEndSequence1)],
                                            [CCDelayTime actionWithDuration:12],
                                            [CCCallFunc actionWithTarget:self selector:@selector(runEndSequence2)],
                                            [CCDelayTime actionWithDuration:31],
                                            [CCCallFunc actionWithTarget:self selector:@selector(runCredits)],
                                            nil]];
        
	}
    
    else{
        
        //only showing the end credits. There are less variables to set up.
        
        creditsNode=[CCNode node];
            [self addChild:creditsNode];    
            [self prepareCreditsNode];
        
        creditsNode.visible=YES;
        
        //Run the credits sequence.
        [self runAction:[CCCallFunc actionWithTarget:self selector:@selector(runCredits)]];
        
        
        }
        
    
    
    }
	return self;
}

#pragma mark Preparing Nodes


-(void)prepareCreditsNode
{
    
    creditsNode.visible=NO;
    
 //Initializing the Title element.
    
    TheTeam= [CCLabelBMFont labelWithString:@"Who We Are" fntFile:@"credits_64Font.fnt"];
    TheTeam.scale= 1.3;
    TheTeam.position=ccp(384, 850);
    TheTeam.opacity=0;
    [creditsNode addChild:TheTeam];
    
    
    
    
//Initializing the Credit Names.
    
    Albith= [CCLabelBMFont labelWithString:@"Albith Delgado" fntFile:@"menu_64Font.fnt"];
    Albith.scale= 0.8;
    Albith.position=ccp(384, 610);
    Albith.opacity=0;
    [creditsNode addChild:Albith];
    
    Pablo= [CCLabelBMFont labelWithString:@"Pablo Pimentel" fntFile:@"menu_64Font.fnt"];
    Pablo.scale= 0.8;
    Pablo.position=ccp(384, 400);
    Pablo.opacity=0;
    [creditsNode addChild:Pablo];
    
    Josue= [CCLabelBMFont labelWithString:@"Josué González" fntFile:@"menu_64Font.fnt"];
    Josue.position=ccp(384, 200);
    Josue.scale= 0.8;
    Josue.opacity=0;
    [creditsNode addChild:Josue];    
    
    
//Initializing the Credit Titles.
    Title1= [CCLabelBMFont labelWithString:@"Designer and Coder" fntFile:@"credits_64Font.fnt"];
    //Title1.scale= 0.8;
    Title1.position=ccp(384, 690);
    Title1.opacity=0;
    [creditsNode addChild:Title1];
    
    Title2= [CCLabelBMFont labelWithString:@"Artist" fntFile:@"credits_64Font.fnt"];
    //Title2.scale= 0.8;
    Title2.position=ccp(384, 464);
    Title2.opacity=0;
    [creditsNode addChild:Title2];
    
    Title3= [CCLabelBMFont labelWithString:@"Composer" fntFile:@"credits_64Font.fnt"];
    Title3.position=ccp(384, 254);
    //Title3.scale= 0.8;
    Title3.opacity=0;
    [creditsNode addChild:Title3];   

    
//create back To Menu thing.
    backToMain= [CCLabelBMFont labelWithString:@"back to Main Menu" fntFile:@"menu_64Font.fnt"];
    backToMain.scale= 0.65;
    backToMain.opacity=0;
    [backToMain setContentSize:CGSizeMake(backToMain.contentSize.width*1.3f , backToMain.contentSize.height*1.3f )];
    backToMain.position=ccp(444, 50);
    [creditsNode addChild:backToMain];    
    
    
}

//The following methods set up the Scenes for the animated sequence.

-(void)prepareEndNode1{
    
    
    Cielo0=[CCSprite spriteWithSpriteFrameName:@"cielo0.png"];
    [endSequence1 addChild:Cielo0];
    
    Tower0=[CCSprite spriteWithSpriteFrameName:@"tower0.png"];
    [endSequence1 addChild:Tower0];
    
    Kid2andLight=[CCSprite spriteWithSpriteFrameName:@"kid2.png"]; 
    [endSequence1 addChild:Kid2andLight];
    
    Kid1=[CCSprite spriteWithSpriteFrameName:@"kid1.png"];
    [endSequence1 addChild:Kid1];
    
    Kid0=[CCSprite spriteWithSpriteFrameName:@"kid0.png"];
    [endSequence1 addChild:Kid0];
        
    //-------------
    
    //set anchor points used in the animations.
    Cielo0.anchorPoint=ccp(0,0);
    Tower0.anchorPoint=ccp(0,0);
    Kid0.anchorPoint=ccp(0,0);
    Kid1.anchorPoint=ccp(0,0);
    Kid2andLight.anchorPoint=ccp(0,0);
    
    
    //set positions
    Cielo0.position=ccp(525,Cinematic_Ypos);
    Tower0.position=ccp(-100,Cinematic_Ypos);
    
    Kid0.position=ccp(250,Cinematic_Ypos);
    Kid0.opacity=0;
    
    Kid1.position=ccp(330,Cinematic_Ypos);
    Kid1.opacity=0;
    
    Kid2andLight.position=ccp(-55,Cinematic_Ypos);
    Kid2andLight.opacity=0;
    
}

-(void)prepareEndNode2{
    
    //This second scene (after the first), is initially set to be invisible.
        //It will later be set to visible.
    endSequence2.visible=NO;
    
    //Create elements.
    Cielo=[CCSprite spriteWithSpriteFrameName:@"cielo.png"];
    [endSequence2 addChild:Cielo];
    
    Cielo.opacity=0;
    
    
    Montana=[CCSprite spriteWithSpriteFrameName:@"mountains.png"];
    [endSequence2 addChild:Montana];
    
    Montana.opacity=0;
    
    Mar=[CCSprite spriteWithSpriteFrameName:@"sea.png"];
    [endSequence2 addChild:Mar];
    
    Arbol=[CCSprite spriteWithSpriteFrameName:@"tree0.png"];
    [endSequence2 addChild:Arbol];
    
    Tower=[CCSprite spriteWithSpriteFrameName:@"tower.png"];
    [endSequence2 addChild:Tower];
    
    Player=[CCSprite spriteWithSpriteFrameName:@"player0.png"];
    [endSequence2 addChild:Player];
    
    
    //set anchor points
    Cielo.anchorPoint=ccp(0,0);
    Montana.anchorPoint=ccp(0,0);
    Mar.anchorPoint=ccp(0,0);
    Arbol.anchorPoint=ccp(0,0);
    Player.anchorPoint=ccp(0,0);
    Tower.anchorPoint=ccp(0,0);
    
    
    //set positions
    Cielo.position=ccp(0,Cinematic_Ypos+175);
    Montana.position=ccp(-200,Cinematic_Ypos+135);
    Mar.position=ccp(-200,Cinematic_Ypos);
    
    Tower.position=ccp(-150,Cinematic_Ypos);
    Player.position=ccp(500,Cinematic_Ypos+25);
    Arbol.position=ccp(750,Cinematic_Ypos);
    
    
    //create Animations.    
    
    NSMutableArray *tempFrames = [NSMutableArray array];
    
    //a. player Animation.
    
    for (int i =0 ; i < 2; i++) {
        
        CCSpriteFrame *frame;
        frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
                 [NSString stringWithFormat:@"player%d.png", i]];
        
        [tempFrames addObject:frame];
        
    }     
    
    id playerFrames = [CCAnimation animationWithFrames:tempFrames delay:0.24f] ;   
    playerWindAnim = [[CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:playerFrames restoreOriginalFrame:NO]] retain];
    
    
    //b. tree Animation
    
    [tempFrames removeAllObjects];
    
    for (int i =0 ; i < 2; i++) {
        
        CCSpriteFrame *frame;
        frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
                 [NSString stringWithFormat:@"tree%d.png", i]];
        
        [tempFrames addObject:frame];     
    }     
    
    id treeFrames = [CCAnimation animationWithFrames:tempFrames delay:0.24f] ;   
    treeBrushAnim = [[CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:treeFrames restoreOriginalFrame:NO]] retain];
    
    //--end of animations setup.    
    
    //Creating Text Boxes.
        congrats= [CCLabelBMFont labelWithString:@"CONGRATULATIONS!" fntFile:@"menu_64Font.fnt"];
        congrats.scale= 0.8;
        congrats.position=ccp(384, 900);
        congrats.opacity=0;
        [endSequence2 addChild:congrats];
        
        mazeIsOver= [CCLabelBMFont labelWithString:@"You are out of the maze." fntFile:@"menu_64Font.fnt"];
        mazeIsOver.scale= 0.8;
        mazeIsOver.position=ccp(384, 320);
        mazeIsOver.opacity=0;
        [endSequence2 addChild:mazeIsOver];
        
        thankYou= [CCLabelBMFont labelWithString:@"THANK YOU FOR PLAYING!" fntFile:@"menu_64Font.fnt"];
        thankYou.position=ccp(384, 200);
        thankYou.scale= 0.9;
        thankYou.opacity=0;
        [endSequence2 addChild:thankYou];
    
    //NSLog(@"finished declaring stuff."); 
     
}

#pragma mark Running End Sequences


//These functions run the sequences.
-(void) runCredits
{  
    [[GameSoundManager sharedManager].soundEngine  stopBackgroundMusic];	
    [[GameSoundManager sharedManager].soundEngine  playBackgroundMusic:@"creditsBeat.mp3"];	

    //Setting up our fade and delay actions.
    id fadeInAction= [CCFadeIn actionWithDuration:1.5f];
    id delay= [CCDelayTime actionWithDuration:1.7f];   
    
    //Fade in Albith and Title1.
    id fadeInAlbith= [CCCallBlock actionWithBlock:
                      ^{
                          [Title1 runAction:[[fadeInAction copy] autorelease] ];
                          [Albith runAction:[[fadeInAction copy] autorelease] ];
                          
                      }];    
    
    
    //Fade in Pablo and Title2.
    id fadeInPablo= [CCCallBlock actionWithBlock:
                     ^{
                         [Title2 runAction:[[fadeInAction copy] autorelease] ];
                         [Pablo runAction:[[fadeInAction copy] autorelease] ];
                         
                     }];
    
    //Fade in Josue and Title3.
    id fadeInJosue= [CCCallBlock actionWithBlock:
                     ^{
                         [Title3 runAction:[[fadeInAction copy] autorelease] ];
                         [Josue runAction:[[fadeInAction copy] autorelease] ];
                         
                     }];
    
 
    
    id showBackToMain= [CCCallBlock actionWithBlock:
                  ^{
                      
                      [backToMain runAction:[CCRepeatForever actionWithAction:[CCSequence actions:[CCFadeIn actionWithDuration:0.4f],
                                                                                                    [CCFadeOut actionWithDuration:0.4f],
                                                                                                    nil]]  ];
                      //[[CCDirector sharedDirector] replaceScene:[TitleScreen scene]];
                      
                  }];
    
    id turnOnTouches= [CCCallBlock actionWithBlock:
                        ^{
                            
                            isBackToMainShowing=YES;
                            
                        }];
    
    
    //Run everything.
    [TheTeam runAction:[CCSequence actions:fadeInAction,
                                           delay,
                                           fadeInAlbith,
                                           [CCDelayTime actionWithDuration:1.9f],
                                           fadeInPablo, 
                                           [[delay copy] autorelease],
                                           fadeInJosue, 
                                           [CCDelayTime actionWithDuration:4],
                                           turnOnTouches,
                                           showBackToMain,
                                           nil]  ];
    
    
}



-(void) runEndSequence1
{
    
    id fadeIn, fadeOut, hideEndNode1;
    
    fadeIn= [CCFadeIn actionWithDuration:Fade_Kid_Time];
    //Alternate: fadeIn_long= [CCFadeIn actionWithDuration:Fade_Kid_Time*1.5f];
    
    fadeOut= [CCFadeOut actionWithDuration:Fade_Kid_Time*0.7f];
    //fadeOut_long= [CCFadeOut actionWithDuration:Fade_Kid_Time*1.5f];
    
    hideEndNode1= [CCCallBlock actionWithBlock:
                           ^{
                               endSequence1.visible=NO;
                           }];
    
    id fadeInWhite= [CCCallBlock actionWithBlock:
                      ^{
                          
                          [whiteBackground runAction:[CCFadeIn actionWithDuration:1.1f]];
                          
                      }];
    

    id fadeInKid1= [CCCallBlock actionWithBlock:
                    ^{
                        //NSLog(@"running Kid1.");             
                    [Kid1 runAction:[[fadeIn copy] autorelease] ];
                               
                    }];
    
    id fadeOutKid1= [CCCallBlock actionWithBlock:
                     ^{
                        // NSLog(@"running Kid1.");
                         [Kid1 runAction:[[fadeOut copy]autorelease]];                   
                     }];

    
    id fadeInKid2= [CCCallBlock actionWithBlock:
                    ^{
                        //NSLog(@"running Kid2.");                
                    [Kid2andLight runAction:[CCFadeIn actionWithDuration:1.6f]];
                    
                    }];
    
    
    
    //Finally, run all the actions.
    [Kid0 runAction:[CCSequence actions: fadeIn, [CCDelayTime actionWithDuration:0.7f], fadeOut, 
                                         fadeInKid1,[CCDelayTime actionWithDuration:1.9f] , fadeOutKid1,
                     
                                            [CCDelayTime actionWithDuration:1],
                     
                                         fadeInKid2, [CCDelayTime actionWithDuration:2.5f], 
    
                                            fadeInWhite, [CCDelayTime actionWithDuration:1.5f],
                     
                                         hideEndNode1, nil]];
    
}

-(void)runEndSequence2
{
    //This sequence is a slow left to right transition,
        //showing the player and the scenery.
    id cieloScroll, montanaScroll, marScroll, arbolScroll, playerScroll, towerScroll;
    
    cieloScroll= [CCMoveBy actionWithDuration:Scroll_Time position:ccp(-25,0)];
    
    montanaScroll= [CCMoveBy actionWithDuration:Scroll_Time position:ccp(50,0)];
    
    marScroll= [CCMoveBy actionWithDuration:Scroll_Time position:ccp(100,0)];

    arbolScroll= [CCMoveBy actionWithDuration:Scroll_Time position:ccp(-200,0)];

    towerScroll= [CCMoveBy actionWithDuration:Scroll_Time position:ccp(-150,0)];
    playerScroll= [CCMoveBy actionWithDuration:Scroll_Time position:ccp(-150,0)];

    id fadeInAction= [CCFadeIn actionWithDuration:8];

   // NSLog(@"created scroll actions, now to run them.");

    
    //Running Animations.    
    [Player runAction:playerWindAnim];
    [Arbol runAction:treeBrushAnim];
    
    //Running Scrolling Actions
    [Cielo runAction:cieloScroll];
    [Montana runAction:montanaScroll];
    [Mar runAction:marScroll];
    
    [Arbol runAction:arbolScroll];
    [Tower runAction:towerScroll];
    [Player runAction:playerScroll];


    //running FadeIn Actions
    [Cielo runAction:fadeInAction];
    [Montana runAction:[[fadeInAction copy] autorelease]];
    
    //NSLog(@"now about to show letters.");

    //Showing a message.    
    
    id delayAction1, delayAction2, delayAction3;
    
    delayAction1=[CCDelayTime actionWithDuration:6];
    delayAction2=[CCDelayTime actionWithDuration:8];
    delayAction3=[CCDelayTime actionWithDuration:10];

    
    id fadeInTextAction= [CCFadeIn actionWithDuration:0.5f];
    
    id fadeOutWhite= [CCCallBlock actionWithBlock:
                   ^{
                       [whiteBackground runAction:[CCFadeOut actionWithDuration:3]];
                       
                   }];	
    
    id showNode2= [CCCallBlock actionWithBlock:
                           ^{
                               endSequence2.visible=YES;
                               
                           }];	
    
    id fadeInTextAction2= [CCCallBlock actionWithBlock:
     ^{
         
         [mazeIsOver runAction:[[fadeInTextAction copy]autorelease] ];
         
     }];	
    
    id fadeInTextAction3= [CCCallBlock actionWithBlock:
                           ^{
                               
                               [thankYou runAction:[[fadeInTextAction copy]autorelease] ];
                               
                           }];
    
    id hideEndNode2= [CCCallBlock actionWithBlock:
                           ^{
                               
                               endSequence2.visible=NO;
                               creditsNode.visible=YES;
                               
                           }];
    
    [congrats runAction:[CCSequence actions:fadeOutWhite, showNode2, delayAction3, fadeInTextAction, [[delayAction1 copy] autorelease], 
                         fadeInTextAction2, [[delayAction1 copy] autorelease], fadeInTextAction3,
                         delayAction2, hideEndNode2,  nil]];
    
    
    
}


//The objective C class's deallocation method.

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
    //Here, I'm deallocating the 2 animations that are set to 'repeat forever'.
    [playerWindAnim release];
    [treeBrushAnim release];
    
	// don't forget to call "super dealloc"
	[super dealloc];
}
@end
