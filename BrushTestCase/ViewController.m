//
//  MainView.m
//  MotionFX
//
//  Created by Nadav on 5/28/13.
//  Copyright (c) 2013 Dropico Media LTD. All rights reserved.
//

//#import "UIFont+Extras.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import <Dropico/DropicoUtils.h>
#import <QuartzCore/QuartzCore.h>
//#import "DMImagePicker.h"
#import "AppManager.h"
//#import "DataManager.h"
//#import "SVProgressHUD.h"
//#import "SoundManager.h"
//#import "MBProgressHUD.h"

#define kCameraDevice @"cameraDevice"
#define kCameraFlashMode @"cameraFlashMode"
#define FILTER_THUMB_WIDTH      70
#define FILTER_THUMB_HEIGHT     70
#define FILTER_CELL_SIZE        75
/*
 Use to determind the current state of this ViewController state.
 */
typedef enum {
	VideoControllerStateNone,
	VideoControllerStateRecording,
    VideoControllerVideoFromLibrary,
	VideoControllerWaitingForProcess,
    VideoControllerProcessing,
    VideoControllerFinishedProcessing,
    VideoControllerPreview,
    VideoControllerProvided // means that the video is saved/uploaded
    // and StartOver should be visible
} VideoControllerState;
/*
 Use to determine if the user want to share the video to facebook/youtube or some other social network.
 */
typedef enum {
	VideoSaveOptionGallery,
	VideoSaveOptionFacebook,
	VideoSaveOptionYouTube
} VideoSaveOption;
@interface ViewController ()
{
    IBOutlet       UIView       *shareView;
    IBOutlet       UIView       *publishView;
    IBOutlet       UIView       *controlView;
    IBOutlet       UIView       *startOverView;
    IBOutlet       UIView      *timerView;
    IBOutlet       UIButton     *privacyButton;
    IBOutlet       UIButton     *browseButton;
    IBOutlet       UIButton     *flashButton;
    IBOutlet       UIButton     *saveButton;
    IBOutlet       UILabel      *timerLabel;
    IBOutlet       UITextField  *titleTextField;
    IBOutlet       UITextField  *descTextField;
    IBOutlet       UIImageView  *recButtonImg;
    IBOutlet       UIImageView  *rightWheel;
    IBOutlet       UIImageView  *leftWheel;
    IBOutlet       UIImageView  *disabledText;
    IBOutlet       UIImageView  *tapToRecord;
    IBOutletCollection(UIButton)  NSArray *publishButtons;
    
    BOOL            isRecord;
    BOOL            hasFrontcam;
    BOOL            hasFlash;
    BOOL            flashOn;
    BOOL            didSaveVideo;
    BOOL            didRecordVideo;
    
    VideoControllerState    state;
    VideoSaveOption         saveOption;
    
    NSMutableArray              *filtersArray;
    NSUInteger      selectedFilter;
    //    EasyTableView   *tblFilters;
    // SHYouTubeBox    *_youTubeBox;
    
    NSTimer     *animationTimer;
    //    DMImagePicker *picker;
    //    MBProgressHUD *hud;
    Semaphore * saveSem;
    
    NSMutableArray * currentStroke;
}
-(void)setupUI;
@end

@implementation ViewController

