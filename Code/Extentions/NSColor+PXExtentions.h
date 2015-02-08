//
//  UIColor+PXExtentions.h
//  VK320
//
//  Created by Roman Silin on 11.07.13.
//  Copyright (c) 2013 Roman Silin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSColor (NSColor_PXExtensions)
+ (NSString *)hexStringForColor:(NSColor *)color;
+ (NSColor *)pxColorWithHexValue:(NSString*)hexValue;
+ (NSColor *)randomColor;
@end
