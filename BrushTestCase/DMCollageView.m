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
    NSMutableArray * transitionList;
    NSMutableArray * time1List, * time2List;
    double * durationList;
    DMTexture * texture1;
    DMView        * view1;

    double startLength, globalLength;
    double prevTime1, prevTime2;
    BOOL off, off2;
    unsigned int index, index2;
    double         lastFrameRecord;
    double         filterStart;
    CFTimeInterval previousTimestamp;
    unsigned int   logCount;
    double         timeSum[30];
    double         sum;
    CGRect         gRenderRect;
    BOOL           isPost;
    CMTime         keepStartTime;
    BOOL           isDisplay;
    BOOL           _isHalfRes;
    unsigned int   isNext;
    BOOL rotate;
    NSLock * loadMutex;
    unsigned int resumeCount, lastResumeCount;
    CGSize _crop;
    BOOL lastHalf;
    BOOL isPostProcess;
    BOOL isRecord;
    unsigned int movieCount;
    DMBrush * brush;
}

- (void)setup;

@property (nonatomic,  copy) void (^onProcessComplete)(void);
@property (nonatomic, copy) void (^onProcessFailed)(NSError *error);

@end

@implementation DMCollageView

- (void)setup
{
    startLength = 0;
    globalLength = 0;
    index = 0;
    index2 = 0;
    movieCount=0;
    _isHalfRes = NO;
    logCount        = 0;
    sum             = 0;
    isPost          = NO;
    keepStartTime   = (CMTime){0, 1};
    isNext          = 0;
    isDisplay       = NO;
    
    durationList = NULL;
    loadMutex = [NSLock new];
    rotate = NO;
    
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
    
/*    if (dmc==nil)
    {
        NSString *device= [DropicoUtils deviceType];
        
            dmc = [[DMCamera alloc] initWithDelegate:self
                                            withInfo: self
                                              preset:AVCaptureSessionPreset1280x720
                                                crop:CGRectMake(0., 0., 1280., 720.)];
    }*/

}

#pragma mark - inner functions
-(void) doFrame:(id)data
{
//    if (isDisplay && !isPost)
    {
        [self update];
        
        [[[DMGraphics manager] factory] displayLock];
        [self display];
        [[[DMGraphics manager] factory] displayUnlock];
    }
#warning No need to sleep in main thread?
    //    else
    //        [NSThread sleepForTimeInterval:0.1];
}

- (id)init
{
    self = [super init];
    if (self)
    {
        lastHalf = NO;
        resumeCount = 0;
        lastResumeCount = 0;
        isPostProcess = NO;       
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

- (void)setDisplay:(BOOL)enable
{
    isDisplay = enable;
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
//unsigned int lastIndex = 0;
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

float scaleArray[5];
unsigned int scaleAmount = 0, maxScale = 5, scaleIndex = 0;
double lastTouch = 0.0;
double touchDelta = 0.0;
unsigned int maxTouch = 5;
BOOL isTouchEnd = NO;
- (void) touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
    if ([touches count]==1)
        currentErase = nil;
    if (currentErase)
        return;
    isTouchEnd = NO;
    touchDelta = 0.0;
    lastTouch = event.timestamp;
    scaleAmount = 0;
    scaleIndex = 0;
    for (unsigned int i=0; i<maxScale; i++)
        scaleArray[i] = 0.0f;
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
        scaleAmount = 0;
        scaleIndex = 0;
        for (unsigned int i=0; i<maxScale; i++)
            scaleArray[i] = 0.0f;
        touchDelta = 0.0;
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
        scaleAmount = 0;
        scaleIndex = 0;
        for (unsigned int i=0; i<maxScale; i++)
            scaleArray[i] = 0.0f;
        touchDelta = 0.0;
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
