//
//  CustomUIImagePickerController.m
//  Face Hole
//
//  Created by SystemTOGA on 7/7/12.
//  Copyright (c) 2012 Yuta Toga. All rights reserved.
//

#import "CustomUIImagePickerController.h"

@interface CustomUIImagePickerController ()

@end

@implementation CustomUIImagePickerController
@synthesize imageView;


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [[NSBundle mainBundle] loadNibNamed:@"CustomUIImagePickerController" owner:self options:nil];
    viewOverlay = [[UIView alloc] init];
    myToolbar = [[UIToolbar alloc] init];
    self.sourceType = UIImagePickerControllerSourceTypeCamera;
     
}
// ビュー表示時の処理
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    
    // 入力ソースが「カメラ」の場合
    if (self.sourceType == UIImagePickerControllerSourceTypeCamera) {
    // オーバーレイビューの設定
        [self setCameraOverlayView:self.view];
        
    }
     
}

// Viewが表示された後に呼び出されるメソッド
- (void)viewDidAppear:(BOOL)animated {
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
    

    // 画像を画面に表示
    [imageView performSelectorOnMainThread:@selector(setImage:) withObject:displayImage waitUntilDone:TRUE];// (2)
}

-(IBAction)takePhoto{
    [self takePicture];
}
@end