-(void)setupUI
{
    /*
     if(IS_IPAD)
     tblFilters = [[EasyTableView alloc] initWithFrame:CGRectMake(280, 545, 715, 200) numberOfColumns:20 ofWidth:300];
     else
     tblFilters = [[EasyTableView alloc] initWithFrame:CGRectMake((IS_IPHONE_5)?95:7, 228, 466, 90) numberOfColumns:20 ofWidth:128];
     
     tblFilters.delegate                 = self;
     tblFilters.glDisplayLink            = videoView;
     tblFilters.tableView.backgroundColor= [UIColor clearColor];
     tblFilters.tableView.opaque         = NO;
     tblFilters.backgroundColor          = [UIColor clearColor];
     tblFilters.opaque                   = NO;
     tblFilters.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
     [self.view addSubview: tblFilters];
     [self.view insertSubview:startOverView aboveSubview:tblFilters];
     [self.view insertSubview:disabledText aboveSubview:tblFilters];
     disabledText.alpha = 0;
     if(!IS_IPAD){
     disabledText.center = tblFilters.center;
     startOverView.frame =CGRectMake(IS_IPHONE_5 ? 90 : 0, 200, 480, 120);
     if(!IS_IPHONE_5){
     disabledText.x      = 170;
     publishView.width   = 480;
     shareView.width     = 480;
     }
     }
     
     
     // Init defaults
     if(![DropicoUtils getDefaultsValueForkey: kCameraFlashMode]) [DropicoUtils setDefaultsValue:[NSNumber numberWithInt: UIImagePickerControllerCameraFlashModeAuto] forKey:kCameraFlashMode];
     if(![DropicoUtils getDefaultsValueForkey: kCameraDevice]) [DropicoUtils setDefaultsValue:[NSNumber numberWithInt: UIImagePickerControllerCameraDeviceRear] forKey:kCameraDevice];
     
     // Check for front cam
     if(![UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]){
     hasFrontcam = NO;
     }
     
     //Check for flash
     if(![UIImagePickerController isFlashAvailableForCameraDevice:UIImagePickerControllerCameraDeviceRear]){
     hasFlash = NO;
     [self setFlashEnabled :NO];
     }else
     hasFlash = YES;
     
     
     //    timerLabel.font= [UIFont customFont:BebasNeue withSize:IS_IPAD ? 35 : 28];
     [titleTextField setBackground:[UIImage imageNamed:@"TextFieldBg"]];
     [descTextField  setBackground:[UIImage imageNamed:@"TextFieldBg"]];*/
}
#pragma mark - Setup YouTubeBox for youtube video upload

-(void)setupYouTubeBox
{
    /*
     _youTubeBox = [[SHYouTubeBox alloc] init];
     [_youTubeBox setBoxBehavior:SHYouTubeBoxBehaviorAutoPresentLogin | SHYouTubeBoxBehaviorHandelLoginFailure ];
     [_youTubeBox setDelegate:self];
     */
}
#pragma mark - Setup all iVars

-(void)setup
{
    isRecord = NO;
    didRecordVideo  = NO;
    selectedFilter  = 0;
    //    filtersArray = [[DataManager sharedManager] getEffects];
    saveOption = VideoSaveOptionGallery;
    [self setState:VideoControllerStateNone];
    //Setup VideoView
    [collageView setDisplay:YES];
    saveSem = [Semaphore new];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    if(IS_IPHONE_5)
        [self.view setFrame:CGRectMake(0, 0, 568, 320)];
    //[self setupYouTubeBox];
    [self setup];
    [self setupUI];
    
    //    [videoView setInterfaceOrientation:UIInterfaceOrientationLandscapeRight];
    
    
    //    ModelEffect *cModel = [[DataManager sharedManager] getEffectAtIndex:0];
    //    [videoView loadEffectWithModel:IS_IPAD ? cModel.layers : cModel.previewLayers];
    //    [videoView loadEffectWithModel:nil];
}
-(void)setState:(VideoControllerState)state1{
    state = state1;
    
    if(state1 == VideoControllerStateNone){
        // fresh start
        dispatch_async(dispatch_get_main_queue(), ^{
            browseButton.enabled   = YES;
            saveButton.enabled     = NO;
            startOverView.hidden   = YES;
            timerView.hidden       = NO;
            flashButton.enabled    = YES;
            controlView.hidden     = NO;
            tapToRecord.hidden     = NO;
            didSaveVideo = NO;
        });
        //        [videoView startCamera];
    }else if(state1 == VideoControllerStateRecording){
        browseButton.enabled = NO;
        [self animateFiltersTable:NO];
        tapToRecord.hidden = YES;
        [UIView animateWithDuration:0.4 animations:^{
            recButtonImg.superview.width = IS_IPAD ? 120 : 80;
            disabledText.alpha = 1;
        }];
        
        [self startRotatingWheels];
        
    }else if(state1 == VideoControllerVideoFromLibrary){
        tapToRecord.hidden = YES;
        controlView.hidden = YES;
        timerView.hidden   = YES;
    }else if(state1 == VideoControllerWaitingForProcess){
        
    }else if(state1 == VideoControllerProcessing){
        
        [self stopRotatingWheels];
        [self animateFiltersTable:YES];
        if(animationTimer!=nil){
            [animationTimer invalidate];
            animationTimer = nil;
        }
        [UIView animateWithDuration:0.5
                         animations:^{
                             recButtonImg.alpha = 0.0f;
                             disabledText.alpha = 0;
                         }
                         completion:^(BOOL finished){
                             [recButtonImg.layer removeAllAnimations];
                         }];
        
    }
    else if(state1 == VideoControllerPreview || state1 == VideoControllerProvided){
        flashButton.enabled = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self dismissProgress];
            recButtonImg.superview.width = IS_IPAD ? 60 : 40;
            timerView.hidden     = YES;
            [timerLabel setText:@"00.00.00"];
            browseButton.enabled = NO;
            startOverView.hidden = NO;
            controlView.hidden = YES;
            saveButton.enabled = YES;
        });
        
        //hid timer as well
    }
    else if(state1 == VideoControllerProvided){
        startOverView.hidden = NO;
        flashButton.enabled = NO;
    }
}
-(void)enablePublishButtons:(id)object
{
    BOOL  enable = [object boolValue];
    for(UIButton *button in publishButtons){
        [button setEnabled:enable];
    }
}
#pragma mark - View Rotation

