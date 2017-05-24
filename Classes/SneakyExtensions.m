//
//  SneakyExtensions.m
//  ScrollingWithJoy
//
//  Created by Steffen Itterheim on 12.08.10.
//  Copyright 2010 Steffen Itterheim. All rights reserved.
//

#import "SneakyExtensions.h"


@implementation SneakyJoystick (Extension)
+(id) joystickWithRect:(CGRect)rect
{
	return [[[SneakyJoystick alloc] initWithRect:rect] autorelease];
}
@end

@implementation SneakyJoystickSkinnedBase (Extension)
+(id) skinnedJoystick
{
	return [[[SneakyJoystickSkinnedBase alloc] init] autorelease];
}
@end

