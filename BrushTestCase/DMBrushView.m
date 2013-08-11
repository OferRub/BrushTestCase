//
//  DMVideoView.m
//  MotionFX
//
//  Created by Ofer Rubinstein on 5/22/13.
//  Copyright (c) 2013 Dropico Media LTD. All rights reserved.
//

#import "DMBrushView.h"
#import "DMView.h"
#import "DMBrush.h"
#import "DMBrushTouche.h"
#import "DMBrushSpray.h"
#import <Dropico/Dropico.h>
#import "DMTexture+Extra.h"


@interface DMBrushView()
{
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

@implementation DMBrushView

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

    brush = [[DMBrushSpray alloc] init];
    [self setBackground:nil];
}


- (void)loadBrushWithType:(DMBrushType)type
{
    if (type==DMBrushTypeInk)
        brush = [[DMBrush alloc] init];
    else if (type==DMBrushTypeTouche)
        brush = [[DMBrushTouche alloc] init];
    else if (type==DMBrushTypeSpray)
        brush = [[DMBrushSpray alloc] init];
}

- (void)setSize:(double)size
{
    [brush setSize:CGSizeMake(size, size)];
}

- (DMBrush *)getBrush
{
    return brush;
}

- (void) setBackground:(DMTexture *)background
{
    background = [[[DMGraphics manager] factory] loadImageWithPath:[[NSBundle mainBundle] pathForResource:@"Valley_Oahu" ofType:@"ppng"]];
    [background load];
    [brush setBackground:background];
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
    if (currentErase)
    {
//        [brush clear: texture1 withBackground:background];
    }
    else
    {
        if (!texture1)
        {
            texture1 = [[[DMGraphics manager] factory] createTarget:viewRect.size.width height:viewRect.size.height isDepth:YES];
            [texture1 clearWhite];
        }
        [brush renderBrushForTarget:texture1];
    }
    if (texture1)
        [view1 presentTexture:texture1 withView:view andRect:gRenderRect];
    else
        [texture1 clearWhite];
}

double lastTouch = 0.0;
CGPoint lastPoint, lastLook;

- (void) touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
    if ([touches count]==1)
        currentErase = nil;
    if (currentErase)
        return;
//    NSLog (@"************");
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
    lastPoint = point;
    lastLook = CGPointMake(0, 0);

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
    CGPoint n1;
    n1.x = point.x-lastPoint.x;
    n1.y = point.y-lastPoint.y;
    float l = sqrt(n1.x*n1.x+n1.y*n1.y);
    n1.x/=l;
    n1.y/=l;
    float dot = n1.x*lastLook.x+n1.y*lastLook.y;
    if (dot>0.3 || sqrt((lastPoint.x-point.x)*(lastPoint.x-point.x)+(lastPoint.y-point.y)*(lastPoint.y-point.y))>20.0)
    {
        double delta = event.timestamp-lastTouch;
        lastTouch = event.timestamp;
        lastPoint = point;
        [brush drawStroke:(DMBrushStrokeData){point, delta}];
        lastLook = n1;
    }
/*    else
    {
        CGPoint n1;
        n1.x = point.x-lastPoint.x;
        n1.y = point.y-lastPoint.y;
        float l = sqrt(n1.x*n1.x+n1.y*n1.y);
        n1.x/=l;
        n1.y/=l;
        float dot = n1.x*lastLook.x+n1.y*lastLook.y;
        if (dot<0.0)
        {
            point.x-=2.0*l*dot*lastLook.x;
            point.y-=2.0*l*dot*lastLook.y;
            n1.x = point.x-lastPoint.x;
            n1.y = point.y-lastPoint.y;
            l = sqrt(n1.x*n1.x+n1.y*n1.y);
            n1.x/=l;
            n1.y/=l;
            lastLook = n1;
        }
    }*/
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
