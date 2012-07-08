//
//  ViewController.m
//  Face Hole
//
//  Created by SystemTOGA on 7/6/12.
//  Copyright (c) 2012 Yuta Toga. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

-(void)viewWillAppear:(BOOL)animated{
    NSLog(@"viewWillAppear");
    AppDelegate *myAppDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    if (myAppDelegate.takenPicture.image != nil) {
        imageViewBase.image = myAppDelegate.takenPicture.image;        
    }
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

-(void)viewDidAppear:(BOOL)animated{
    NSLog(@"viewDidAppear");
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    imageView.backgroundColor= [UIColor colorWithWhite:1 alpha:0];
    //imageView.contentMode = UIViewContentModeScaleToFill;
    //imageView.clipsToBounds = YES;
    //[self.view insertSubview:imageView aboveSubview:self.view];
    self.circleArray = [[NSMutableArray alloc] init];
    NSLog(@"bouds%f frame%f", self.view.frame.size.height, self.view.bounds.size.height);
    virgin = true;
    shareButton.enabled = false;
    cameraButton.enabled = false;
    undoButton.enabled = false;
    NSLog(@"view x:%f y:%f", self.view.frame.size.width, self.view.frame.size.height);
    //toolbar.hidden = true;
    touchOnToolbar = true;
    toolbar.userInteractionEnabled = false;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"touchesBegan");
    // 現在のタッチ座標をローカル変数currentPointに保持
    UITouch *touch = [touches anyObject];
    // タッチ開始座標をインスタンス変数touchPointに保持
    touchPoint = [touch locationInView:imageView];
    self.touchDownPosX = [[NSNumber alloc] initWithFloat:touchPoint.x];
    self.touchDownPosY = [[NSNumber alloc] initWithFloat:touchPoint.y];
    NSLog(@"touchPoint.y:%f", touchPoint.y);
    if (touchPoint.y <= 372) {
        touchOnToolbar = false;
        if (virgin) {
            firstGuideLabel.hidden = true;
            nonHoleImage = [[UIImage alloc] initWithCGImage:[self imageByRenderingView].CGImage];
        }
        whenTouchImage = imageView.image;
        
        NSLog(@"hole effect comes!");
        //hole
        // 描画領域をimageViewの大きさで生成
        UIGraphicsBeginImageContext(imageView.frame.size);
        // imageViewにセットされている画像（UIImage）を描画
        [imageView.image drawInRect:
         CGRectMake(0, 0, imageView.frame.size.width, imageView.frame.size.height)];
        //ここに書く
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 1.0, 1.0, 1.0, 1.0);//important
        CGContextAddEllipseInRect(UIGraphicsGetCurrentContext(), CGRectMake(touchPoint.x-0.5, touchPoint.y-0.5, 1, 1));//please customize
        CGContextStrokePath(UIGraphicsGetCurrentContext());
        //
        //描画
        imageView.image = UIGraphicsGetImageFromCurrentImageContext();
        // 描画領域のクリア
        UIGraphicsEndImageContext();
        self.holeRadius = [NSNumber numberWithFloat:1.0];
    }else{
        NSLog(@"touch on toolbar");
        touchOnToolbar = true;
    }
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"touchesMoved");
    if (touchOnToolbar == false) {
        // 現在のタッチ座標をローカル変数currentPointに保持
        UITouch *touch = [touches anyObject];
        CGPoint currentPoint = [touch locationInView:imageView];
        self.holeRadius = [NSNumber numberWithFloat: sqrt(pow((currentPoint.x-self.touchDownPosX.floatValue), 2)+pow(currentPoint.y-self.touchDownPosY.floatValue, 2))];
        //いったん円のない元の画像にもどす（リセット）
        imageView.image = whenTouchImage;
        //再描画
        // 描画領域をimageViewの大きさで生成
        UIGraphicsBeginImageContext(imageView.frame.size);
        
        // imageViewにセットされている画像（UIImage）を描画
        [imageView.image drawInRect:
         CGRectMake(0, 0, imageView.frame.size.width, imageView.frame.size.height)];
        //ここに書く
        CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 0.75);
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 1.0, 1.0, 1.0, 1.0);//important
        CGContextAddEllipseInRect(UIGraphicsGetCurrentContext(), CGRectMake(self.touchDownPosX.floatValue-self.holeRadius.floatValue, self.touchDownPosY.floatValue-self.holeRadius.floatValue, self.holeRadius.floatValue*2, self.holeRadius.floatValue*2));
        CGContextStrokePath(UIGraphicsGetCurrentContext());
        
        CGContextSetRGBFillColor(UIGraphicsGetCurrentContext(), 1.0, 1.0, 1.0, 0.25);
        CGContextAddEllipseInRect(UIGraphicsGetCurrentContext(), CGRectMake(self.touchDownPosX.floatValue-self.holeRadius.floatValue, self.touchDownPosY.floatValue-self.holeRadius.floatValue, self.holeRadius.floatValue*2, self.holeRadius.floatValue*2));
        CGContextFillPath(UIGraphicsGetCurrentContext());
        //
        //描画
        imageView.image = UIGraphicsGetImageFromCurrentImageContext();
        // 描画領域のクリア
        UIGraphicsEndImageContext();
        // 現在のタッチ座標を次の開始座標にセット
        touchPoint = currentPoint;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"touchesEnded");
    if (touchOnToolbar == false) {
        if (virgin) {
            virgin = false;
            toolbar.userInteractionEnabled = true;
            shareButton.enabled = true;
            cameraButton.enabled = true;
            undoButton.enabled = true;
            toolbar.hidden =false;
        }
        UITouch *touch = [touches anyObject];
        touchPoint = [touch locationInView:imageView];
        
        //hole mode
        NSLog(@"hole effect comes!");
        NSDictionary *myDict= [NSDictionary dictionaryWithObjectsAndKeys:
                               [NSValue valueWithCGPoint:CGPointMake(self.touchDownPosX.floatValue, self.touchDownPosY.floatValue)], @"pos",
                               [NSNumber numberWithFloat:self.holeRadius.floatValue], @"radius",
                               nil];
        [self.circleArray addObject:myDict];
        NSLog(@"add to array");
        imageView.image = whenTouchImage;
        // 現在のタッチ座標をローカル変数currentPointに保持
        
        CGPoint currentPoint = [touch locationInView:imageView];
        
        [self makeHole];
        // 現在のタッチ座標を次の開始座標にセット
        touchPoint = currentPoint;
    }else{
        NSLog(@"do nothing because touchesEnded on toolbar");
    }
}
- (void)makeHole{
    for (int i=0; i<self.circleArray.count; i++) {
        NSLog(@"holes for %d", i);
        //hole
        // 描画領域をimageViewの大きさで生成
        UIGraphicsBeginImageContext(imageView.frame.size);
        // imageViewにセットされている画像（UIImage）を描画
        [imageView.image drawInRect:
         CGRectMake(0, 0, imageView.frame.size.width, imageView.frame.size.height)];
        //ここに書く
        CGContextSetBlendMode(UIGraphicsGetCurrentContext(), kCGBlendModeClear);//important
        
        CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 1.0);
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 0.0, 0.0, 0.0, 1.0);//important
        CGContextAddEllipseInRect(UIGraphicsGetCurrentContext(), CGRectMake([[[self.circleArray objectAtIndex:i] objectForKey:@"pos"] CGPointValue].x - [[[self.circleArray objectAtIndex:i] objectForKey:@"radius"] floatValue],
                                                                            [[[self.circleArray objectAtIndex:i] objectForKey:@"pos"] CGPointValue].y - [[[self.circleArray objectAtIndex:i] objectForKey:@"radius"] floatValue],
                                                                            [[[self.circleArray objectAtIndex:i] objectForKey:@"radius"] floatValue] * 2,
                                                                            [[[self.circleArray objectAtIndex:i] objectForKey:@"radius"] floatValue] * 2));
        CGContextStrokePath(UIGraphicsGetCurrentContext());
        
        CGContextAddEllipseInRect(UIGraphicsGetCurrentContext(), CGRectMake([[[self.circleArray objectAtIndex:i] objectForKey:@"pos"] CGPointValue].x - [[[self.circleArray objectAtIndex:i] objectForKey:@"radius"] floatValue],
                                                                            [[[self.circleArray objectAtIndex:i] objectForKey:@"pos"] CGPointValue].y - [[[self.circleArray objectAtIndex:i] objectForKey:@"radius"] floatValue],
                                                                            [[[self.circleArray objectAtIndex:i] objectForKey:@"radius"] floatValue] * 2,
                                                                            [[[self.circleArray objectAtIndex:i] objectForKey:@"radius"] floatValue] * 2));
        CGContextFillPath(UIGraphicsGetCurrentContext());
        //
        //描画
        imageView.image = UIGraphicsGetImageFromCurrentImageContext();
        // 描画領域のクリア
        UIGraphicsEndImageContext();
    }
    //play camera sound
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Pop" ofType:@"aiff"];
    NSURL *fileURL = [NSURL fileURLWithPath:path];
    [self playSystemSound:fileURL];
}
-(IBAction)undoModeButtonTouched{
    //undo
    NSLog(@"undoModeButtonTouched");
    NSLog(@"self.circleArray.count:%d", self.circleArray.count);
        [self.circleArray removeLastObject];
        imageView.image = nonHoleImage;
        [self makeHole];
    if (self.circleArray.count < 1) {
        virgin = true;
        toolbar.userInteractionEnabled = false;
        firstGuideLabel.hidden = false;
        cameraButton.enabled = false;
        shareButton.enabled =false;
        undoButton.enabled = false;
    }
    NSLog(@"after remove self.circleArray.count:%d", self.circleArray.count);
}
-(void)clear{
    UIGraphicsBeginImageContext(imageView.frame.size);
    imageView.image = nil;
    UIGraphicsEndImageContext();
}
-(IBAction)cameraButtonTouched{
    // イメージピッカーを作る
    /*
    UIImagePickerController*    imagePicker;
    imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePicker.allowsEditing = NO;//please customize
    imagePicker.showsCameraControls = YES;
    imagePicker.delegate = self;
     // オーバーレイビューの設定
     //画像の大きさがツールバーで小さくなっているので、カメラビューに合うように変換する。
     UIImageView *sendView = [[UIImageView alloc] initWithImage:imageView.image];
     //sendView.frame = CGRectMake(0, 0, 320, 480-44-44-20);
     sendView.frame = CGRectMake(0, 0, 320, 480-44-9);//9 is magic number
     sendView.alpha = 0.8;//please customize
     [imagePicker setCameraOverlayView:sendView];
     
     // イメージピッカーを表示する
     //[self presentViewController:imagePicker animated:YES completion:nil];
     */
    
    //カスタムイメージピッカー 
    /*
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    picker.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    picker.showsCameraControls = NO;
    picker.delegate = self;
    NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:@"CustomUIImagePickerController"
                                                  owner:nil
                                                options:nil];
    
    */
    
    CustomCameraViewController* cameraView;
    cameraView = [[CustomCameraViewController alloc] init];
    AppDelegate *myAppDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    NSLog(@"OtO imageView.frame:w%f h%f x%f y%f", imageView.frame.size.width, imageView.frame.size.height, imageView.frame.origin.x, imageView.frame.origin.y);
    NSLog(@"OtO filterPicture.frame:w%f h%f x%f y%f", myAppDelegate.filterPicture.frame.size.width, myAppDelegate.filterPicture.frame.size.height, myAppDelegate.filterPicture.frame.origin.x, myAppDelegate.filterPicture.frame.origin.y);
    NSLog(@"OtO imageView.image:w%f h%f", imageView.image.size.width, imageView.image.size.height);
    
    myAppDelegate.filterPicture.image = imageView.image;
    [self presentViewController:cameraView animated:YES completion:nil];
}
- (BOOL) startCameraControllerFromViewController: (UIViewController*) controller
                                   usingDelegate: (id <UIImagePickerControllerDelegate,
                                                   UINavigationControllerDelegate>) delegate {
    if (([UIImagePickerController isSourceTypeAvailable:
          UIImagePickerControllerSourceTypeCamera] == NO)
        || (delegate == nil)
        || (controller == nil))
        return NO;
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
    // ユーザが写真またはムービーのキャプチャを選択するためのコントロールを表示する
    // （写真とムービーの両方が利用可能な場合）
    cameraUI.mediaTypes =
    [UIImagePickerController availableMediaTypesForSourceType:
     UIImagePickerControllerSourceTypeCamera];
    // 写真の移動と拡大縮小、または
    // ムービーのトリミングのためのコントロールを隠す。代わりにコントロールを表示するには、YESを使用する。
    cameraUI.allowsEditing = YES;//please customize
    cameraUI.delegate = delegate;
    cameraUI.showsCameraControls = YES;
    [controller presentViewController:cameraUI animated:YES completion:nil];
    return YES;
}
// 「キャンセル(Cancel)」をタップしたユーザへの応答.
- (void) imagePickerControllerDidCancel: (UIImagePickerController *) picker {
    NSLog(@"imagePickerControllerDidCancel");
    [self dismissViewControllerAnimated:YES completion:nil];
}
// 新規にキャプチャした写真やムービーを受理したユーザへの応答
- (void) imagePickerController: (UIImagePickerController *) picker
 didFinishPickingMediaWithInfo: (NSDictionary *) info {
    NSLog(@"picker done!");
    [self.circleArray removeAllObjects];
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    UIImage *originalImage, *editedImage, *imageToSave;
    UIImage *pickedPhoto = [info objectForKey:UIImagePickerControllerOriginalImage];
    NSLog(@"pickedPhoto:%d", pickedPhoto.imageOrientation);
    // 静止画像のキャプチャを処理する
    if (CFStringCompare ((__bridge CFStringRef) mediaType, kUTTypeImage, 0)
        == kCFCompareEqualTo) {
        editedImage = (UIImage *) [info objectForKey:
                                   UIImagePickerControllerEditedImage];
        originalImage = (UIImage *) [info objectForKey:
                                     UIImagePickerControllerOriginalImage];
        if (editedImage) {
            imageToSave = editedImage;
            //pictImageView.image = editedImage;//problem is here
            //update special image
            NSLog(@"camera:%d", picker.cameraDevice);
            if (picker.cameraDevice) {
                pickedPhoto = [UIImage imageWithCGImage:pickedPhoto.CGImage scale:pickedPhoto.scale orientation:UIImageOrientationLeftMirrored];
            }
            imageView.image = pickedPhoto;
        } else {
            imageToSave = originalImage;
            //pictImageView.image = originalImage;//problem is here
            //update special image
            NSLog(@"camera:%d", picker.cameraDevice);
            if (picker.cameraDevice) {
                pickedPhoto = [UIImage imageWithCGImage:pickedPhoto.CGImage scale:pickedPhoto.scale orientation:UIImageOrientationLeftMirrored];
            }
            imageView.image = pickedPhoto;
        }
        // （オリジナルまたは編集後の）新規画像を「カメラロール(Camera Roll)」に保存する
        UIImageWriteToSavedPhotosAlbum (imageToSave, nil, nil , nil);
    }
    // ムービーのキャプチャを処理する
    if (CFStringCompare ((__bridge CFStringRef) mediaType, kUTTypeMovie, 0)
        == kCFCompareEqualTo) {
        NSString *moviePath = [[info objectForKey:
                                UIImagePickerControllerMediaURL] path];
        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum (moviePath)) {
            UISaveVideoAtPathToSavedPhotosAlbum (
                                                 moviePath, nil, nil, nil);
        }
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (UIImage *)mirrorImage:(UIImage *)img{
    
    CGImageRef imgRef = [img CGImage]; // 画像データ取得
    
    UIGraphicsBeginImageContext(img.size); // 開始
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    // コンテキスト取得
    CGContextTranslateCTM( context, img.size.width,
                          img.size.height); // コンテキストの原点変更
    CGContextScaleCTM( context, -1.0, -1.0);
    // コンテキストの軸をXもYも等倍で反転
    CGContextDrawImage( context, CGRectMake( 0, 0,
                                            img.size.width, img.size.height), imgRef);
    // コンテキストにイメージを描画
    UIImage *retImg = UIGraphicsGetImageFromCurrentImageContext();
    // コンテキストからイメージを取得
    
    UIGraphicsEndImageContext(); // 終了
    
    return retImg;
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

-(IBAction)actionButtonTouched{
    //https://devforums.apple.com/message/679214#679214
    NSString *hoge = [[NSString alloc] initWithString:@"Hello, world!"];
    NSMutableArray *myActivityItemsArray = [[NSMutableArray alloc] init];
    [myActivityItemsArray addObject:hoge];
    UIImage *capturedImage = [self imageByRenderingView];
    [myActivityItemsArray addObject:capturedImage];
    UIActivityViewController *sharing = [[UIActivityViewController alloc] initWithActivityItems:myActivityItemsArray applicationActivities:nil];
    [self presentViewController:sharing animated:YES completion:nil];
}
//capture function
- (UIImage *)imageByRenderingView
{
    //UIGraphicsBeginImageContext(self.view.bounds.size);
    UIGraphicsBeginImageContext(CGRectMake(0, 0, 320, 480-44-44-20).size);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultingImage;
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
-(IBAction)imageButtonTouched{
    NSLog(@"imageButtonTouched");
    //[self startCameraControllerFromViewController: self usingDelegate: self];
    UIActionSheet*  sheet;
    sheet = [[UIActionSheet alloc]
             initWithTitle:@"Select Source Type"
             delegate:self
             cancelButtonTitle:@"Cancel"
             destructiveButtonTitle:nil
             otherButtonTitles:@"Photo Library", @"Camera", @"Saved Photos", nil];
    
    // アクションシートを表示する
    [sheet showInView:self.view];
    UIImagePickerControllerSourceType   sourceType = 0;
    sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
}


@end
