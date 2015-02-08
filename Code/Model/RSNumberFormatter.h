//
//  RSNumberFormatter.h
//  VK320
//
//  Created by Roman Silin on 12.07.14.
//  Copyright (c) 2014 Roman Silin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RSNumberFormatter : NSNumberFormatter
@property NSInteger length;

+ (RSNumberFormatter *)initWithLength:(NSInteger)length;

@end
