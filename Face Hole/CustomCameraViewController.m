//
//  CustomCameraViewController.m
//  Face Hole
//
//  Created by SystemTOGA on 7/7/12.
//  Copyright (c) 2012 Yuta Toga. All rights reserved.
//

#import "CustomCameraViewController.h"

@interface CustomCameraViewController ()

@end

@implementation CustomCameraViewController

@synthesize imageView;
@synthesize imageViewBase;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated{
    AppDelegate *myAppDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    imageView.image = myAppDelegate.filterPicture.image;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if (session == nil) {
        NSError *error = nil;
        // 入力と出力からキャプチャーセッションを作成
        session = [[AVCaptureSession alloc] init];
        session.sessionPreset = AVCaptureSessionPresetMedium; // (1)
        
        // カメラからの入力を作成
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];// (2)
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
        [session addInput:input];
        
        // ビデオへの出力を作成
        AVCaptureVideoDataOutput *output = [[AVCaptureVideoDataOutput alloc] init];
        [session addOutput:output];
        
        // ビデオ出力のキャプチャの画像情報のキューを設定
        dispatch_queue_t queue = dispatch_queue_create("myQueue", NULL);//(3)
        [output setAlwaysDiscardsLateVideoFrames:TRUE];
        [output setSampleBufferDelegate:self queue:queue];
        
        // ビデオへの出力の画像は、BGRAで出力
        output.videoSettings = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey];
        

    }
    
    if (!session.running) {
        // セッションを開始
        [session startRunning]; // (5)
    }
    AppDelegate *myAppDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    imageViewBase.image = myAppDelegate.filterPicture.image;
    curerntPositioin = AVCaptureDevicePositionBack;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
}
// キャプチャしたフレームからCGImageに変換するメソッド。
- (CGImageRef) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer {
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(imageBuffer,0);
    
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    // RGBの色空間
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // キャプチャしたフレームの画像情報が格納されているアドレス
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    // キャプチャしたフレームの画像情報からCGBitmapContextを作成
    CGContextRef newContext = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    // CGBitmapContextからCGImageを作成
    CGImageRef cgImage = CGBitmapContextCreateImage(newContext);
    CGContextRelease(newContext);
    CGColorSpaceRelease(colorSpace);
    
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
    return cgImage;
}

// AVCaptureVideoDataOutputSampleBufferDelegateプロトコルのメソッド。新しいキャプチャの情報が追加されたときに呼び出される。
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    // キャプチャしたフレームからCGImageを作成
    CGImageRef inImage = [self imageFromSampleBuffer:sampleBuffer];
    CGImageRef filteredImage;
    filteredImage = CGImageRetain(inImage);
    // CGImageをUIImageに変換
    UIImage *displayImage = [UIImage imageWithCGImage:filteredImage];
    CGImageRelease(filteredImage);
    CGImageRelease(inImage);
    
    
    displayImage = [self rotateImage:displayImage imageOrientation:3];//OtO added
    //内側カメラの時だけ左右反転
    if (curerntPositioin == AVCaptureDevicePositionFront) {
        displayImage = [UIImage imageWithCGImage:displayImage.CGImage scale:displayImage.scale orientation:UIImageOrientationUpMirrored];
    }
    //カメラからの画像を画面に表示
    [imageViewBase performSelectorOnMainThread:@selector(setImage:) withObject:displayImage waitUntilDone:TRUE];// (2)
}
// 撮影画面に表示されている画像をアルバムに保存
- (IBAction)takePhotoAction:(id)sender {
    NSLog(@"shouldAutorotateToInterfaceOrientation");
    //play camera sound
    NSString *path = [[NSBundle mainBundle] pathForResource:@"camera2" ofType:@"wav"];
    NSURL *fileURL = [NSURL fileURLWithPath:path];
    [self playSystemSound:fileURL];
    // iPhoneのアルバムに保存
    UIImageWriteToSavedPhotosAlbum(imageViewBase.image,self,nil,nil);
    AppDelegate *myAppDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    myAppDelegate.takenPicture.image = imageViewBase.image;
    [self dismissViewControllerAnimated:YES completion:nil];
}
//sound
-(void)playSystemSound:(NSURL *)fileURL{
    SystemSoundID mySystemSoundID;
    //[3] SystemSoundIDを作成する
    OSStatus err = AudioServicesCreateSystemSoundID((__bridge CFURLRef) fileURL, &mySystemSoundID);
    //[4]エラーがあった場合はreturnで中止
    if(err){
        NSLog(@"AudioServicesCreateSystemSoundID err = %li",err);
        return;
    }
    AudioServicesPlaySystemSound(mySystemSoundID);//just sound
    //AudioServicesPlayAlertSound(mySystemSoundID);//sound + vibration
}

