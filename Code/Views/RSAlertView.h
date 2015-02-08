//
//  RSAlertView.h
//  VK320
//
//  Created by Roman Silin on 10.08.14.
//  Copyright (c) 2014 Roman Silin. All rights reserved.
//

@interface RSAlertView : NSView

@property (strong, nonatomic) NSString *text;
@property (strong, nonatomic) NSColor *color;
@property (strong, nonatomic) NSMutableAttributedString *atrStr;
@property (strong, nonatomic) NSTimer *timer;

- (void)showAlert:(NSString*)text withcolor:(NSColor *)color autoHide:(BOOL)autoHide;
- (void)showAlert_ConnectionLag;
- (void)hideAlert;
@end
