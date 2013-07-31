//
//  DMVideoView.m
//  MotionFX
//
//  Created by Ofer Rubinstein on 5/22/13.
//  Copyright (c) 2013 Dropico Media LTD. All rights reserved.
//

#import "DMCollageView.h"
#import "DMView.h"
#import "DMBrush.h"
#import <Dropico/Dropico.h>
#import "DMTexture+Extra.h"


@interface DMCollageView()
{
    DMTexture * background;
    DMBrushNode * currentErase;
    DMTexture * texture1;
    DMView        * view1;

    CGRect         gRenderRect;
    DMBrush * brush;
}

- (void)setup;

@property (nonatomic,  copy) void (^onProcessComplete)(void);
@property (nonatomic, copy) void (^onProcessFailed)(NSError *error);

@end

@implementation DMCollageView

- (void)setup
{
    [[DMGraphics manager] DMGSetup];
    [DMGraphics manager].delegate = self;
    CADisplayLink * mFrameLink = [CADisplayLink displayLinkWithTarget:self
                                                             selector:@selector(doFrame:)];
    [mFrameLink setFrameInterval:1];
    [mFrameLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    
    self.delegate = self;
    self.drawableDepthFormat = GLKViewDrawableDepthFormat16;
    self.drawableStencilFormat = GLKViewDrawableStencilFormat8;
    self.context = [[DMGraphics manager] factory]->context;
    
    gRenderRect = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
}

#pragma mark - inner functions
-(void) doFrame:(id)data
{
    [self update];
        
    [self display];
}

- (id)init
{
    self = [super init];
    if (self)
    {
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self setup];
    }
    
    return self;
}

- (BOOL)update
{
    BOOL b = YES;
    return b;
}

+ (void) removeFile:(NSURL *)fileURL
{
    NSString *filePath = [fileURL path];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filePath]) {
        NSError *error;
        if ([fileManager removeItemAtPath:filePath error:&error] == NO) {
            NSLog(@"removeItemAtPath %@ error:%@", filePath, error);
        }
    }
}


-(void)DMGraphicsDidEnterToBackground
{
}

-(void)DMGraphicsDidEnterToForeground
{
}


double gRetinaFactor = 2.0;
- (void)renderView: (GLKView *)view
{
    if (view1 == nil)
        view1 = [[DMView alloc] init];
    
    CGRect viewRect = CGRectMake(0, 0, [view drawableWidth], [view drawableHeight]);

    gRenderRect = viewRect;
    [view1 setView:view viewRect:gRenderRect];
    if (brush==nil)
    {
        brush = [[DMBrush alloc] init];
        [brush setColor:DMMakeColor(1.0, 1.0, 0.5)];
    }
    if (!background)
    {
        background = [[[DMGraphics manager] factory] loadImageWithPath:[[NSBundle mainBundle] pathForResource:@"Valley_Oahu" ofType:@"ppng"]];
        [background load];
        [brush setBackground:background];
    }
    if (currentErase)
    {
//        [brush clear: texture1 withBackground:background];
    }
    else
    {
        if (!texture1)
            texture1 = [[[DMGraphics manager] factory] createTarget:viewRect.size.width*gRetinaFactor/2.0 height:viewRect.size.height*gRetinaFactor/2.0];
        [brush renderBrushForTarget:texture1];
    }
    if (texture1)
        [view1 presentTexture:texture1 withView:view andRect:gRenderRect];
    else
        [texture1 clearWhite];
}

double lastTouch = 0.0;

- (void) touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
    if ([touches count]==1)
        currentErase = nil;
    if (currentErase)
        return;
    lastTouch = event.timestamp;
    if ([touches count]>1)
    {
        int i = 0;
        CGPoint point = CGPointZero;
        for (UITouch *touch in touches) {
            point.x += [touch locationInView:self].x;
            point.y += [touch locationInView:self].y;
            i++;
        }
        point.x/=(float)i;
        point.y/=(float)i;
        DMBrushNode * n = [DMBrushNode new];
        n->position = point;
        currentErase = n;
        return;
    }
    CGPoint point = [ [touches anyObject] locationInView:self];
    point.x*=gRetinaFactor;
    point.y*=gRetinaFactor;

    [brush drawStroke:(DMBrushStrokeData){point, 1.0/60.0}];
}

- (void) touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event
{
    if (currentErase)
        return;
    if ([touches count]>1)
    {
        lastTouch = event.timestamp;
        int i = 0;
        CGPoint point = CGPointZero;
        for (UITouch *touch in touches) {
            point.x += [touch locationInView:self].x;
            point.y += [touch locationInView:self].y;
            i++;
        }
        point.x/=(float)i;
        point.y/=(float)i;
        DMBrushNode * n = [DMBrushNode new];
        n->position = point;
        currentErase = n;
        return;
    }
    CGPoint point = [ [touches anyObject] locationInView:self];
    point.x*=gRetinaFactor;
    point.y*=gRetinaFactor;
    double delta = event.timestamp-lastTouch;
    lastTouch = event.timestamp;
    [brush drawStroke:(DMBrushStrokeData){point, delta}];
}


- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (currentErase)
        return;
    if ([touches count]>1)
    {
        lastTouch = event.timestamp;
        int i = 0;
        CGPoint point = CGPointZero;
        for (UITouch *touch in touches) {
            point.x += [touch locationInView:self].x;
            point.y += [touch locationInView:self].y;
            i++;
        }
        point.x/=(float)i;
        point.y/=(float)i;
        DMBrushNode * n = [DMBrushNode new];
        n->position = point;
        currentErase = n;
        return;
    }
    CGPoint point = [ [touches anyObject] locationInView:self];
    point.x*=gRetinaFactor;
    point.y*=gRetinaFactor;
    double delta = event.timestamp-lastTouch;
    lastTouch = event.timestamp;
    [brush drawStroke:(DMBrushStrokeData){point, delta}];
    [brush endDrawing];
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    [self renderView:view];
}

- (void)tearDownGL
{
    [[DMGraphics manager] DMGRelease];
}

- (void)dealloc
{
    [self tearDownGL];
}



#pragma mark - interface

- (void) removeFile:(NSURL *)fileURL
{
    NSString *filePath = [fileURL path];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filePath]) {
        NSError *error;
        if ([fileManager removeItemAtPath:filePath error:&error] == NO) {
            NSLog(@"removeItemAtPath %@ error:%@", filePath, error);
        }
    }
}
@end