- (UIImage*)rotateImage:(UIImage*)img imageOrientation:(int)angleID
{
    CGImageRef img_ref = [img CGImage];
    CGContextRef context;
    UIImage *rotate_image;
    switch (angleID) {
        case 0:
            rotate_image = img;
            return rotate_image;
            break;
        case 2:
            UIGraphicsBeginImageContext(CGSizeMake(img.size.height, img.size.width));
            context = UIGraphicsGetCurrentContext();
            CGContextTranslateCTM(context, img.size.height, img.size.width);
            CGContextScaleCTM(context, 1.0, -1.0);
            CGContextRotateCTM(context, M_PI/2.0);
            break;
        case 1:
            UIGraphicsBeginImageContext(CGSizeMake(img.size.width, img.size.height));
            context = UIGraphicsGetCurrentContext();
            CGContextTranslateCTM(context, img.size.width, 0);
            CGContextScaleCTM(context, 1.0, -1.0);
            CGContextRotateCTM(context, -M_PI);
            break;
        case 3:
            UIGraphicsBeginImageContext(CGSizeMake(img.size.height, img.size.width));
            context = UIGraphicsGetCurrentContext();
            CGContextScaleCTM(context, 1.0, -1.0);
            CGContextRotateCTM(context, -M_PI/2.0);
            break;
        default:
            return nil;
    }
    
    CGContextDrawImage(context, CGRectMake(0, 0, img.size.width, img.size.height), img_ref);
    rotate_image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return rotate_image;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(IBAction)changeCamera{
    NSLog(@"changeCamera");
    /*
    NSArray *devices = [AVCaptureDevice devices];
    NSError *error = nil;
    AVCaptureDevice *frontCamera;
    AVCaptureDevice *backCamera;
    for (AVCaptureDevice *device in devices) {
        
        NSLog(@"Device name: %@", [device localizedName]);
        NSLog(@"%d",[device position]);
        if ([device hasMediaType:AVMediaTypeVideo]) {
            
            if ([device position] == AVCaptureDevicePositionBack) {
                NSLog(@"Device position : back");
                backCamera = device;
            }
            else {
                NSLog(@"Device position : front");
                frontCamera = device;
            }
        }
    }
    AVCaptureDeviceInput *frontFacingCameraDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:frontCamera error:&error];
    AVCaptureDeviceInput *backFacingCameraDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:backCamera error:&error];
    [session beginConfiguration];
    [session removeInput:backFacingCameraDeviceInput];
    [session addInput:frontFacingCameraDeviceInput];
    [session commitConfiguration];
    
    //from apple
    
    AVCaptureSession *session = <#A capture session#>;
    [session beginConfiguration];
    [session removeInput:frontFacingCameraDeviceInput];
    [session addInput:backFacingCameraDeviceInput];
    [session commitConfiguration];
    */
    
    NSError *error = nil;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
        [session setSessionPreset:AVCaptureSessionPreset640x480];
    } else {
        [session setSessionPreset:AVCaptureSessionPresetPhoto];
    }
    // Select a video device, make an input
    AVCaptureDevice *device;
    

    AVCaptureDevicePosition desiredPosition = (curerntPositioin == AVCaptureDevicePositionBack ? AVCaptureDevicePositionFront: AVCaptureDevicePositionBack);
    curerntPositioin = desiredPosition;
    // find the front facing camera
    for (AVCaptureDevice *d in [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo]) {
        if ([d position] == desiredPosition) {
            device = d;
            break;
        }
    }
    
    
    
    
    
    [session stopRunning];
    session = nil;
    if (session == nil) {
        // 入力と出力からキャプチャーセッションを作成
        session = [[AVCaptureSession alloc] init];
        session.sessionPreset = AVCaptureSessionPresetMedium; // (1)
        
        // カメラからの入力を作成
        // (2)
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
        [session addInput:input];
        
        // ビデオへの出力を作成
        AVCaptureVideoDataOutput *output = [[AVCaptureVideoDataOutput alloc] init];
        [session addOutput:output];
        
        // ビデオ出力のキャプチャの画像情報のキューを設定
        dispatch_queue_t queue = dispatch_queue_create("myQueue", NULL);//(3)
        [output setAlwaysDiscardsLateVideoFrames:TRUE];
        [output setSampleBufferDelegate:self queue:queue];
        
        // ビデオへの出力の画像は、BGRAで出力
        output.videoSettings = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey];
        
    }
    
    if (!session.running) {
        // セッションを開始
        [session startRunning]; // (5)
    }
    AppDelegate *myAppDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    imageViewBase.image = myAppDelegate.filterPicture.image;

}

@end
