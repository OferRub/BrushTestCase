//
//  MainView.h
//  MotionFX
//
//  Created by Nadav on 5/28/13.
//  Copyright (c) 2013 Dropico Media LTD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DMCollageView.h"
//#import "EasyTableView.h"

#define RGBA(R,G,B,A)   [UIColor colorWithRed:(float) R/255 green:(float) G/255 blue:(float) B/255 alpha: A]

@interface ViewController : UIViewController <UIScrollViewDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    IBOutlet    DMCollageView * collageView;
}

@end
