//
//  RSRowView.m
//  VK320
//
//  Created by Roman Silin on 17.07.14.
//  Copyright (c) 2014 Roman Silin. All rights reserved.
//

#import "RSRowView.h"

@implementation RSRowView

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];

    if (![self isSelected] && [self.delegate isCurrentAudioRow:self]) {
        
        NSColor *currentColor = [NSColor pxColorWithHexValue:COLOR_HIGHLIGHT_LITE];
        NSColor *blankColor = [NSColor whiteColor];
        
        NSGradient *gradient = [[NSGradient alloc] initWithColors:@[blankColor,currentColor,blankColor]];
        [gradient drawInRect:dirtyRect angle:0];
                
    } else {
        
        [super drawRect:dirtyRect];
        
    }
    
}

- (void)drawSelectionInRect:(NSRect)dirtyRect {
    
    NSColor *selectedColor = [NSColor pxColorWithHexValue:COLOR_HIGHLIGHT];
    [selectedColor setFill];
    NSRectFill(dirtyRect);
}

@end
