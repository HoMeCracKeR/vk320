//
//  ScrollingTextView.h
//  VK320
//
//  Created by Roman Silin on 08.08.14.
//  Copyright (c) 2014 Roman Silin. All rights reserved.
//

@interface ScrollingTextView : NSView {
    NSTimer *scroller;
    NSPoint point;
    NSString *text;
    NSTimeInterval speed;
    CGFloat stringWidth;
}

@property (nonatomic, copy) NSString *text;
@property (nonatomic) NSTimeInterval speed;
@property (strong, nonatomic) NSMutableAttributedString *atrStr;
@end
