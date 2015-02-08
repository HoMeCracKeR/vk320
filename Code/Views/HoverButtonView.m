//
//  HoverButtonView.m
//  VK320
//
//  Created by Roman Silin on 31.07.14.
//  Copyright (c) 2014 Roman Silin. All rights reserved.
//

#import "HoverButtonView.h"

@implementation HoverButtonView

- (void)awakeFromNib {
    [self updateTextColor];
    if (self.needHandCursor) {
        [self setCursor: [NSCursor pointingHandCursor]];
    } else {
        [self setCursor:[NSCursor arrowCursor]];
    }
}

- (void)mouseEntered:(NSEvent *)theEvent {
    [super mouseEntered:theEvent];
    [self setMouseHover:YES];
    if ([self isEnabled]) {
        self.imageTmp = self.image;
        self.image = self.alternateImage;
        [self updateTextColor];
    }
}

- (void)mouseExited:(NSEvent *)theEvent {
    [super mouseExited:theEvent];
    [self setMouseHover:NO];
    if ([self isEnabled]) {
        self.image = self.imageTmp;
        self.imageTmp = nil;
        [self updateTextColor];
    }
}

- (void)updateTextColor {
    
    NSColor *color;
    if (self.mouseHover) {
         color = [NSColor pxColorWithHexValue:COLOR_BUTTON_BLUE];
    } else {
       color = [NSColor pxColorWithHexValue:COLOR_BUTTON_GRAY];
    }

    NSMutableAttributedString *colorTitle =
    [[NSMutableAttributedString alloc] initWithAttributedString:[self attributedTitle]];
    NSRange titleRange = NSMakeRange(0, [colorTitle length]);
    [colorTitle addAttribute:NSForegroundColorAttributeName
                       value:color
                       range:titleRange];
    [self setAttributedTitle:colorTitle];
    
}


- (void)updateTrackingAreas {
    
    if(self.trackingArea != nil) {
        [self removeTrackingArea:self.trackingArea];
    }
    
    int opts = (NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways);
    self.trackingArea = [[NSTrackingArea alloc] initWithRect:[self bounds]
                                                     options:opts
                                                       owner:self
                                                    userInfo:nil];
    
    [self addTrackingArea:self.trackingArea];
}

- (void)setEnabled:(BOOL)flag {
    [super setEnabled:flag];    
    if (!flag && [self.image isEqualTo:self.alternateImage]) {
        [self setImage:self.imageTmp];
    }
}

- (void)resetCursorRects
{
    if (self.cursor) {
        [self addCursorRect:[self bounds] cursor: self.cursor];
    } else {
        [super resetCursorRects];
    }
}

@end