- (BOOL)shouldAutorotate
{
    return YES;
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}
#pragma mark - Rotatting Wheels Animations

-(void)startRotatingWheels
{
    [self runSpinAnimationOnView:rightWheel duration:2.5 rotations:1 repeat:2500];
    [self runSpinAnimationOnView:leftWheel  duration:2.5 rotations:1 repeat:2500];
}
-(void)stopRotatingWheels
{
    [rightWheel.layer removeAllAnimations];
    [leftWheel.layer removeAllAnimations];
}
- (void) runSpinAnimationOnView:(UIView*)view duration:(CGFloat)duration rotations:(CGFloat)rotations repeat:(float)repeat;
{
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 /* full rotation*/ * rotations * duration ];
    rotationAnimation.duration = duration;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = repeat;
    [view.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}
#pragma mark - Flash Methods (Only for iPad) Methods

-(void)setFlashEnabled:(BOOL)isEnabled
{
    if(!isEnabled)
    {
        [flashButton setImage:[UIImage imageNamed:@"flashOff"] forState:UIControlStateNormal];
        [flashButton setUserInteractionEnabled: NO];
    }else
    {
        [flashButton setImage:[UIImage imageNamed:@"On"] forState:UIControlStateNormal];
        [flashButton setUserInteractionEnabled: YES];
    }
}
-(IBAction)touchFlash:(id)sender
{
    
    if(!hasFlash)
        return;
    if(flashOn){
        flashOn = NO;
        [flashButton setImage:[UIImage imageNamed:@"flashOff"] forState:UIControlStateNormal];
    }else
    {
        flashOn = YES;
        [flashButton setImage:[UIImage imageNamed:@"flashOn"] forState:UIControlStateNormal];
    }
    
    //    [videoView toggleFlashLight];
}
#pragma mark - Browse Video  Methods

-(IBAction)touchedBrowse:(id)sender
{
    //     [[SoundManager sharedManager] playSound:beepSound];
    //    picker = [[AppManager sharedAppManager] browsePhotos];
    //    [[AppManager sharedAppManager] popoverPicker:picker forView:self.view withRect:CGRectMake(-85,180.0, 320.0, 480)];
}

