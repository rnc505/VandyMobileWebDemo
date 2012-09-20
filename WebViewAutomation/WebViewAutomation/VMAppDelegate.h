//
//  VMAppDelegate.h
//  WebViewAutomation
//
//  Created by Robby Cohen on 9/18/12.
//  Copyright (c) 2012 Robby Cohen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VMViewController;

@interface VMAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) VMViewController *viewController;

@end
