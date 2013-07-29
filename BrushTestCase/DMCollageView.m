//
//  DMVideoView.m
//  MotionFX
//
//  Created by Ofer Rubinstein on 5/22/13.
//  Copyright (c) 2013 Dropico Media LTD. All rights reserved.
//

#import "DMCollageView.h"
#import "DMBaseElement.h"
#import "DMBrush.h"
#import <Dropico/Dropico.h>
#import "DMTexture+Extra.h"


@interface DMCollageView()
{
    DMTexture * giant, * background;
    NSMutableArray * currentStroke;
    DMBrushNode * currentErase;
    NSMutableArray * transitionList;
    NSMutableArray * videoList;
    NSMutableArray * time1List, * time2List;
    double * durationList;
    DMTexture * texture1;
    DMView        * view1;
    DMBaseElement *processCopy;

    double startLength, globalLength;
    double prevTime1, prevTime2;
    BOOL off, off2;
    unsigned int index, index2;
    double         lastFrameRecord;
    double         filterStart;
    CMTime         countTime;
    CFTimeInterval previousTimestamp;
    BOOL           isFirstTime;
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
@synthesize currentVideoPath = _currentVideoPath;

- (void)setup
{
    startLength = 0;
    globalLength = 0;
    index = 0;
    index2 = 0;
    movieCount=0;
    _isHalfRes = NO;
    isFirstTime     = YES;
    logCount        = 0;
    sum             = 0;
    isPost          = NO;
    keepStartTime   = (CMTime){0, 1};
    isNext          = 0;
    isDisplay       = NO;
    
    durationList = NULL;
    loadMutex = [NSLock new];
    rotate = NO;
    
    countTime = CMTimeMake (0, 1);
    
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
        if ([self update])
        {
//            if (greenscreenVideo)
//                [greenscreenVideo tryReadNext:1.];
        }
        
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
- (void)setDisplay:(BOOL)enable
{
    isDisplay = enable;
}

- (BOOL)update
{
    BOOL b = YES;
    return b;
}

+ (void) clearTempFiles
{
/*    NSString * path = [NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), @"output.mov"];
    NSString * prePath = [NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), @"process.mov"];
    NSString * outputPath = [NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), @"processResume.mov"];
    [DMVideoView removeFile:[NSURL fileURLWithPath:path]];
    [DMVideoView removeFile:[NSURL fileURLWithPath:prePath]];
    [DMVideoView removeFile:[NSURL fileURLWithPath:outputPath]];
    path = [NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), @"export.mov"];
    prePath = [NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), @"processHalf.mov"];
    outputPath = [NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), @"processResumeHalf.mov"];
    [DMVideoView removeFile:[NSURL fileURLWithPath:path]];
    [DMVideoView removeFile:[NSURL fileURLWithPath:prePath]];
    [DMVideoView removeFile:[NSURL fileURLWithPath:outputPath]];*/
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

-(void)processVideoError:(NSString *)errorText
{
    if (self.onProcessFailed)
    {
        NSError *error = [NSError errorWithDomain:errorText code:400 userInfo:nil];
        self.onProcessFailed(error);
    }
}
- (void)finishedProcessVideo:(BOOL)complete
{
//    _currentVideoPath = [DMVideo lastProcessPath];
    if (self.onProcessComplete && complete)
        self.onProcessComplete();
    if (self.onProcessFailed && !complete)
    {
        NSError *error = [NSError errorWithDomain:@"App is in background, processing paused" code:400 userInfo:nil];
        self.onProcessFailed(error);
    }
    
    isPost = !complete;
}

- (void)skipProcessTo:(CMTime)time
{
}


-(void)recordTimeStamp:(double)time delta:(double)delta
{
    
}


double gRetinaFactor = 2.0;
unsigned int lastIndex = 0;
- (void)renderView: (GLKView *)view
{
//    if (![[[DMGraphics manager] factory:YES] sleepTryLock])
//        return;
    if (view1 == nil)
    {
        view1 = [[DMView alloc] init];
        previousTimestamp = CFAbsoluteTimeGetCurrent();
    }
    {
//        if (isNext>0)
        {
//            [[[DMGraphics manager] factory] lock];
//            [view bindDrawable];
//            [[[DMGraphics manager] factory] unlock];
            CFTimeInterval currentDuration = CFAbsoluteTimeGetCurrent();
            if (isFirstTime)
            {
                for (unsigned int i=0; i<30; i++)
                    timeSum[i] = 0;
            }
            sum-=timeSum[logCount];
            timeSum[logCount] = (currentDuration-previousTimestamp)*1000.0;
            sum+=timeSum[logCount];
            logCount++;
            logCount%=30;
            //          if (logCount==0)
            //               NSLog (@"Frame: %f", sum/30.0);
            if (!isFirstTime)
                countTime = CMTimeAdd(countTime, CMTimeMake((currentDuration-previousTimestamp)*1000.0, 1000));
            isFirstTime = NO;

            previousTimestamp = currentDuration;
            
            CGRect viewRect = CGRectMake(0, 0, [view drawableWidth], [view drawableHeight]);

            gRenderRect = viewRect;
            [view1 setView:view viewRect:gRenderRect];
            if (brush==nil)
            {
//                giant = [[[DMGraphics manager] factory] loadImageWithPath:[[NSBundle mainBundle] pathForResource:@"Brush2" ofType:@"ppng"]];
//                [giant load];
//                giant = [[[DMGraphics manager] factory] loadImageWithPath:[[NSBundle mainBundle] pathForResource:@"Valley_Oahu" ofType:@"ppng"] withArchivePath:nil];
                brush = [[DMBrush alloc] init:giant];
            }
 /*           if (processCopy==nil)
            {
                giant = [[[DMGraphics manager] factory] loadImageWithPath:[[NSBundle mainBundle] pathForResource:@"giant" ofType:@"pvr"] withArchivePath:nil];
                DMBaseElement * first = [[DMBaseElement alloc] initWithBlendArray:@[giant, @(DMBlendModeNormal)] withRect:CGRectZero isAlpha:YES instances: 1];
                [first load];
                processCopy = [[DMBaseElement alloc] initWithTextureArray:@[first]];
//                processCopy = [[DMBaseElement alloc] initWithBlendArray:@[giant, @(DMBlendModeAdd)] isMain:YES withRect:CGRectZero];
            }
//                processCopy = [[DMBaseElement alloc] initWithLayerArray:@[[[NSBundle mainBundle] pathForResource:@"giant" ofType:@"pvr"], @(DMBlendModeNormal)] isMain:YES];
            [processCopy load];
            [processCopy processBrushWithView:view1 source:nil position:currentStroke rotation:0 scaledSize:CGSizeMake(70, 70) viewRect:viewRect];
*            [processCopy setOverlay:giant atIndex:0];
            //            [processCopy processScreen:nil view:view viewportRect:viewRect isRotate:YES];
            //            [processCopy setFlipX:YES];
            [processCopy setFlipX:YES];
            [processCopy processWithView:view1 andTexture:nil position:CGPointMake(0, 0) rotation:M_PI scaledSize:CGSizeMake(700, 700) viewRect:gRenderRect];
            [processCopy setOverlay:nil  atIndex:0];*
         
            //            [processCopy processWithView:view1 andTexture:(DMTexture *)(dmv?dmv:dmc) position:CGPointMake(0, 0) rotation:0 scaledSize:CGSizeMake(700, 700) viewRect:gRenderRect isRotate:NO];
            isNext--;
            [view1 present:view withRect:viewRect];*/
            //            [view1 presentTexture:(DMTexture *)(dmv?dmv:dmc) withView:view andRect:viewRect isRotate:NO];
            if (!background)
            {
                background = [[[DMGraphics manager] factory] loadImageWithPath:[[NSBundle mainBundle] pathForResource:@"Valley_Oahu" ofType:@"ppng"]];
                [background load];
            }
            if (currentErase)
            {
                currentStroke = [NSMutableArray new];
                [brush clear: texture1 withBackground:background];
//                [texture1 clearWhite];
            }
            else
            {
                if ([currentStroke count]>=5 && [currentStroke count]>lastIndex+1)
                {
                    if (!texture1)
                        texture1 = [[[DMGraphics manager] factory] createTarget:viewRect.size.width*gRetinaFactor/2.0 height:viewRect.size.height*gRetinaFactor/2.0];
                    NSMutableArray * trimmed = [NSMutableArray array];
                    unsigned int startIndex = lastIndex;
//                    NSLog (@"%d, %d, %d", startIndex, MAX(lastIndex, 2)-2, [currentStroke count]);
                    for (unsigned int i=MAX(lastIndex, 2)-2; i<[currentStroke count]; i++)
                    {
                        [trimmed addObject:currentStroke[i]];
                        lastIndex = i;
                    }
    //                NSLog (@"**************************************");
    //                CGPoint p1 = ((DMBrushNode *)currentStroke[lastIndex-1])->position;
    //                CGPoint p2 = ((DMBrushNode *)currentStroke[lastIndex])->position;
    //                CGPoint p3 = ((DMBrushNode *)currentStroke[lastIndex+1])->position;
    //                CFTimeInterval t2 = ((DMBrushNode *)currentStroke[lastIndex])->time;
    //                double delta = ((DMBrushNode *)currentStroke[lastIndex+1])->delta;

    //                NSLog (@"%d, %d", [currentStroke count], lastIndex);
                    BOOL isFirst = YES;
                    CGPoint p1 = ((DMBrushNode *)currentStroke[startIndex])->position;
                    CGPoint p2 = ((DMBrushNode *)currentStroke[lastIndex])->position;
                    unsigned int Count = 0;
                    float s = 0;
                    for (unsigned int i=MAX(startIndex, 7)-7; i<lastIndex; i++)
                    {
                        CGPoint p1 = ((DMBrushNode *)currentStroke[i])->position;
                        CGPoint p2 = ((DMBrushNode *)currentStroke[i+1])->position;
                        double delta2 = 0.0;
                        delta2 = ((DMBrushNode *)currentStroke[i])->delta;
                        float s1 = [DMBrush calculateScale:p1 current:p2 delta:delta2];
                        s+=s1;
                        Count++;
                    }
                    s = s/(double)Count;
                    //                    float s = [DMBrush calculateScale:p1 current:p2 delta:delta2];
                    for (unsigned int i=startIndex+1; i<=lastIndex; i++)
                    {
      /*                  if (i>=3)
                        {
                            scaleArray[scaleIndex] = s;
                            scaleIndex++;
                            scaleIndex%=maxScale;
                            scaleAmount++;
                        }
                        float resultScale = 0.0;
                        if (scaleAmount==0)
                            resultScale = s;
                        else
                        {
                            for (unsigned int i=0; i<MIN(scaleAmount, maxScale); i++)
                                resultScale += scaleArray[i];
                            resultScale/=(double)MIN(scaleAmount, maxScale);
                        }*/
                        double t = (double)(i-startIndex)/(double)(lastIndex-startIndex);
                        ((DMBrushNode *)currentStroke[i])->scale = s*t+((DMBrushNode *)currentStroke[startIndex])->scale*(1.0-t);
                    }
                    if (isTouchEnd)
                    {
                        for (unsigned int i=lastIndex; i<[currentStroke count]; i++)
                        {
                            [trimmed addObject:currentStroke[i]];
                            ((DMBrushNode *)currentStroke[i])->scale = ((DMBrushNode *)currentStroke[lastIndex-1])->scale;
                        }
                        currentStroke = nil;
                        touchAmount = 0;
                        touchDelta = 0.0;
                        touchAverage = CGPointZero;
                        touchIndex = 0;
                        scaleAmount = 0;
                        scaleIndex = 0;
                        for (unsigned int i=0; i<maxScale; i++)
                            scaleArray[i] = 0.0f;
                        for (unsigned int i=0; i<maxTouch; i++)
                            touchArray[i] = CGPointZero;
                        
                    }
                    
    //                ((DMBrushNode *)currentStroke[lastIndex])->scale = [DMBrush calculateScale:p2 current:p3 delta:delta];
    //                [trimmed addObject:currentStroke[lastIndex]];
                    DMBrushNode * lastPoint = [brush drawPointList:trimmed withSize:CGSizeMake(46, 46) intoTarget:texture1 withBackground:background startLength:startLength+globalLength];
                    if (lastPoint)
                        startLength = [brush getLastLength]-globalLength;
                    if (isTouchEnd && lastPoint)
                    {
                        globalLength += startLength;
                        [brush drawCircleAt:lastPoint withSize:CGSizeMake(46, 46) intoTarget:texture1];
                        startLength = 0;
                    }
                }
            }
/*            if (currentErase)
            {
                if (!texture1)
                    texture1 = [[[DMGraphics manager] factory] createTarget:viewRect.size.width/2 height:viewRect.size.height/2];
                [brush erase:currentErase->position withSize:CGSizeMake(30, 30) intoTarget:texture1 withBackground:background];
                currentErase = nil;
            }*/
            if (texture1)
                [view1 presentTexture2:texture1 withView:view andRect:gRenderRect];
            else
                [texture1 clearWhite];
//                [view1 presentTexture2:background withView:view andRect:gRenderRect];
        }
    }
//    [[[DMGraphics manager] factory:YES] sleepTryUnlock];
}

float scaleArray[5];
unsigned int scaleAmount = 0, maxScale = 5, scaleIndex = 0;
double lastTouch = 0.0;
double touchDelta = 0.0;
unsigned int maxTouch = 5;
unsigned int touchIndex = 0;
CGPoint touchArray[5];
CGPoint touchAverage = {0.f, 0.f};
unsigned int touchAmount = 0;
BOOL isTouchEnd = NO;
- (void) touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
    if ([touches count]==1)
        currentErase = nil;
    if (currentErase)
        return;
    lastIndex = 0;
    isTouchEnd = NO;
    touchAmount = 0;
    touchDelta = 0.0;
    lastTouch = event.timestamp;
    touchAverage = CGPointZero;
    touchIndex = 0;
    scaleAmount = 0;
    scaleIndex = 0;
    for (unsigned int i=0; i<maxScale; i++)
        scaleArray[i] = 0.0f;
    for (unsigned int i=0; i<maxTouch; i++)
        touchArray[i] = CGPointZero;
    if ([touches count]>1)
    {
        currentStroke = nil;
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
    currentStroke = [NSMutableArray array];
    CGPoint point = [ [touches anyObject] locationInView:self];
    point.x*=gRetinaFactor;
    point.y*=gRetinaFactor;
    DMBrushNode * n = [DMBrushNode new];
    n->position = point;
    touchArray[touchIndex] = point;
    touchIndex++;
    touchIndex%=maxTouch;
    touchAverage = point;
//    n->time = event.timestamp;
    n->delta = 1.0/60.0;
    n->weightFactor = 2.0;
    [currentStroke addObject:n];
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
        touchAmount = 0;
        touchDelta = 0.0;
        touchAverage = CGPointZero;
        lastTouch = event.timestamp;
        currentStroke = nil;
        touchIndex = 0;
        for (unsigned int i=0; i<maxTouch; i++)
            touchArray[i] = CGPointZero;
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
    if (!currentStroke)
        currentStroke = [NSMutableArray array];
    CGPoint point = [ [touches anyObject] locationInView:self];
    point.x*=gRetinaFactor;
    point.y*=gRetinaFactor;
    DMBrushNode * n = [DMBrushNode new];
    double delta = event.timestamp-lastTouch;
    touchDelta = (touchDelta*(double)MIN(touchAmount, 5)+delta)/(double)(MIN(touchAmount, 5)+1);
    touchArray[touchIndex] = point;
    touchAmount++;
    touchIndex++;
    touchIndex%=maxTouch;
    touchAverage = CGPointZero;
    for (unsigned int i=0; i<MIN(touchAmount+1, maxTouch); i++)
    {
        touchAverage.x+=touchArray[i].x;
        touchAverage.y+=touchArray[i].y;
    }
    touchAverage.x/=(double)MIN(touchAmount+1, maxTouch);
    touchAverage.y/=(double)MIN(touchAmount+1, maxTouch);
    n->position = touchAverage;
    lastTouch = event.timestamp;
//    n->time = event.timestamp;
    n->delta = touchDelta;
    n->weightFactor = 1.0;
    [currentStroke addObject:n];
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
        touchAmount = 0;
        touchDelta = 0.0;
        touchAverage = CGPointZero;
        lastTouch = event.timestamp;
        currentStroke = nil;
        touchIndex = 0;
        for (unsigned int i=0; i<maxTouch; i++)
            touchArray[i] = CGPointZero;
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
    if (!currentStroke)
        currentStroke = [NSMutableArray array];
    CGPoint point = [ [touches anyObject] locationInView:self];
    point.x*=gRetinaFactor;
    point.y*=gRetinaFactor;
    double delta = event.timestamp-lastTouch;
    touchDelta = (touchDelta*(double)MIN(touchAmount, 5)+delta)/(double)(MIN(touchAmount, 5)+1);
    isTouchEnd = YES;
    for (unsigned int k=0; k<5; k++)
    {
        DMBrushNode * n = [DMBrushNode new];
        touchArray[touchIndex] = point;
        touchAmount++;
        touchIndex++;
        touchIndex%=maxTouch;
        touchAverage = CGPointZero;
        for (unsigned int i=0; i<MIN(touchAmount+1, maxTouch); i++)
        {
            touchAverage.x+=touchArray[i].x;
            touchAverage.y+=touchArray[i].y;
        }
        touchAverage.x/=(double)MIN(touchAmount+1, maxTouch);
        touchAverage.y/=(double)MIN(touchAmount+1, maxTouch);
        n->weightFactor = 2.;
        n->position = touchAverage;
        lastTouch = event.timestamp;
        //    n->time = event.timestamp;
        n->delta = touchDelta;
        [currentStroke addObject:n];
    }
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
/*
- (void)loadEffectWithModel:(NSMutableArray *)layers
{
    [loadMutex lock];
    first = [[DMBaseElement alloc] initWithLayerArray:@[[[NSBundle mainBundle] pathForResource:@"giant" ofType:@"pvr"], @(DMBlendModeNormal)] isMain:YES];
    texture1 = [[[DMGraphics manager] factory:YES] createTarget:first.elementSize.width height:first.elementSize.height];
    [first load];
    DMBaseElement * second = [[DMBaseElement alloc] initWithLayerArray:@[[[NSBundle mainBundle] pathForResource:@"land" ofType:@"pvr"], @(DMBlendModeNormal)] isMain:YES];
    [second load];
    //    processBackground = [[DMBaseElement alloc] initWithBlendArray:@[[NSNull null], @(DMBlendModeBlur)] isMain: YES withRect:CGRectZero];
    processBackground = second;
    [processBackground load];
    [loadMutex unlock];
}
*/
- (void)loadCollageWithArray:(NSMutableArray *)collage
{
/*    [loadMutex lock];
    
    prevTime1 = 0;
    prevTime2 = 0;
    transitionList = [[NSMutableArray alloc] initWithCapacity:movieCount];
    videoList = [[NSMutableArray alloc] initWithCapacity:movieCount];
    time1List = [[NSMutableArray alloc] initWithCapacity:movieCount+1];
    time2List = [[NSMutableArray alloc] initWithCapacity:movieCount+2];
    if (durationList!=NULL)
        free (durationList);
    durationList = NULL;
    durationList = malloc(movieCount*sizeof(double));
    
    double t1 = 0;
    double t2 = 0;
    double lastTime = 0.0;
    [time1List addObject:@(0.)];
    [time2List addObject:@(0.)];
    for (unsigned int i=0; i<movieCount; i++)
    {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString * path = [NSString stringWithFormat:@"%@movie%d.mov", NSTemporaryDirectory(), i];
        NSString * path2 = [NSString stringWithFormat:@"%@image%d.png", NSTemporaryDirectory(), i];
        
        DMBaseElement * effect;
        double duration = 4.0;
        if ([fileManager fileExistsAtPath:path])
        {
            DMVideo * video = [[[DMGraphics manager] factory:YES] loadVideoWithPath:path withRepeat:YES andIntro:0.0];
            effect = [[DMBaseElement alloc] initBlendWithVideo: video isMain:YES blend:DMBlendModeNormal isBGR:NO withRect:CGRectZero];
            [videoList addObject:video];
            duration = (double)[video getDuration].value/(double)[video getDuration].timescale;
        }
        else
        {
            effect = [[DMBaseElement alloc] initWithLayerArray:@[path2, @(DMBlendModeNormal)] isMain:YES];
            [videoList addObject:[NSNull null]];
        }
        [effect load];
        if (!texture1)
            texture1 = [[[DMGraphics manager] factory:YES] createTarget:1280 height:720];
//            texture1 = [[[DMGraphics manager] factory:YES] createTarget:effect.elementSize.width height:effect.elementSize.height];
        DMTransition * trans = [[DMTransition alloc] initWithEffect:effect isHalfRes:NO];
//        [trans setAlphaStart1:0.5 start2:0.5 startFactor:0.2 end1:0.5 end2:0.5 endFactor:0.8];
        double startFactor = 0.;
        double endFactor = 1.;
        if (duration<4.0)
            t1+=duration;
        else
        {
            if (i==0)
                t1 = 1.0;
            startFactor = 1./duration;
            endFactor = 1.0-(1./duration);
            t1+= duration-1.;
        }
        durationList[i] = duration;
        [time1List addObject:@(t1)];
        t2 = t1-1.0;
        [time2List addObject:@(t2)];
        lastTime = t1;
        [trans setAlphaStart1:0.0 start2:1.0 startFactor:startFactor end1:1.0 end2:0.0 endFactor:endFactor];
        [trans setScaleStart1:1. start2:1. startFactor:0. end1:2. end2:2. endFactor:1.0];
        [transitionList addObject:trans];
    }
    t2 = t1-1.0;
    [time2List addObject:@(t2)];

    [loadMutex unlock];*/
    
/*    video = [[[DMGraphics manager] factory:YES] loadVideoWithPath:[[NSBundle mainBundle] pathForResource:@"Movie" ofType:@"MOV"] withRepeat:YES andIntro:0.0];
    [video readNext];
    DMBaseElement * effect = [[DMBaseElement alloc] initBlendWithVideo: video isMain:YES blend:DMBlendModeNormal isBGR:NO withRect:CGRectZero];
//    DMBaseElement * effect = [[DMBaseElement alloc] initWithLayerArray:@[[[NSBundle mainBundle] pathForResource:@"giant" ofType:@"pvr"], @(DMBlendModeNormal)] isMain:YES];
    [effect load];
    texture1 = [[[DMGraphics manager] factory:YES] createTarget:effect.elementSize.width height:effect.elementSize.height];
    inTrans = [[DMTransition alloc] initWithEffect:effect isHalfRes:NO];
    [inTrans setAlphaStart1:0 start2:1.0 startFactor:0.2 end1:1.0 end2:0.0 endFactor:0.8];
    [inTrans setScaleStart1:0.5 start2:0.5 startFactor:0. end1:1.5 end2:1.5 endFactor:1.0];
    [inTrans setRotationStart1:-0.5 start2:-0.5 startFactor:0.0 end1:0.73 end2:0.73 endFactor:1.0];
    effect = [[DMBaseElement alloc] initWithLayerArray:@[[[NSBundle mainBundle] pathForResource:@"land" ofType:@"pvr"], @(DMBlendModeNormal)] isMain:YES];
    [effect load];
    outTrans = [[DMTransition alloc] initWithEffect:effect isHalfRes:NO];
    [outTrans setAlphaStart1:0 start2:1.0 startFactor:0.3 end1:1.0 end2:0.0 endFactor:0.9];
    [outTrans setScaleStart1:2. start2:2. startFactor:0. end1:0.75 end2:0.75 endFactor:1.0];
    [loadMutex unlock];*/
/*    first = [[DMBaseElement alloc] initWithLayerArray:@[[[NSBundle mainBundle] pathForResource:@"giant" ofType:@"pvr"], @(DMBlendModeNormal)] isMain:YES];
    texture1 = [[[DMGraphics manager] factory:YES] createTarget:first.elementSize.width height:first.elementSize.height];
    [first load];
    DMBaseElement * second = [[DMBaseElement alloc] initWithLayerArray:@[[[NSBundle mainBundle] pathForResource:@"land" ofType:@"pvr"], @(DMBlendModeNormal)] isMain:YES];
    [second load];
    //    processBackground = [[DMBaseElement alloc] initWithBlendArray:@[[NSNull null], @(DMBlendModeBlur)] isMain: YES withRect:CGRectZero];
    processBackground = second;
    [processBackground load];
    [loadMutex unlock];*/
}

- (void)clearEffect
{
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

-(void)resumePostProcess
{
/*    BOOL b = [DMVideo resumeSuccess];
    if (b)
        resumeCount++;
    NSString * path = [NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), @"output.mov"];
    NSString * prePath = [DMVideo lastProcessPath];
    DMVideo * preInput = [[[DMGraphics manager] factory:YES] loadVideoWithPath:prePath withSlow: YES];
    NSString * outputPath = [NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), resumeCount%2==1?(lastHalf?@"processResumeHalf.mov":@"processResume.mov"):(lastHalf?@"processHalf.mov":@"process.mov")];
    [self removeFile:[NSURL fileURLWithPath:outputPath]];
    isPostProcess = YES;
    [DMVideo resumePostProcess:nil preVideo:preInput withDelegate:self andPath:outputPath withCrop:_crop isHalf:lastHalf];*/
}


-(void)processLastRecordHalf:(BOOL)isHalf withCrop:(CGSize)crop
{
 /*   isPostProcess = YES;
    NSString * outputPath = [NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), isHalf?@"processHalf.mov":@"process.mov"];
    [self removeFile:[NSURL fileURLWithPath:outputPath]];
    lastHalf = isHalf;
    _crop = crop;
    [DMVideo postProcess:nil withDelegate: self andPath:outputPath withCrop:crop isHalf:isHalf];*/
}

- (void)processCollageWithCompleteBlock:(void (^)(void))completeBlock andErrorBlock:(void (^)(NSError *))errorBlock isHalf:(BOOL)isHalf
{
    index = 0;
    index2 = 0;
    off = NO;
    off2 = YES;
    [self setDisplay:NO];
//    [self processLastRecordHalf:isHalf withCrop:gRenderRect.size];
    [self processLastRecordHalf:isHalf withCrop:CGSizeMake(1280.0, 720.0)];
    
    isPost = YES;
    
    if (completeBlock){
        self.onProcessComplete = [completeBlock copy];
    }
    
    if (errorBlock) {
        self.onProcessFailed = [errorBlock copy];
    }
}

- (void)saveVideo
{
    isPost = YES;
#warning Not stopping preview might ruin save to camera roll
/*    NSString * str = [DMVideo saveLast];
    if (str)
    {
        NSError * error = [NSError errorWithDomain:str code:0 userInfo:nil];
//        if ([self.videoDelegate respondsToSelector:@selector(DMVideoViewDidFinishWithError:)])
//            [self.videoDelegate DMVideoViewDidFinishWithError:error];
    }
  */  
}
/*
- (void)setInterfaceOrientation:(UIInterfaceOrientation)toInterface
{
    if(toInterface == UIInterfaceOrientationLandscapeRight){
        rotate = YES;
    }else if(toInterface == UIInterfaceOrientationLandscapeLeft){
        rotate = NO;
    }
    [dmc setFlip:rotate];
}*/
@end