/*
 #pragma mark - EasyTableView Methods
 - (NSUInteger)numberOfSectionsInEasyTableView:(EasyTableView*)easyTableView
 {
 return 1;
 }
 - (NSUInteger)numberOfCellsForEasyTableView:(EasyTableView *)view inSection:(NSInteger)section
 {
 return filtersArray.count;
 }
 -(UIView *)easyTableView:(EasyTableView *)easyTableView viewForRect:(CGRect)rect{
 
 UIView *container           = [[UIView alloc] initWithFrame: rect];
 container.backgroundColor   = [UIColor clearColor];
 container.opaque            = NO;
 
 UIImageView *img            = nil;
 if(IS_IPAD)
 img = [[UIImageView alloc] initWithFrame: CGRectMake(2, 2,290, 170)];
 else
 img = [[UIImageView alloc] initWithFrame: CGRectMake(2, 2, 124, 69)];
 
 img.clipsToBounds = YES;
 img.contentMode             = UIViewContentModeScaleAspectFill;
 img.tag                     = 20;
 [container addSubview: img];
 
 UILabel *lblTitle           = nil;
 if(IS_IPAD)
 lblTitle =  [[UILabel alloc] initWithFrame: CGRectMake(2, 172, 290, 30)];
 else
 lblTitle =  [[UILabel alloc] initWithFrame: CGRectMake(2, 73, 124, 15)];
 
 lblTitle.backgroundColor    = [UIColor clearColor];
 lblTitle.opaque             = NO;
 lblTitle.textColor          = RGBA(166, 164, 165, 1.0);
 lblTitle.textAlignment      = NSTextAlignmentLeft;
 lblTitle.lineBreakMode      = NSLineBreakByTruncatingTail;
 lblTitle.font               = [UIFont customFont:BebasNeue withSize:IS_IPAD ? 25 : 14];
 lblTitle.tag                = 21;
 
 [container addSubview: lblTitle];
 
 
 return container;
 }
 
 -(void)easyTableView:(EasyTableView *)easyTableView setDataForView:(UIView *)view forIndexPath:(NSIndexPath *)indexPath
 {
 ModelEffect                 *currentEffect = [filtersArray objectAtIndex:indexPath.row];
 UIImageView *img            = (UIImageView *) [view viewWithTag: 20];
 img.image                   = [UIImage imageNamed:currentEffect.icon];
 
 UILabel *lblTitle           = (UILabel *) [view viewWithTag: 21];
 lblTitle.text               = currentEffect.title;
 
 if(selectedFilter == indexPath.row){
 img.layer.borderColor = [UIColor whiteColor].CGColor;
 img.layer.borderWidth = 4.0f;
 UIView *animatedView = [[UIView alloc] initWithFrame:img.frame];
 animatedView.backgroundColor = [UIColor whiteColor];
 animatedView.alpha = 0.7;
 UIImageView *vImg = [[UIImageView alloc] initWithFrame:animatedView.frame];
 vImg.image = [UIImage imageNamed:@"ApplyV"];
 vImg.contentMode = UIViewContentModeScaleAspectFit;
 [animatedView addSubview:vImg];
 [view addSubview:animatedView];
 [UIView animateWithDuration:0.7 animations:^{
 animatedView.alpha = 0;
 }];
 }else{
 img.layer.borderWidth = 0.0f;
 }
 
 return;
 }
 
 
 -(void)easyTableView:(EasyTableView *)easyTableView selectedView:(UIView *)selectedView atIndexPath:(NSIndexPath *)indexPath deselectedView:(UIView *)deselectedView
 {
 // [[SoundManager sharedManager] playSound:beepSound];
 *
 if(indexPath.row == 0)
 {
 [videoView clearEffect];
 selectedFilter = 0;
 [tblFilters reloadData];
 
 }
 else*
 {
 [self performBlock:^{
 ModelEffect *cModel = [[DataManager sharedManager] getEffectAtIndex:indexPath.row];
 [videoView loadEffectWithModel:IS_IPAD ? cModel.layers : cModel.previewLayers];
 } afterDelay:0.1];
 
 if([videoView isRecord]){
 [self animateFiltersTable:NO];
 }
 if(state == VideoControllerVideoFromLibrary){
 [self performSelectorOnMainThread:@selector(enablePublishButtons:) withObject:[NSNumber numberWithBool:YES] waitUntilDone:NO];
 }
 
 [self animateControlsView:YES];
 selectedFilter      = indexPath.row;
 [tblFilters reloadData];
 }
 }*/
-(void)processVideo:(void (^)(void))completionBlock
{
    /*
     if(state == VideoControllerWaitingForProcess || state == VideoControllerPreview || state == VideoControllerVideoFromLibrary || state == VideoControllerProvided){
     [self setState:VideoControllerProcessing];
     [videoView processVideoWithCompleteBlock:^{
     [self setState:VideoControllerFinishedProcessing];
     completionBlock();
     }andErrorBlock:^(NSError *error) {
     //handle error
     NSLog(@"error");
     } isHalf:NO];
     }else if(state == VideoControllerFinishedProcessing)
     completionBlock();*/
}
#pragma mark - Save/Share IBOutlets

