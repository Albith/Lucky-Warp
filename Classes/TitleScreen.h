//
//  TitleScreen.h
//  WaveProject
//
//  Created by Game Developer on 9/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

//This is the header file for the TitleScreen class.

@interface TitleScreen : CCLayer {
    
//The title screen node.  
    CCNode* titleScreenNode;
        //CGRect gameStartRect, optionsModeRect, continueRect;
        CCSprite *titleSplash,  *gameModeSelector;
        CCLabelBMFont *gameStartTxt, *optionsModeTxt, *continueTxt, *creditsTxt, *companyLogo;
	
//Stage Select Scenes and elements
        CCNode* stageSelectNode;
        CCLabelBMFont *chooseAStageTxt, *stageNumbers, *backToMainTxt;
 
//Save state variables
    int currentLevel;
    int howManyNumberSpritesToShow;
    
//Status of Sounds
    BOOL areSoundsOn;
      
//Are you in Stage Select or the Title Screen?    
    BOOL isInStageSelect;
}

@property (nonatomic, assign) BOOL allLevelsUnlocked;

// returns a Scene that contains the TitleScreen as the only child
+(id) scene;

//Menu Options
    -(void)toGameStart;
    -(void)toStageSelect;
    -(void)toCredits;

    -(void)backToTitleScreen;
    -(void)toggleSound;

    -(void)prepareTitleScreenNode;
    -(void)prepareStageSelectNode;

//Enlarge the Stage Select Numer's Content Size
    -(void)enlargeNodeContentSize;

//Checking input inside the Stage Select screen:
    -(void)checkForStageSelectedWithPoint:(CGPoint)touchPoint;

-(void)getCurrentLevel;


@end
