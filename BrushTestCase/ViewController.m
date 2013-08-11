//
//  ViewController2.m
//  BrushTestCase
//
//  Created by Ofer Rubinstein on 8/6/13.
//  Copyright (c) 2013 Ofer Rubinstein. All rights reserved.
//

#import "ViewController.h"
#import "DMBrushView.h"
#import "KZColorPicker.h"

@interface ViewController ()
 KZColorPicker *picker
@end

@implementation ViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        KZColorPicker *picker = [[KZColorPicker alloc] initWithFrame:container.bounds];
        picker.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        picker.selectedColor = self.selectedColor;
        picker.oldColor = self.selectedColor;
        [picker addTarget:self action:@selector(pickerChanged:) forControlEvents:UIControlEventValueChanged];
        [self.view addSubview:picker];

        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)touchInk:(id)sender
{
    //[collageView loadBrushWithType:DMBrushTypeInk];
}

-(IBAction)touchTouche:(id)sender
{
    //[collageView loadBrushWithType:DMBrushTypeTouche];
}

-(IBAction)touchSpray:(id)sender
{
  //  [collageView loadBrushWithType:DMBrushTypeSpray];
}


- (void)showPicker
{
    
}




@end
