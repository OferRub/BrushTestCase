//
//  SplashView.m
//  MotionFX
//
//  Created by Nadav on 5/28/13.
//  Copyright (c) 2013 Dropico Media LTD. All rights reserved.
//

#import "SplashView.h"
#import <Dropico/Dropico.h>
@interface SplashView ()

@end

@implementation SplashView

- (id)init
{
    self = [super initWithNibName:@"SplashView" bundle:nil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    if(IS_IPHONE_5)
//        [(UIImageView*)[self.view viewWithTag:1111] setImage:[UIImage imageNamed:@"Default-568h-landscape.png"]];
    
   
    
    [[AppManager sharedAppManager] setup];
    
        //[self setStatus:@"Done, and now... starting."];
        [self performBlock:^{
            [[AppManager sharedAppManager] gotoMainView];
        } afterDelay:2];   
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

@end
