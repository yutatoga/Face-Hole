//
//  ViewController.h
//  Face Hole
//
//  Created by SystemTOGA on 7/6/12.
//  Copyright (c) 2012 Yuta Toga. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "CustomUIImagePickerController.h"
#import <AVFoundation/AVFoundation.h>
#import "CustomCameraViewController.h"
#import "AppDelegate.h"

@interface ViewController : UIViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate>{
    IBOutlet UIImageView *imageViewBase;
    IBOutlet UIImageView *imageView;
    UIImageView *canvas;
    CGPoint touchPoint;
    UIImage *whenTouchImage;
    UIImageView *takenPhoto;
    UIImage *nonHoleImage;
    BOOL virgin;
    IBOutlet UIBarButtonItem *cameraButton;
    IBOutlet UIBarButtonItem *undoButton;
    IBOutlet UIBarButtonItem *shareButton;
    IBOutlet UIToolbar *toolbar;
    BOOL touchOnToolbar;
    IBOutlet UILabel *firstGuideLabel;
}
@property (nonatomic, retain) NSNumber *touchDownPosX;
@property (nonatomic, retain) NSNumber *touchDownPosY;
@property (nonatomic, retain) NSNumber *holeRadius;
@property (nonatomic, retain) NSMutableArray *circleArray;
-(IBAction)actionButtonTouched;
-(IBAction)undoModeButtonTouched;
-(IBAction)imageButtonTouched;
@end
