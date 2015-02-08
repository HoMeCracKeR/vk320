//
//  RSAudioItem.m
//  VK320
//
//  Created by Roman Silin on 22.06.14.
//  Copyright (c) 2014 Roman Silin. All rights reserved.
//

#import "RSAudioItem.h"

@implementation RSAudioItem

+ (RSAudioItem *)initWithArtist:(NSString *)artist title:(NSString *)title duration:(NSInteger)duration kbps:(NSInteger)kbps size:(NSInteger)size url:(NSString *)url vkID:(NSString *)vkID owner_id:(NSString *)owner_id addedToVK:(BOOL)addedToVK {
    RSAudioItem *audioItem = [[RSAudioItem alloc] init];
    audioItem.artist = artist;
    audioItem.title = title;
    audioItem.duration = duration;
    audioItem.size = size;
    audioItem.kbps = kbps;
    audioItem.url = url;
    audioItem.vkID = vkID;
    audioItem.owner_id = owner_id;
    return audioItem;
}

@end
