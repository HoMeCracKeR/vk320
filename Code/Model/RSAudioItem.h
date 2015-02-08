//
//  RSAudioItem.h
//  VK320
//
//  Created by Roman Silin on 22.06.14.
//  Copyright (c) 2014 Roman Silin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Protocols.h"

@interface RSAudioItem : NSObject

@property (strong, nonatomic) NSString *artist;
@property (strong, nonatomic) NSString *title;
@property (nonatomic) NSInteger duration;
@property (nonatomic) NSInteger size;
@property (nonatomic) NSInteger kbps;
@property (strong, nonatomic) NSString *url;
@property (strong, nonatomic) NSString *vkID;
@property (strong, nonatomic) NSString *owner_id;
@property (nonatomic) BOOL addedToVK;
@property (nonatomic) BOOL inDownloads;

+ (RSAudioItem *)initWithArtist:(NSString *)artist title:(NSString *)title duration:(NSInteger)duration kbps:(NSInteger)kbps size:(NSInteger)size url:(NSString *)url vkID:(NSString *)vkID owner_id:(NSString *)owner_id addedToVK:(BOOL)addedToVK;

@end
