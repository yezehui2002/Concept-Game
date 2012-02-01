//
//  GameConcept4AppDelegate.h
//  GameConcept4
//
//  Created by Joan Gayle Villaneva on 1/23/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RootViewController;

@interface GameConcept4AppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow			*window;
	RootViewController	*viewController;
}

@property (nonatomic, retain) UIWindow *window;

@end
