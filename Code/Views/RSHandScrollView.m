//
//  RSHandScrollView.m
//  VK320
//
//  Created by Roman Silin on 07.08.14.
//  Copyright (c) 2014 Roman Silin. All rights reserved.
//

#import "RSHandScrollView.h"

@implementation RSHandScrollView

- (void)setAutoscroll:(BOOL)autoscroll {
    
    if (autoscroll) {

        self.duration = (self.widthOfText - self.frame.size.width)/10;
        self.scrollTimer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(moveTextToRight) userInfo:nil repeats:YES];
        
    } else if (self.scrollTimer) {
        
        [self.scrollTimer invalidate];
        self.scrollTimer = nil;
        
    }
    
}

- (void)moveTextToRight {

    [self.scrollTimer invalidate];
    self.scrollTimer = nil;

    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:self.duration];
    NSClipView* clipView = [self contentView];
    NSPoint newOrigin = [clipView bounds].origin;
    newOrigin.x = (self.widthOfText - [self contentView].frame.size.width)*2;
    [[clipView animator] setBoundsOrigin:newOrigin];
    [NSAnimationContext endGrouping];

    self.scrollTimer = [NSTimer scheduledTimerWithTimeInterval:(self.duration+2.0) target:self selector:@selector(moveTextToLeft) userInfo:nil repeats:NO];

}

- (void)moveTextToLeft {
    
    [self.scrollTimer invalidate];
    self.scrollTimer = nil;
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:self.duration];
    NSClipView* clipView = [self contentView];
    NSPoint newOrigin = [clipView bounds].origin;
    newOrigin.x = -(self.widthOfText - [self contentView].frame.size.width);
    [[clipView animator] setBoundsOrigin:newOrigin];
    [NSAnimationContext endGrouping];
    
    self.scrollTimer = [NSTimer scheduledTimerWithTimeInterval:(self.duration+2.0) target:self selector:@selector(moveTextToRight) userInfo:nil repeats:NO];
    
    
}

@end
