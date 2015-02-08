//
//  ScrollingTextView.m
//  VK320
//
//  Created by Roman Silin on 08.08.14.
//  Copyright (c) 2014 Roman Silin. All rights reserved.
//

#import "ScrollingTextView.h"

@implementation ScrollingTextView

@synthesize text;
@synthesize speed;

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.speed = 0.1;
        
    }
    return self;
}

- (NSMutableAttributedString *)atrStr {
    if (!_atrStr) {
        _atrStr = [[NSMutableAttributedString alloc] init];
    }
    return _atrStr;
}

- (void)setSpeed:(NSTimeInterval)newSpeed {
    if (newSpeed != speed) {
        speed = newSpeed;
        [scroller invalidate];
        if (speed > 0 && text != nil) {
            scroller = [NSTimer scheduledTimerWithTimeInterval:speed target:self selector:@selector(moveText:) userInfo:nil repeats:YES];
        }
    }
}

- (void)setText:(NSString *)newText {
    text = [newText copy];
    point = NSZeroPoint;
    
    NSFont *systemFont = [NSFont systemFontOfSize:9.0f];
    NSDictionary * fontAttributes = [[NSDictionary alloc] initWithObjectsAndKeys:systemFont, NSFontAttributeName, nil];
    self.atrStr = [[NSMutableAttributedString alloc] initWithString:newText attributes:fontAttributes];
    [self.atrStr addAttribute:NSForegroundColorAttributeName value:[NSColor disabledControlTextColor] range:NSMakeRange(0, newText.length)];

    stringWidth = [self.atrStr size].width;
    
    [scroller invalidate];
    scroller = nil;
    
    if (stringWidth > self.frame.size.width && text != nil) {
        
        scroller = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(startMoveText:) userInfo:nil repeats:NO];
        [[NSRunLoop mainRunLoop] addTimer:scroller forMode:NSRunLoopCommonModes];
        [self setNeedsDisplay:YES];
        
    } else {
        
        [self.atrStr setAlignment:NSCenterTextAlignment range:NSMakeRange(0, newText.length)];
        point.x = self.frame.size.width/2 - stringWidth/2;
        [self setNeedsDisplay:YES];
        
    }
}

- (void)startMoveText:(NSTimer *)timer {
    
    [scroller invalidate];
    scroller = [NSTimer scheduledTimerWithTimeInterval:speed target:self selector:@selector(moveText:) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:scroller forMode:NSRunLoopCommonModes];
    
}

- (void)moveText:(NSTimer *)timer {
    point.x = point.x - 1.0f;
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)dirtyRect {

    [super drawRect:dirtyRect];
    if (point.x + stringWidth < 0) {
        point.x += dirtyRect.size.width;
    }
    
    [self.atrStr drawAtPoint:point];
    
    if (point.x < 0) {
        NSPoint otherPoint = point;
        otherPoint.x += stringWidth+50;
        [self.atrStr drawAtPoint:otherPoint];
    }
}

@end
