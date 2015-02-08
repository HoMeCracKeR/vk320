//
//  RSNumberFormatter.m
//  VK320
//
//  Created by Roman Silin on 12.07.14.
//  Copyright (c) 2014 Roman Silin. All rights reserved.
//

#import "RSNumberFormatter.h"

@implementation RSNumberFormatter

- (BOOL)isPartialStringValid:(NSString *)partialString newEditingString:(NSString *__autoreleasing *)newString errorDescription:(NSString *__autoreleasing *)error {
    
    if (!self.length) {
        self.length = 3;
    }
    
    if([partialString length] == 0) {
        return YES;
    }
    
    if(([partialString length] > self.length) || ([partialString intValue] < 0)) {
        NSBeep();
        return NO;
    }
    
    NSScanner* scanner = [NSScanner scannerWithString:partialString];
    
    if(!([scanner scanInt:0] && [scanner isAtEnd])) {
        NSBeep();
        return NO;
    }
    
    return YES;
}

+ (RSNumberFormatter *)initWithLength:(NSInteger)length {
    RSNumberFormatter* formatter = [[RSNumberFormatter alloc] init];
    formatter.length = length;
    return formatter;
}


@end
