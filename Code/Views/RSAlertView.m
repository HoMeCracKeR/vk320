//
//  RSAlertView.m
//  VK320
//
//  Created by Roman Silin on 10.08.14.
//  Copyright (c) 2014 Roman Silin. All rights reserved.
//

#import "RSAlertView.h"
#import "Protocols.h"
#import "NSColor+PXExtentions.h"

@implementation RSAlertView

- (NSMutableAttributedString *)atrStr {
    if (!_atrStr) {
        _atrStr = [[NSMutableAttributedString alloc] init];
    }
    return _atrStr;
}

- (void)setText:(NSString *)text {
    _text = text;
    
    NSFont *systemFont = [NSFont systemFontOfSize:13.0f];
    NSDictionary * fontAttributes = [[NSDictionary alloc] initWithObjectsAndKeys:systemFont, NSFontAttributeName, nil];
    self.atrStr = [[NSMutableAttributedString alloc] initWithString:text attributes:fontAttributes];
    [self.atrStr addAttribute:NSForegroundColorAttributeName value:[NSColor whiteColor] range:NSMakeRange(0, text.length)];
    
}

- (void)showAlert:(NSString*)text withcolor:(NSColor *)color autoHide:(BOOL)autoHide {

    [self setText:text];
    [self setColor:color];
    
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context){
        [context setDuration:0.2];
        [[self animator] setAlphaValue:1.0];
        [self setNeedsDisplay:YES];
    } completionHandler:^{ }];
    
    [self.timer invalidate];
    self.timer = nil;
    if (autoHide) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(hideAlert) userInfo:nil repeats:NO];
        [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];        
    }
    
}

- (void)showAlert_ConnectionLag {
   
    [self.timer invalidate];
    self.timer = nil;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(connectionLag) userInfo:nil repeats:NO];
}

- (void)connectionLag {

    [self setAlphaValue:0.0];

    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context){
        [context setDuration:1.0];
        [self setText:ALERT_CONNECTION_TRY];
        [self setColor:[NSColor pxColorWithHexValue:COLOR_ALERT_BLUE]];
        [[self animator] setAlphaValue:1.0];
        [self setNeedsDisplay:YES];
    } completionHandler:^{ }];
    

}

- (void)hideAlert {
    
    [self.timer invalidate];
    self.timer = nil;
    
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context){
        [context setDuration:1.0];
        [[self animator] setAlphaValue:0.0];
        [self setNeedsDisplay:YES];
    } completionHandler:^{ }];
    
}

- (void)drawRect:(NSRect)dirtyRect {
    
    [super drawRect:dirtyRect];
    
    CGRect rectBack = [self bounds];
    [self.color set];
    [NSBezierPath fillRect:rectBack];
    
    
    CGPoint point;
    point.x = self.bounds.size.width/2 - self.atrStr.size.width/2;
    point.y = self.bounds.size.height/2 - self.atrStr.size.height/2;
    [self.atrStr drawAtPoint:point];
    
}

@end
