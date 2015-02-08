//
//  RSDownloadItem.h
//  VK320
//
//  Created by Roman Silin on 13.07.14.
//  Copyright (c) 2014 Roman Silin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RSAudioItem.h"
#import "Protocols.h"
#import "NSString+Bonus.h"
#import "AFNetworking.h"
//#import "AFDownloadRequestOperation.h"
#import "NSColor+PXExtentions.h"

@interface RSDownloadItem : NSObject

@property (strong, nonatomic) NSString *path;
@property (nonatomic) NSInteger duration;
@property (nonatomic) NSInteger sizeDownloaded;
@property (nonatomic) NSInteger size;
@property (nonatomic) NSInteger kbps;
@property (strong, nonatomic) NSString *url;
@property (strong, nonatomic) AFHTTPRequestOperation *operation;
@property (nonatomic) enum RSDownloadStatus status;
@property (weak, nonatomic) id <RSPlayer> delegate;
@property (weak, nonatomic) RSAudioItem *audioItem;


+ (RSDownloadItem *)initWithAudioItem:(RSAudioItem *)audioItem;
- (void)startDownload;
- (void)pauseDownload;
- (void)resumeDownload;
- (void)removeFile;

@end