-(void)touchedSave:(id)sender{
    /*
     
     if(state == VideoControllerVideoFromLibrary || didRecordVideo){
     ModelEffect *lastModel = [[DataManager sharedManager] getEffectAtIndex:selectedFilter];
     //        [videoView loadEffectWithModel:lastModel.layers];
     //        hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES withAbortBlock:^{
     }];
     //        hud.mode = MBProgressHUDModeAnnularDeterminate;
     //        hud.labelText = @"Saving Video...";
     
     [self processVideo:^{
     // [SVProgressHUD showWithStatus:@"Saving Video..." maskType:SVProgressHUDMaskTypeGradient];
     [videoView saveVideo];
     }];
     }
     else if(!didRecordVideo){
     [UIAlertView alertViewWithTitle:nil message:@"No video has been recorded yet." cancelButtonTitle:@"OK" otherButtonTitles:nil onDismiss:nil onCancel:nil];
     }*/
}
- (void)touchedShare:(id)sender
{
    //   [[SoundManager sharedManager] playSound:beepSound];
    if(!didRecordVideo){
        [UIAlertView alertViewWithTitle:nil message:@"No video has been recorded yet." cancelButtonTitle:@"OK" otherButtonTitles:nil onDismiss:nil onCancel:nil];
    }
    else
    {
        shareView.alpha = 0.0f;
        [self.view addSubview:shareView];
        [UIView animateWithDuration:0.3 animations:^{
            shareView.alpha = 1.0;
        }];
    }
}
#pragma mark - ShareView Methods

-(void)toucheBackFromShare:(id)sender
{
    [collageView takePicture];
    /*    [UIView animateWithDuration:0.3 animations:^{
     shareView.alpha = 0.0;
     } completion:^(BOOL finished) {
     [shareView removeFromSuperview];
     }];*/
}
#pragma mark - YouTube Publish Methods
/*
 - (void)touchedYouTube:(id)sender{
 if(IS_IPAD){
 if(!didRecordVideo){
 [UIAlertView alertViewWithTitle:nil message:@"No video has been recorded yet." cancelButtonTitle:@"OK" otherButtonTitles:nil onDismiss:nil onCancel:nil];
 return;
 }
 }
 
 saveOption = VideoSaveOptionYouTube;
 [self showPublishView];
 }
 -(void)performYouTubePublish
 {
 [SVProgressHUD dismiss];
 UPDATE_DISPLAY;
 
 if(state == VideoControllerFinishedProcessing || state == VideoControllerProvided){
 __block BOOL didShowProgress = NO;
 NSString *path =  [videoView currentVideoPath];
 [self startRotatingWheels];
 [_youTubeBox uploadWithFilePath:path
 title:titleTextField.text
 andDescription:descTextField.text.length == 0 ? @"" : descTextField.text
 isPrivate:privacyButton.selected
 onProgress:^(float progress) {
 NSLog(@"progress %f", progress);
 if(!didShowProgress){
 [SVProgressHUD showWithStatus:@"Uploading..." maskType:SVProgressHUDMaskTypeGradient];
 didShowProgress = YES;
 }
 } onComplete:^(NSDictionary *info) {
 NSLog(@"Complete with url:%@", info[@"videoURL"]);
 
 [self stopRotatingWheels];
 [SVProgressHUD dismiss];
 [UIAlertView alertViewWithTitle:nil message:@"Your video is on YouTube!\nWant to watch it now?" cancelButtonTitle:@"No" otherButtonTitles:@[@"Yes"] onDismiss:^(int buttonIndex) {
 [[UIApplication sharedApplication] openURL:[NSURL URLWithString:info[@"videoURL"]]];
 } onCancel:nil];
 
 } onFailure:^(NSError *error) {
 NSLog(@"Error: %@", [error localizedDescription]);
 [self stopRotatingWheels];
 [SVProgressHUD dismiss];
 }];
 
 }
 }
 */
