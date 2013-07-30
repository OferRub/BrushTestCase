//
//  AppManager.m
//  MotionFX
//
//  Created by Nadav on 5/27/13.
//  Copyright (c) 2013 Dropico Media LTD. All rights reserved.
//

#import "AppManager.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "SplashView.h"

#define APP_VERSION_KEY     @"VideoAppVersion"

static AppManager *_instance = nil;
NSUserDefaults    *userDefaults;
@interface AppManager()
{
//    DMImagePicker  *_browsePicker;
    UIPopoverController      *_popover;
}
@property (nonatomic, strong) SplashView *splashView;
@property (nonatomic, strong) UINavigationController *navController;

@end
@implementation AppManager
@synthesize splashView,navController;

+ (AppManager *)sharedAppManager {
    @synchronized(self) {
        if (_instance == nil){
            _instance = [[self allocWithZone:nil] init];
        }
    }
    return _instance;
}

- (UIViewController *)runApplication
{
    userDefaults = [NSUserDefaults standardUserDefaults];
    
    self.splashView = [[SplashView alloc] init];
    self.navController = [[UINavigationController alloc] initWithRootViewController:self.splashView];
    [self.navController setNavigationBarHidden:YES];

    
    return [self navController];
}

- (void)setup
{
    [self setupDMGraphics];
    [self setupDataManager];
}

- (void)setupDataManager
{
 }


- (void)setupDMGraphics
{
    [[DMGraphics manager] DMGSetup];
}




#pragma mark - Image Picker Handlers

- (void)gotoMainView
{
    if(self.mainView == nil)
        self.mainView = [[ViewController alloc] init];
    
    [self.navController pushViewController:self.mainView animated:YES];

}
#pragma mark - Social Servies

- (void)initSocialBrowserWithCompleteBlock:(void (^)(void))completionBlock
                                   onError:(void (^)(NSError *))errorBlock
{
    /*
    if (![[MFXUser user] hasServiceListReady]) {
        [DropicoServices getServices:kServiceFilterFlagAll
                             success:^(DropicoResponse *serviceResponse) {
                                 
                                 NSMutableArray *connectedServices = [[NSMutableArray alloc] init];
                                 [[DMSocialBrowser sharedSocialBrowser] fetchServicesWithResponse:serviceResponse];
                                 
                                 [serviceResponse.response enumerateObjectsUsingBlock:^(DropicoService *service, NSUInteger idx, BOOL *stop) {
                                     if ([service isConnected]) {
                                         [connectedServices addObject:service];
                                     }
                                 }];
                                 
                                 [[[Dropico sharedManager] privateCache] setObject:connectedServices forKey:kServiceCache];
                                 
                                 [[MFXUser user] setHasServiceListReady:YES];
                                 if (completionBlock != nil) {
                                     completionBlock();
                                 }
                                 
                             }
         //Fail getting services
                             failure:^(NSURLRequest *request, DropicoResponse *response, NSError *error) {
                                 DropicoLogDebug(@"Fail getting services. Response: %@",response);
                                 
                                 if (errorBlock != nil) {
                                     errorBlock(error);
                                 }
                                 
                             }];
    }
    else
    {
        if (completionBlock != nil) {
            completionBlock();
        }
    }
     */
}
/*
- (UIImagePickerController *)browsePhotos
{
    return [self browsePhotosWithDelegate:self];

}*/
/*
- (UIImagePickerController *)browsePhotosWithDelegate:(id)delegate
{
    if (_browsePicker == nil)
    {
        _browsePicker = [[DMImagePicker alloc] init];
        _browsePicker.delegate = delegate;
        _browsePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        _browsePicker.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *)kUTTypeMovie,nil];
        _browsePicker.allowsEditing = NO;
        _browsePicker.videoQuality = UIImagePickerControllerQualityTypeHigh;
    }

    if(!IS_IPAD)
    {
        [navController presentModalViewController:_browsePicker animated:YES];
    }
    
    return _browsePicker;

}*/
- (void)popoverPicker:(UIViewController *) picker forView:(UIView *)aView withRect:(CGRect)aRect
{
    if(!IS_IPAD)
        return;
    if ( picker != [_popover contentViewController])
        _popover = [[UIPopoverController alloc] initWithContentViewController:picker];
    
    
    //[_popover setPopoverBackgroundViewClass:[KSCustomPopoverBackgroundView class]];
    [_popover presentPopoverFromRect:aRect inView:aView permittedArrowDirections:UIPopoverArrowDirectionLeft animated:NO];

}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    NSLog(@"imagePickerControllerDidCancel");
    [picker dismissModalViewControllerAnimated:YES];
}

@end
