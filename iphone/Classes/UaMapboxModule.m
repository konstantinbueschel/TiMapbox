/**
 * TiMapbox
 *
 * Created by Jonatan Lundin
 * Copyright (c) 2014 Your Company. All rights reserved.
 */

#import "UaMapboxModule.h"

#import "RMConfiguration.h"

#import "TiBase.h"
#import "TiHost.h"
#import "TiUtils.h"
#import "RMMapViewDelegate.h"
#import "UaMapboxAnnotationProxy.h"

@implementation UaMapboxModule

#pragma mark Internal

// this is generated for your module, please do not change it
-(id)moduleGUID
{
	return @"fb31619e-639b-469f-b37f-643708668d42";
}

// this is generated for your module, please do not change it
-(NSString*)moduleId
{
	return @"ua.mapbox";
}

#pragma mark Lifecycle

-(void)startup
{
	// this method is called when the module is first loaded
	// you *must* call the superclass
	[super startup];

	NSLog(@"[INFO] [MapboxModule] %@ loaded",self);
}

-(void)shutdown:(id)sender
{
	// this method is called when the module is being unloaded
	// typically this is during shutdown. make sure you don't do too
	// much processing here or the app will be quit forceably

	// you *must* call the superclass
	[super shutdown:sender];
}

#pragma mark Cleanup


#pragma mark Internal Memory Management

-(void)didReceiveMemoryWarning:(NSNotification*)notification
{
	// optionally release any resources that can be dynamically
	// reloaded once memory is available - such as caches
	[super didReceiveMemoryWarning:notification];
}


#pragma Public APIs

-(void)setAccessToken:(id)args
{
    ENSURE_STRING(args);

    NSString *accessToken = [NSString stringWithString:args];
    TiThreadPerformOnMainThread(^{
        [[RMConfiguration sharedInstance] setAccessToken:accessToken];
    }, YES);
}

MAKE_SYSTEM_STR(LINE_JOIN_MITER, kCALineJoinMiter);
MAKE_SYSTEM_STR(LINE_JOIN_ROUND, kCALineJoinRound);
MAKE_SYSTEM_STR(LINE_JOIN_BEVEL, kCALineJoinBevel);

MAKE_SYSTEM_UINT(USER_TRACKING_MODE_NONE,			RMUserTrackingModeNone);
MAKE_SYSTEM_UINT(USER_TRACKING_MODE_FOLLOW,			RMUserTrackingModeFollow);
MAKE_SYSTEM_UINT(USER_TRACKING_MODE_FOLLOW_HEADING,	RMUserTrackingModeFollowWithHeading);

MAKE_SYSTEM_UINT(ANNOTATION_ACCESSORY_TAG_LEFT, UaMapboxAnnotationAccessoryTagLeft);
MAKE_SYSTEM_UINT(ANNOTATION_ACCESSORY_TAG_RIGHT, UaMapboxAnnotationAccessoryTagRight);

@end