#pragma mark - Facebook Publish Methods
/*
 - (void)touchedFacebook:(id)sender
 {
 if(IS_IPAD){
 if(!didRecordVideo){
 [UIAlertView alertViewWithTitle:nil message:@"No video has been recorded yet." cancelButtonTitle:@"OK" otherButtonTitles:nil onDismiss:nil onCancel:nil];
 return;
 }
 }
 saveOption = VideoSaveOptionFacebook;
 [self showPublishView];
 }
 -(void)performFacebookPublish
 {
 dispatch_async(dispatch_get_main_queue(), ^{
 if(state == VideoControllerFinishedProcessing || state == VideoControllerProvided)
 {
 if (![[Dropico sharedManager] isReachable])
 {
 [UIAlertView alertViewWithTitle:@"Internet is required" message:@"The Share option is depended on\nan internet connection, please try again later." cancelButtonTitle:@"OK" otherButtonTitles:nil onDismiss:nil onCancel:nil];
 return;
 }
 
 FBSession *activeSession = FBSession.activeSession;
 if(activeSession.state != FBSessionStateOpen){
 [self doFBAuthWithCompletion:^{
 [self performFacebookPublish];
 }];
 }else{
 [self doFBShareWithCompletion:^{
 [SVProgressHUD dismiss];
 }];
 }
 }
 });
 }
 -(void)doFBAuthWithCompletion:(void (^)(void))completion{
 // i perform the following code on with dispatch_async because an expection the following exepction was  raised
 // 'FBSession: should only be used from a single thread
 
 dispatch_async(dispatch_get_main_queue(), ^{
 [FBSession openActiveSessionWithPublishPermissions:@[@"publish_stream"]
 defaultAudience: privacyButton.selected ? FBSessionDefaultAudienceOnlyMe : FBSessionDefaultAudienceEveryone
 allowLoginUI:YES
 completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
 NSLog(@"%d", FBSession.activeSession.state);
 if(error){
 [SVProgressHUD dismiss];
 if(SYSTEM_VERSION_GREATER_THAN(@"6.0")){
 [UIAlertView alertViewWithTitle:@"Please allow access for Facebook!"
 message:@"Please make sure you let VideoPlay Access your Facebook Data. \n\n If you're using the Native Facebook login, please make sure VideoPlay is 'On' under Settings->Facebook"
 cancelButtonTitle:@"OK"
 otherButtonTitles:nil
 onDismiss:nil
 onCancel:nil];
 }else{
 [UIAlertView alertViewWithTitle:@"Please allow access for Facebook!"
 message:@"Please make sure you let VideoPlay Access your Facebook Data."
 cancelButtonTitle:@"OK"
 otherButtonTitles:nil
 onDismiss:nil
 onCancel:nil];
 }
 return;
 }
 if(completion)
 completion();
 }];
 });
 }
 -(void)doFBShareWithCompletion:(void (^)(void))completion{
 dispatch_async(dispatch_get_main_queue(), ^{
 
 if (FBSession.activeSession.isOpen) {
 [SVProgressHUD showWithStatus:@"Uploading..." maskType:SVProgressHUDMaskTypeGradient];
 UPDATE_DISPLAY;
 NSString *filePath = [videoView currentVideoPath];
 NSURL *pathURL = [[NSURL alloc]initFileURLWithPath:filePath isDirectory:NO];
 NSData *videoData = [NSData dataWithContentsOfFile:filePath];
 
 NSDictionary *videoObject = @{
 @"title": titleTextField.text,
 @"description": descTextField.text.length == 0 ? @"" : descTextField.text,
 [pathURL absoluteString]: videoData
 };
 FBRequest *uploadRequest = [FBRequest requestWithGraphPath:@"me/videos"
 parameters:videoObject
 HTTPMethod:@"POST"];
 
 [uploadRequest startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
 if (!error)
 NSLog(@"Done: %@", result);
 else
 NSLog(@"Error: %@", error.localizedDescription);
 
 [self touchedClosePublish:nil];
 [SVProgressHUD dismiss];
 }];
 }
 });
 }
 */
#pragma mark - Video Start/Stop Methods


