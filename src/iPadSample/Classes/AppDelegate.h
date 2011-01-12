//
//  AppDelegate.h
//  iPadSample
//
//  Created by Timothy Kerchmar on 11/30/10.
//  Copyright 2010 The Night School, LLC. All rights reserved.
//

#include "TSRenderer.h"

@class iPadSampleViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    iPadSampleViewController *viewController;
	TSRenderer* renderer;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet iPadSampleViewController *viewController;

@end

