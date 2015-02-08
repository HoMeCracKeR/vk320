//
//  RSDownloadCell.m
//  VK320
//
//  Created by Roman Silin on 13.07.14.
//  Copyright (c) 2014 Roman Silin. All rights reserved.
//

#import "RSDownloadCell.h"

@implementation RSDownloadCell



- (void)drawRect:(NSRect)dirtyRect
{
    
    CGRect rectBack = [self bounds];
    NSBezierPath *pathBack = [NSBezierPath bezierPathWithRoundedRect:rectBack xRadius:4.0f yRadius:4.0f];
    if (![pathBack isEmpty]) {
        [pathBack addClip];
    }
    [[NSColor pxColorWithHexValue:COLOR_BAR_GRAY] set];
    [NSBezierPath fillRect:rectBack];
    
    CGRect rectProgress = [self bounds];
    rectProgress.size.width = rectProgress.size.width * self.progress;
    NSBezierPath *pathProgress = [NSBezierPath bezierPathWithRoundedRect:rectProgress xRadius:4.0f yRadius:4.0f];
    if (![pathProgress isEmpty]) {
        [pathProgress addClip];
    }

    [self.barColor set];
    [NSBezierPath fillRect:rectProgress];

    [super drawRect:dirtyRect];
    
}

- (void)setBackgroundStyle:(NSBackgroundStyle)backgroundStyle {
    
    self.textField.textColor =  [NSColor whiteColor];
    
}

@end