-(void)touchedRecordButton:(id)sender
{
    if (isRecord)
    {
        NSLog (@"Stop recrod");
        [collageView stopRecord];
    }
    else
    {
        NSLog (@"Start recrod");
        [collageView startRecord];
    }
    isRecord = !isRecord;
    /*    if([videoView isRecord]){
     return;
     }else{
     didSaveVideo = NO;
     [videoView startRecord];
     [self setState:VideoControllerStateRecording];
     
     // if device is under iPhone 4 then the blinking red button should be called every 1 sec
     NSArray     *devicesNotSupported = @[@"iPhone 2G",@"iPhone 3G",@"iPhone 3GS",@"iPhone 4 (GSM)",@"iPhone 4",@"iPhone 4 (CDMA)",@"iPod Touch (1st Gen)",@"iPod Touch (2nd Gen)",@"iPod Touch (3rd Gen)",@"iPod Touch (4th Gen)"];
     if([devicesNotSupported containsObject:[DropicoUtils deviceType]]){
     animationTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self  selector:@selector(recordAnimation) userInfo:nil repeats:YES];
     [animationTimer fire];
     }else {
     recButtonImg.alpha = 1.0f;
     [UIView animateWithDuration:0.5
     delay:0.0
     options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse | UIViewAnimationOptionAllowUserInteraction
     animations:^{
     recButtonImg.alpha = 0.0f;
     }completion:nil];
     }
     }*/
}
-(void)recordAnimation
{
    [UIView animateWithDuration:0.05 animations:^{
        recButtonImg.alpha = recButtonImg.alpha == 0 ? 1 : 0;
    }];
}
-(void)touchedStopButton
{
    /*    if(state == VideoControllerPreview)
     {
     [self setState:VideoControllerStateNone];
     return;
     }
     else if(state == VideoControllerStateRecording)
     {
     [videoView stopRecord];
     didRecordVideo = YES;
     [self setState:VideoControllerProcessing];
     
     hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES withAbortBlock:^{
     }];
     hud.mode = MBProgressHUDModeAnnularDeterminate;
     hud.labelText = @"Processing Video...";
     hud.progress = 0;
     
     ModelEffect *lastModel = [[DataManager sharedManager] getEffectAtIndex:selectedFilter];
     [videoView loadEffectWithModel:lastModel.layers];
     [videoView processVideoWithCompleteBlock:^{
     dispatch_async(dispatch_get_main_queue(), ^{
     [hud hide:YES];
     UPDATE_DISPLAY;
     });
     [videoView setDisplay:YES];
     [videoView loadVideoWithPath:videoView.currentVideoPath];
     [self setState:VideoControllerPreview];
     } andErrorBlock:^(NSError *error) {
     } isHalf:YES];
     }
     else {
     [UIView animateWithDuration:0.4 animations:^{
     recButtonImg.superview.width = IS_IPAD ? 60 : 40;
     }];
     
     }*/
}
#pragma mark - StartOver
-(IBAction)touchedStartOverButton:(id)sender{
    if(didSaveVideo == NO){
        [UIAlertView alertViewWithTitle:nil message:@"You haven't save your work.\nWould you like to save now?" cancelButtonTitle:@"No" otherButtonTitles:@[@"Yes"]
                              onDismiss:^(int buttonIndex) {
                                  [self touchedSave:nil];
                              } onCancel:^{
                                  didSaveVideo = YES;
                                  [self touchedStartOverButton:nil];
                              }];
        return;
    }
    //    [tblFilters reloadData];
    [self setState:VideoControllerStateNone];
}
#pragma mark - PublishView Methods
/*
 -(IBAction)touchedUploadButton:(id)sender
 {
 
 if(titleTextField.text.length == 0){
 [UIAlertView alertViewWithTitle:nil message:@"You haven't write title for you video" cancelButtonTitle:@"OK" otherButtonTitles:nil onDismiss:nil onCancel:nil];
 return;
 }
 ModelEffect *lastModel = [[DataManager sharedManager] getEffectAtIndex:selectedFilter];
 [videoView loadEffectWithModel:lastModel.layers];
 [self processVideo:^{
 
 if(saveOption == VideoSaveOptionFacebook){
 [self performFacebookPublish];
 }else if(saveOption == VideoSaveOptionYouTube){
 [self performSelectorOnMainThread:@selector(performYouTubePublish) withObject:nil waitUntilDone:NO];
 }
 }];
 }
 -(void)showPublishView{
 titleTextField.text = @"";
 descTextField.text  = @"";
 UIView      *innerView = [publishView viewWithTag:10];
 innerView.y =  -150;
 publishView.alpha = 0.0;
 [self.view addSubview:publishView];
 [UIView animateWithDuration:0.5 animations:^{
 publishView.alpha  = 1.0;
 } completion:^(BOOL finished) {
 [titleTextField becomeFirstResponder];
 [UIView animateWithDuration:0.8 animations:^{
 innerView.y = 0;
 }];
 }];
 }
 -(IBAction)privacyButtonPressed:(id)sender{
 privacyButton.selected = !privacyButton.selected;
 }
 */
/*
 Show/Hide the Record/Stop buttons while recording
 */
-(void)animateControlsView:(BOOL)show
{
    if(state == VideoControllerVideoFromLibrary)
        return;
    if([controlView isHidden])
    {
        controlView.hidden = NO;
        tapToRecord.hidden = NO;
    }
    [UIView animateWithDuration:1 animations:^{
        controlView.alpha =  show ? 1.0 : 0.3;
    } completion:^(BOOL finished) {
    }];
}
/*
 Show/Hide the Filters Scroller while recording
 */
