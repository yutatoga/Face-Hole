//
//  CustomUIImagePickerController.h
//  Face Hole
//
//  Created by SystemTOGA on 7/7/12.
//  Copyright (c) 2012 Yuta Toga. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreVideo/CoreVideo.h>
#import <CoreMedia/CoreMedia.h>
@interface CustomUIImagePickerController : UIImagePickerController<AVCaptureVideoDataOutputSampleBufferDelegate>{
    UIView	 *viewOverlay;
    IBOutlet UIToolbar *myToolbar;
    // キャプチャーセッション
    AVCaptureSession *session; //  (1)

}
@property (nonatomic,retain) IBOutlet UIImageView *imageView;
@end
