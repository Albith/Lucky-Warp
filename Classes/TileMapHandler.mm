//
//  TileMapHandler.mm
//  WaveProject
//
//  Created by Albith Delgado on 11. 7. 12..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TileMapHandler.h"
#import "GameScene.h"

#import "GameConstants.h"

#define PTM_RATIO 32

@implementation TileMapHandler

@synthesize tileMap;
@synthesize gameSceneInstance;


+(id) initTileMap:(GameScene*)sceneInstance
{
	return [[[self alloc] init:sceneInstance] autorelease];
}


- (id) init:(GameScene *)sceneInstance
{
		
	if( (self=[super init]) )
	{

//First, we get a copy of the gameScene object:
    self.gameSceneInstance=sceneInstance;

//Then, we load the tileMap

    tileMap = [CCTMXTiledMap tiledMapWithTMXFile:
                  [NSString stringWithFormat:@"nivel%d.tmx", self.gameSceneInstance.currentLevel]];
    //Loading a test level, sample code:
        //tileMap = [CCTMXTiledMap tiledMapWithTMXFile:@"level1.tmx"];    
                
    //Placing the tileMap onto the scene tree.            
    tileMap.anchorPoint = ccp(0, 0);
	[self.gameSceneInstance.gameLayer addChild:tileMap z:-1];
	
	}
	
	return self;

}


