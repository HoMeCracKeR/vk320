//
//  HoverButtonView.h
//  VK320
//
//  Created by Roman Silin on 31.07.14.
//  Copyright (c) 2014 Roman Silin. All rights reserved.
//

#import "NSColor+PXExtentions.h"
#import "Protocols.h"

@interface HoverButtonView : NSButton

@property (nonatomic, strong) NSTrackingArea *trackingArea;
@property (nonatomic, strong) NSImage *imageTmp;
@property (nonatomic) BOOL mouseHover;
@property (strong) NSCursor *cursor;
@property BOOL needHandCursor;

@end
