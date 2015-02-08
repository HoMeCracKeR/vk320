//
//  NSImage+Rotate.h
//  VK320
//
//  Created by Roman Silin on 31.07.14.
//  Copyright (c) 2014 Roman Silin. All rights reserved.
//

@interface NSImage (Rotated)

- (NSImage *)imageRotated:(float)degrees;
+ (NSImage *)roundCorners:(NSImage *)image;

@end


@interface NSImageView(Rotated)

- (void)setImageAndFrame:(NSImage *)image;

@end

