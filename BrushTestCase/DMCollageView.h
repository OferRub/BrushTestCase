//
//  DMCollageView.h
//  PhotoCollage
//
//  Created by Ofer Rubinstein on 6/27/13.
//  Copyright (c) 2013 Ofer Rubinstein. All rights reserved.
//

#import <GLKit/GLKit.h>
#import "DMCamera.h"

@protocol DMCollageViewDeleagte <NSObject>
- (void)DMCollageViewFrameTimeUpdate:(NSNumber *)time;
- (void)DMCollageViewProgressUpdate:(CGFloat)progress;
- (void)DMCollageViewDidFinishWithError:(NSError *)error;
@end
@interface DMCollageView : GLKView<GLKViewDelegate, DMGraphicsDelegate, ProcessDelegate, RecordDelegate>
@property (nonatomic, unsafe_unretained) id<DMCollageViewDeleagte> videoDelegate;
@property (nonatomic, readonly) NSString *currentVideoPath;

//- (void)loadEffectWithModel:(NSMutableArray *)layers;
-(void)startRecord;
-(void)stopRecord;
-(void)takePicture;
- (void)loadCollageWithArray:(NSMutableArray *)collage;
- (void)setDisplay:(BOOL)enable;
- (void)processCollageWithCompleteBlock:(void (^)(void))completeBlock andErrorBlock:(void (^)(NSError *))errorBlock isHalf:(BOOL)isHalf;
@end