- (void) drawBodyTiles {
	
    //Tile properties.
    int x ;
	int y ;
	//int w ;
	//int h ;
    

    
//-----------1. Loading and preparing TMX Collision Spaces.  
    //This is done by fetching the 'collisions' object group in the file,
        //then taking that data and creating rectangles from it.    
    CCTMXObjectGroup *collisionObjects = [tileMap objectGroupNamed:@"Collisions"];	
    [[GameScene sharedGameScene] createCollisionRectsWithArray:[collisionObjects objects]];    
    
//-----------2. Loading and preparing Moving and Falling Platforms    
    
    CCTMXObjectGroup *platformObjects = [tileMap objectGroupNamed:@"Platforms"];
    CCTMXObjectGroup *fallingPlatformObjects = [tileMap objectGroupNamed:@"FPlatforms"];
    
    CCTMXObjectGroup *platformBObjects = [tileMap objectGroupNamed:@"PlatformsB"];

    int numberOfPlatforms= [[platformObjects objects] count];
    int numberOfFallingPlatforms= [[fallingPlatformObjects objects] count];
    
    int numberOfPlatformBs= [[platformBObjects objects] count];
    
    //Initializing our Sprite Batch Node.
    
    //Adding platforms if the level data specifies them.
        if( (numberOfPlatforms>0) || (numberOfFallingPlatforms>0) )
            [[GameScene sharedGameScene] initMovingPlatforms:numberOfPlatforms
                                        andFallingPlatforms:(int)numberOfFallingPlatforms
                                        andDoBPlatformsExist:FALSE];

        else if (numberOfPlatformBs > 0)
            [[GameScene sharedGameScene] initMovingPlatforms:numberOfPlatformBs
                                        andFallingPlatforms:(int)numberOfFallingPlatforms
                                        andDoBPlatformsExist:TRUE];
    
    //NSLog(@"Number of Moving Platforms is %d and number of Falling Platforms is %d", numberOfPlatforms, numberOfFallingPlatforms);   
    if( (numberOfPlatforms > 0)||(numberOfPlatformBs >0) )
    {
        //Adding platform data to the gameScene, if there is any platform data.
        [GameScene sharedGameScene].doesLevelHavePlatforms=TRUE;
        
        //our temporary holder of platform Data.
        NSMutableDictionary * platformData;
             
        int xOffset ;
        int yOffset ; 
        
        int count= 0;
        
        if(numberOfPlatformBs > 0)
            for (platformData in [platformBObjects objects]) {
                
                
                x = [[platformData valueForKey:@"x"] intValue];
                y = [[platformData valueForKey:@"y"] intValue];
                
                
                xOffset = [[platformData valueForKey:@"xOffset"] intValue];
                yOffset = [[platformData valueForKey:@"yOffset"] intValue];
                
                //NSLog(@"Tile information: X %d, Y %d, width %d, height %d",x,y,w,h);   
                
                [[GameScene sharedGameScene] addPlatformAtPosition:ccp(x,y) 
                withOffset:ccp(xOffset, yOffset) andIndex:count];
                
                count++;
            }
            
            
        else    
            for (platformData in [platformObjects objects]) {
            
            x = [[platformData valueForKey:@"x"] intValue];
            y = [[platformData valueForKey:@"y"] intValue];
            
            
            xOffset = [[platformData valueForKey:@"xOffset"] intValue];
            yOffset = [[platformData valueForKey:@"yOffset"] intValue];
            
            //NSLog(@"Tile information: X %d, Y %d, width %d, height %d",x,y,w,h);   
            [[GameScene sharedGameScene] addPlatformAtPosition:ccp(x,y) withOffset:ccp(xOffset, yOffset) andIndex:count];
            
            count++;
        }
        
    }
    else
        [GameScene sharedGameScene].doesLevelHavePlatforms=FALSE;

    
    
    //If there are any falling platforms, add them to the gameScene as well.
    if(numberOfFallingPlatforms > 0)
    {       
        //our temporary holder of platform Data.
        NSMutableDictionary * platformData;
        
        int count= 0; 
        
        for (platformData in [fallingPlatformObjects objects]) {
            
            
            x = [[platformData valueForKey:@"x"] intValue];
            y = [[platformData valueForKey:@"y"] intValue];
            
            
            //NSLog(@"Tile information: X %d, Y %d, width %d, height %d",x,y,w,h);   
            //Add the falling platforms to the gameScene.
            [[GameScene sharedGameScene] addFallingPlatformAtPosition:ccp(x,y) 
                                                             andIndex:(count + FALLING_PLATFORM_TAG_OFFSET) ];
            
            count++;
        }
        
    }
    
   
    //----------3. Getting spawn point information for a Key object, if any.
        //Then, add the Key object to the gameScene.   
    NSDictionary *keyLocationInfo = [[tileMap objectGroupNamed:@"Game Objects"] objectNamed:@"Key"];
    if(keyLocationInfo != nil)
    {  
        [GameScene sharedGameScene].doesLevelHaveAKey=TRUE;
        
        x = [[keyLocationInfo valueForKey:@"x"] intValue];
        y = [[keyLocationInfo valueForKey:@"y"] intValue];
        [[GameScene sharedGameScene] initKeyAtPosition:ccp(x,y)];
        
    }
    else
        [GameScene sharedGameScene].doesLevelHaveAKey=FALSE;
    
    
    //---------4. Getting position info for our Door object, and then add it to the gameScene.
    NSDictionary *doorInfo = [[tileMap objectGroupNamed:@"Game Objects"] objectNamed:@"Goal"];
    x = [[doorInfo valueForKey:@"x"] intValue];
    y = [[doorInfo valueForKey:@"y"] intValue];
    
    [[GameScene sharedGameScene] initDoorAtPosition:ccp(x,y)];
    
    //--------5. Fetching the numbered platforms, if any.
    CCTMXObjectGroup *numberedPlatforms = [tileMap objectGroupNamed:@"Numbered Platforms"];
    
    int numberOfNumberedPlatforms= [[numberedPlatforms objects] count];
    
    if(numberOfNumberedPlatforms > 0)
    {
        
        [[GameScene sharedGameScene] createNumberedPlatformsWithArray:[numberedPlatforms objects]];
        //I can init, create and run the numbered Platforms here.
        
    }
    
    //---------6. Getting spawn point information for our Player, 
        //then using it to initialize the player at the gameScene.   
    NSDictionary *spawnPointInfo = [[tileMap objectGroupNamed:@"Game Objects"] objectNamed:@"Player"];
    x = [[spawnPointInfo valueForKey:@"x"] intValue];
    y = [[spawnPointInfo valueForKey:@"y"] intValue];
    
    [[GameScene sharedGameScene] initPlayerAtPosition:ccp(x,y)];    
    
    
    
//-----------7. Loading Teleports. It needs to know about the player's size, so it's after the player.
    
    CCTMXObjectGroup *teleports = [tileMap objectGroupNamed:@"Teleports"];
    
    int numberOfTeleports= [[teleports objects] count];
    
    //Initializing our Sprite Batch Node.
    
    if(numberOfTeleports>0)
    {
        
        [[GameScene sharedGameScene] initTeleports:numberOfTeleports];

        
        [[GameScene sharedGameScene] createTeleportsWithMutableArray:[teleports objects]];
        
    }    
 

//------------8. Getting Spike Rects.
    
    CCTMXObjectGroup *spikeRects = [tileMap objectGroupNamed:@"Spike Rects"];
	
    if(spikeRects != nil)
        [[GameScene sharedGameScene] createSpikeRectsWithArray:[spikeRects objects]];
  
    
//-------------9. Getting Spark Rects.
    
    CCTMXObjectGroup *sparkRects = [tileMap objectGroupNamed:@"Spark Rects"];

    int numberOfSparkRects= [[sparkRects objects] count];
    
    //Initializing our Sprite Batch Node.
    
    if(numberOfSparkRects>0)
    {
        
        [[GameScene sharedGameScene] createSparkRectsWithMutableArray:[sparkRects objects]];
        //I can init, create and run the sparks here.
        
        
    }    

    
     
//---------10. Getting the checkpoint information.
    //Checkpoints are not implented in the game.      
    //    NSDictionary *checkPointInfo = [[tileMap objectGroupNamed:@"Game Objects"] objectNamed:@"Check Point"];
    //    
    //    if(checkPointInfo != nil)
    //    {
    //        
    //        x = [[checkPointInfo valueForKey:@"x"] intValue];
    //        y = [[checkPointInfo valueForKey:@"y"] intValue]; 
    //        
    //        
    //    [[GameScene sharedGameScene] createCheckPointAt:ccp(x,y)];
    //  
    //        
    //    }
        
    
}

- (void) dealloc
{
	// cocos2d will automatically release all the children (Label)
	
    //Deallocating the tilemap object (once it has been loaded into the gameScene, it's not needed) 
        //and the gameScene.
    self.tileMap = nil;
    //	self.meta = nil;
    self.gameSceneInstance=nil;
	
	// don't forget to call "super dealloc"
	[super dealloc];
}

@end

