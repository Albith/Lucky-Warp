//
//  InputLayer.m
//  ScrollingWithJoy
//
//  Created by Steffen Itterheim on 12.08.10.
//  Copyright 2010 Steffen Itterheim. All rights reserved.
//

#import "InputLayer.h"
#import "GameScene.h"

//I have modifified this inputLayer class to fit the game's joystick and button configuration.
	//Joystick input is now directly handled by the gameScene.

@interface InputLayer (PrivateMethods)
-(void) addFireButton;
-(void) addJoystick;
@end

@implementation InputLayer

-(id) init
{
	if ((self = [super init]))
	{
		[self addJoystick];
		
		[self scheduleUpdate];
	}
	
	return self;
}

-(void) dealloc
{
	[super dealloc];
}

-(void) addJoystick
{
	float stickRadius = 128;

	joystick = [SneakyJoystick joystickWithRect:CGRectMake(0, 0, stickRadius, stickRadius)];
	joystick.autoCenter = YES;
	
	// Now with fewer directions
	joystick.isDPad = YES;
	joystick.numberOfDirections = 2;
	
	SneakyJoystickSkinnedBase* skinStick = [SneakyJoystickSkinnedBase skinnedJoystick];
	skinStick.position = CGPointMake(stickRadius * 1.5f, stickRadius * 1.5f);
	skinStick.backgroundSprite = [ColoredCircleSprite circleWithColor:ccc4(255, 0, 0, 128) radius:64];
	skinStick.thumbSprite = [ColoredCircleSprite circleWithColor:ccc4(0, 0, 255, 200) radius:32];
	skinStick.thumbSprite.scale = 0.5f;
	skinStick.joystick = joystick;
	[self addChild:skinStick];
}

-(void) update:(ccTime)delta
{

//Note: The code sample inside this update method is not used in my game.

//totalTime += delta;
//
//	//// Continuous fire
//	if (fireButton.active && totalTime > nextShotTime)
//	{
//		nextShotTime = totalTime + 0.5f;
//
//		GameScene* game = [GameScene sharedGameScene];
//		ShipEntity* ship = [game defaultShip];
//		BulletCache* bulletCache = [game bulletCache];
//
//		// Set the position, velocity and spriteframe before shooting
//		CGPoint shotPos = CGPointMake(ship.position.x + [ship contentSize].width * 0.5f, ship.position.y);
//		float spread = (CCRANDOM_0_1() - 0.5f) * 0.5f;
//		CGPoint velocity = CGPointMake(4, spread);
//		[bulletCache shootBulletFrom:shotPos velocity:velocity frameName:@"bullet.png" isPlayerBullet:YES];
//	}
//	
//	// Allow faster shooting by quickly tapping the fire button.
//	if (fireButton.active == NO)
//	{
//		nextShotTime = 0;
//	}
	
	// Moving the ship with the thumbstick.
	//GameScene* game = [GameScene sharedGameScene];
	//ShipEntity* ship = [game defaultShip];
//	
//	CGPoint velocity = ccpMult(joystick.velocity, 200);
//	if (velocity.x != 0 && velocity.y != 0)
//	{
//		ship.position = CGPointMake(ship.position.x + velocity.x * delta, ship.position.y + velocity.y * delta);
//	}
}

@end
