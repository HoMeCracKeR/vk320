//
//  NSString+Bonus.m
//  VK320
//
//  Created by Roman Silin on 13.07.14.
//  Copyright (c) 2014 Roman Silin. All rights reserved.
//

#import "NSString+Bonus.h"

@implementation NSString (Bonus)

- (NSString *)clearBadPathSymbols {
    
    NSCharacterSet* illegalFileNameCharacters = [NSCharacterSet characterSetWithCharactersInString:@"/\\?%*|\"<>"];
    NSString *stringWithoutBadSymbols = [[self componentsSeparatedByCharactersInSet:illegalFileNameCharacters] componentsJoinedByString:@" "];
    
    NSMutableArray *words = [[stringWithoutBadSymbols componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] mutableCopy];
    [words removeObject:@""];
    NSString *clearedString = [words componentsJoinedByString:@" "];
        
    return clearedString;
    
}

- (NSString *)clearBadUrlSymbols {
    
    NSCharacterSet* illegalFileNameCharacters = [NSCharacterSet characterSetWithCharactersInString:@";/?:@&=+$,/\\?%*|\"<>"];
    NSString *stringWithoutBadSymbols = [[self componentsSeparatedByCharactersInSet:illegalFileNameCharacters] componentsJoinedByString:@" "];
    
    NSMutableArray *words = [[stringWithoutBadSymbols componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] mutableCopy];
    [words removeObject:@""];
    NSString *clearedString = [words componentsJoinedByString:@" "];
    
    return clearedString;
    
}

@end
