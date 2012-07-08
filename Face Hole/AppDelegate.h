//
//  AppDelegate.h
//  Face Hole
//
//  Created by SystemTOGA on 7/6/12.
//  Copyright (c) 2012 Yuta Toga. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>{
    UIImageView *takenPicture;
    UIImageView *filterPicture;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UIImageView *takenPicture;
@property (strong, nonatomic) UIImageView *filterPicture;

@end
