//
//  AVPlayer+Bonus.m
//  VK320
//
//  Created by Roman Silin on 13.01.15.
//  Copyright (c) 2015 Roman Silin. All rights reserved.
//

#import "AVPlayer+Bonus.h"

@implementation AVPlayer (Bonus)

- (NSTimeInterval)availableDuration {

    NSArray *loadedTimeRanges = [[self currentItem] loadedTimeRanges];
    CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];
    float startSeconds = CMTimeGetSeconds(timeRange.start);
    float durationSeconds = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result = startSeconds + durationSeconds;
    return result;
    
}

@end
