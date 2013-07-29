//
//  AppManager.h
//  MotionFX
//
//  Created by Nadav on 5/27/13.
//  Copyright (c) 2013 Dropico Media LTD. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "SplashView.h"
#import "ViewController.h"
//#import "DMImagePicker.h"

#define IS_IPAD     (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE_5  ( !IS_IPAD && ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON ) )
#define UPDATE_DISPLAY [[NSRunLoop currentRunLoop] runMode: NSDefaultRunLoopMode beforeDate: [NSDate date]]

@interface AppManager : NSObject <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic,strong) ViewController   *mainView;
+ (AppManager *) sharedAppManager;

- (UIViewController *) runApplication;
- (void) setup;
- (void)gotoMainView;
//- (DMImagePicker *)browsePhotos;
//- (DMImagePicker *)browsePhotosWithDelegate:(id)delegate;
- (void)popoverPicker:(UIViewController *) picker forView:(UIView *)aView withRect:(CGRect)aRect;

@end
