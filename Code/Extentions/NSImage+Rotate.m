//
//  NSImage+Rotate.m
//  VK320
//
//  Created by Roman Silin on 31.07.14.
//  Copyright (c) 2014 Roman Silin. All rights reserved.
//

#import "NSImage+Rotate.h"

@implementation NSImage(Rotated)
- (NSImage *)imageRotated:(float)degrees {
    if (0 != fmod(degrees,90.)) { NSLog( @"This code has only been tested for multiples of 90 degrees. (TODO: test and remove this line)"); }
    degrees = fmod(degrees, 360.);
    if (0 == degrees) {
        return self;
    }
    NSSize size = [self size];
    NSSize maxSize;
    if (90. == degrees || 270. == degrees || -90. == degrees || -270. == degrees) {
        maxSize = NSMakeSize(size.height, size.width);
    } else if (180. == degrees || -180. == degrees) {
        maxSize = size;
    } else {
        maxSize = NSMakeSize(20+MAX(size.width, size.height), 20+MAX(size.width, size.height));
    }
    NSAffineTransform *rot = [NSAffineTransform transform];
    [rot rotateByDegrees:degrees];
    NSAffineTransform *center = [NSAffineTransform transform];
    [center translateXBy:maxSize.width / 2. yBy:maxSize.height / 2.];
    [rot appendTransform:center];
    NSImage *image = [[NSImage alloc] initWithSize:maxSize];
    [image lockFocus];
    [rot concat];
    NSRect rect = NSMakeRect(0, 0, size.width, size.height);
    NSPoint corner = NSMakePoint(-size.width / 2., -size.height / 2.);
    [self drawAtPoint:corner fromRect:rect operation:NSCompositeCopy fraction:1.0];
    [image unlockFocus];
    return image;
}

+ (NSImage*)roundCorners:(NSImage *)image
{
    if (!image) {
        return nil;
    }
    
    NSImage *existingImage = image;
    NSSize existingSize = [existingImage size];
    NSSize newSize = NSMakeSize(existingSize.height, existingSize.width);
    NSImage *composedImage = [[NSImage alloc] initWithSize:newSize];
    
    [composedImage lockFocus];
    [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
    
    NSRect imageFrame = NSRectFromCGRect(CGRectMake(0, 0, existingSize.height, existingSize.width));
    NSBezierPath *clipPath = [NSBezierPath bezierPathWithRoundedRect:imageFrame xRadius:10 yRadius:10];
    [clipPath setWindingRule:NSEvenOddWindingRule];
    [clipPath addClip];
    
    [image drawAtPoint:NSZeroPoint fromRect:NSMakeRect(0, 0, newSize.width, newSize.height) operation:NSCompositeSourceOver fraction:1];
    
    [composedImage unlockFocus];
    
    return composedImage;
}


@end

@implementation NSImageView(Rotated)

- (void)setImageAndFrame:(NSImage *)image {
    NSRect frame = [self frame];
    frame.size = [image size];
    [self setFrame:frame];
    [self setImage:image];
}

@end
