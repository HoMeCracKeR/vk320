//
//  UIColor+PXExtentions.m
//  VK320
//
//  Created by Roman Silin on 11.07.13.
//  Copyright (c) 2013 Roman Silin. All rights reserved.
//

#import "NSColor+PXExtentions.h"

@implementation NSColor (UIColor_PXExtensions)

+ (NSColor*)randomColor {
    
    unsigned int baseInt = arc4random() % 16777216;
    NSString *hex = [NSString stringWithFormat:@"%06X", baseInt];
    return [self pxColorWithHexValue:hex];
    
}

+ (NSString *)hexStringForColor:(NSColor *)color {
    const CGFloat *components = CGColorGetComponents(color.CGColor);
    CGFloat r = components[0];
    CGFloat g = components[1];
    CGFloat b = components[2];
    NSString *hexString=[NSString stringWithFormat:@"%02X%02X%02X", (int)(r * 255), (int)(g * 255), (int)(b * 255)];
    return hexString;
}

+ (NSColor*)pxColorWithHexValue:(NSString*)hexValue
{
    //Default
    NSColor *defaultResult = [NSColor blackColor];
    
    //Strip prefixed # hash
    if ([hexValue hasPrefix:@"#"] && [hexValue length] > 1) {
        hexValue = [hexValue substringFromIndex:1];
    }
    
    //Determine if 3 or 6 digits
    NSUInteger componentLength = 0;
    if ([hexValue length] == 3)
    {
        componentLength = 1;
    }
    else if ([hexValue length] == 6)
    {
        componentLength = 2;
    }
    else
    {
        return defaultResult;
    }
    
    BOOL isValid = YES;
    CGFloat components[3];
    
    //Seperate the R,G,B values
    for (NSUInteger i = 0; i < 3; i++) {
        NSString *component = [hexValue substringWithRange:NSMakeRange(componentLength * i, componentLength)];
        if (componentLength == 1) {
            component = [component stringByAppendingString:component];
        }
        NSScanner *scanner = [NSScanner scannerWithString:component];
        unsigned int value;
        isValid &= [scanner scanHexInt:&value];
        components[i] = (CGFloat)value / 255.0f;
    }
    
    if (!isValid) {
        return defaultResult;
    }
    
    return [NSColor colorWithRed:components[0]
                           green:components[1]
                            blue:components[2]
                           alpha:1.0];
}

@end
