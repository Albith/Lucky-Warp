//
//  TileMapHandler.h
//  Lucky Warp
//
//  Created by Albith Delgado on 11. 7. 12..
//  Copyright 2011 __Albith Delgado__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "GameScene.h"

@class GameScene;

//This class loads a .tmx file and processes it to render a game level.
    //This TileMap manager adds level elements not explicitly found in the tmx file:
    //such as collision boxes, platform placement and properties,
    //as well as spark elements and properties.


@interface TileMapHandler : NSObject {

GameScene *gameSceneInstance;

}

@property (nonatomic, retain) CCTMXTiledMap *tileMap;
@property (assign) GameScene *gameSceneInstance;
//Not using these layer properties for the moment.
    //@property (nonatomic, retain) CCTMXLayer *tileLayer;
    //@property (nonatomic, retain) CCTMXLayer *firstLayer;

+(id) initTileMap:(GameScene*)sceneInstance;
- (id) init:(GameScene *)sceneInstance;

- (void) drawBodyTiles;


@end
