//
//  DMCollageView.h
//  PhotoCollage
//
//  Created by Ofer Rubinstein on 6/27/13.
//  Copyright (c) 2013 Ofer Rubinstein. All rights reserved.
//

#import <GLKit/GLKit.h>
typedef enum _DMBrushType {
    DMBrushTypeSpray,
    DMBrushTypeMarker,
    DMBrushTypeInk
} DMBrushType;

@class DMBrush;

@interface DMBrushView : GLKView<GLKViewDelegate, DMGraphicsDelegate>

- (void)setBackground:(DMTexture *)background;
- (void)loadBrushWithType:(DMBrushType)type;
- (void)setSize:(double)size;
- (DMBrush *)getBrush;

@end
