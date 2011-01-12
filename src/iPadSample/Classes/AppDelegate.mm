//
//  AppDelegate.m
//  iPadSample
//
//  Created by Timothy Kerchmar on 11/30/10.
//  Copyright 2010 The Night School, LLC. All rights reserved.
//

using namespace std;

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize window;
@synthesize viewController;

- (void)applicationDidFinishLaunching:(UIApplication *)application {
	[[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeLeft animated:NO];
	
	UIWindow* localWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	localWindow.backgroundColor = [UIColor redColor];
	self.window = localWindow;
	[localWindow release];
	
	renderer = new TSRenderer();
	[window addSubview:renderer->view];
	[window makeKeyAndVisible];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    renderer->stopAnimation();
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	renderer->startAnimation();
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	renderer->stopAnimation();
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Handle any background procedures not related to animation here.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Handle any foreground procedures not related to animation here.
}

- (void)dealloc
{
	delete renderer;
    [window release];
    
    [super dealloc];
}

@end
