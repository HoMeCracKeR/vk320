//
//  RSHandScrollView.h
//  VK320
//
//  Created by Roman Silin on 07.08.14.
//  Copyright (c) 2014 Roman Silin. All rights reserved.
//

#import "Protocols.h"

@interface RSHandScrollView : NSScrollView <NSAnimationDelegate>

@property (strong, nonatomic) NSTimer *scrollTimer;
@property (nonatomic) BOOL autoscroll;
@property (nonatomic) float duration;
@property (nonatomic) float widthOfText;

@end
