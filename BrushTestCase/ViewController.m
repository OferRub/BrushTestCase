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
    saveOption = VideoSaveOptionGallery;
    [self setState:VideoControllerStateNone];
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
#pragma mark - Video Start/Stop Methods
-(void)recordAnimation
{
    [UIView animateWithDuration:0.05 animations:^{
        recButtonImg.alpha = recButtonImg.alpha == 0 ? 1 : 0;
    }];
}

#pragma mark - PublishView Methods

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
}

@end
