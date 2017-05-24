//
//  EndScene.h
//  WaveProject
//
//  Created by Game Developer on 11/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

//This class displays the animated ending sequence, 
    //after the player reaches the last level.

@interface EndScene : CCLayer {
    
    //Elements of the first scene are described below.
    CCNode* endSequence1;
        //Including different sprites for the child.
            //as well as a sky and tower sprite.
        CCSprite *Kid0, *Kid1, *Kid2andLight,  *Tower0, *Cielo0;
        CCSprite* whiteBackground;

    //Elements of the second scene.    
    CCNode* endSequence2;
        CCSprite *Cielo, *Montana, *Mar, *Arbol, *Tower, *Player;
        CCLabelBMFont *congrats, *mazeIsOver, *thankYou;
    
    //Text elements displayed in the credits screen.
    CCNode* creditsNode;
        CCLabelBMFont *Albith, *Pablo, *Josue, *backToMain;
        CCLabelBMFont *TheTeam, *Title1, *Title2, *Title3;
    
        BOOL isBackToMainShowing;
    
    //Saving the id for animations here.
       id playerWindAnim, treeBrushAnim;
    
}

//FYI, a + sign means the method is a class method.
    // a - sign means it's an instance method.

    +(id) loadEndSceneCreditsOnly:(BOOL)onlyShowCredits;
    -(id) initEndSceneCreditsOnly:(BOOL)onlyShowCredits;

    -(void)prepareEndNode1;
    -(void)runEndSequence1;

    -(void)prepareEndNode2;
    -(void)runEndSequence2;

    -(void)prepareCreditsNode;
    -(void)runCredits;

@end