-(void)animateFiltersTable:(BOOL)show
{
    /*    tblFilters.userInteractionEnabled = show;
     [UIView animateWithDuration:1 animations:^{
     tblFilters.alpha =  show ? 1.0 : 0.3;
     } completion:^(BOOL finished) {
     }];*/
}
- (void)touchedClosePublish:(id)sender
{
    [UIView animateWithDuration:0.5 animations:^{
        publishView.alpha = 0;
    } completion:^(BOOL finished) {
        [publishView removeFromSuperview];
    }];
}

- (void) video: (NSString *) videoPath didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo
{
    [saveSem signal];
}

-(void)touchedStartButton:(id)sender
{
    [collageView loadCollageWithArray:nil];
    
    [collageView setDisplay:NO];
    [collageView processCollageWithCompleteBlock:^{
        [saveSem purge];
        UISaveVideoAtPathToSavedPhotosAlbum([collageView currentVideoPath], self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
        [saveSem wait:90000.];
        [collageView setDisplay:YES];
        //            completionBlock();
    }andErrorBlock:^(NSError *error) {
        //handle error
        NSLog(@"error");
    } isHalf:NO];
    /*    if(state == VideoControllerWaitingForProcess || state == VideoControllerPreview || state == VideoControllerVideoFromLibrary || state == VideoControllerProvided){
     [self setState:VideoControllerProcessing];
     [collageView processCollageWithCompleteBlock:^{
     [self setState:VideoControllerFinishedProcessing];
     //            completionBlock();
     }andErrorBlock:^(NSError *error) {
     //handle error
     NSLog(@"error");
     } isHalf:NO];
     }//else if(state == VideoControllerFinishedProcessing)
     //        completionBlock();*/
}

#pragma mark - Timer Methods

-(NSString*)prettifySeconds:(int)seconds
{
    // Return variable.
    NSString *result = @"";
    
    // Int variables for calculation.
    int secs = seconds;
    int tempHour    = 0;
    int tempMinute  = 0;
    int tempSecond  = 0;
    
    NSString *hour      = @"";
    NSString *minute    = @"";
    NSString *second    = @"";
    
    // Convert the seconds to hours, minutes and seconds.
    tempHour    = secs / 3600;
    tempMinute  = secs / 60 - tempHour * 60;
    tempSecond  = secs - (tempHour * 3600 + tempMinute * 60);
    
    hour    = [[NSNumber numberWithInt:tempHour] stringValue];
    minute  = [[NSNumber numberWithInt:tempMinute] stringValue];
    second  = [[NSNumber numberWithInt:tempSecond] stringValue];
    
    // Make time look like 00:00:00 and not 0:0:0
    if (tempHour < 10) {
        hour = [@"0" stringByAppendingString:hour];
    }
    
    if (tempMinute < 10) {
        minute = [@"0" stringByAppendingString:minute];
    }
    
    if (tempSecond < 10) {
        second = [@"0" stringByAppendingString:second];
    }
    
    if (tempHour == 0) {
        result = [NSString stringWithFormat:@"00.%@.%@", minute, second];
        
    } else {
        result = [NSString stringWithFormat:@"%@.%@.%@",hour, minute, second];
    }
    
    return result;
}
-(void)updateTimer:(NSString*)time
{
    [timerLabel setText:time];
}
-(void)dismissProgress
{
    //    [SVProgressHUD dismiss];
}
#pragma mark - DMVideoView Delegates
- (void)DMCollageViewFrameTimeUpdate:(NSNumber *)time
{
    [self performSelectorOnMainThread:@selector(updateTimer:) withObject:[self prettifySeconds:time.integerValue] waitUntilDone:NO];
}

- (void)DMCollageViewProgressUpdate:(CGFloat)progress
{
    //    hud.progress = progress;
}
- (void)DMCollageViewDidFinishWithError:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        //        [hud hide:YES];
        UPDATE_DISPLAY;
    });
    if(!error){
        saveButton.enabled = NO;
        //        [videoView loadLastVideo];
    }
    [collageView setDisplay:YES];
    [self setState:VideoControllerProvided];
    didSaveVideo = YES;
    //    [SVProgressHUD dismiss];
    //    [tblFilters reloadData];
    [self touchedStartOverButton:nil];
}

@end
