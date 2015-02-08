//
//  RSDownloadItem.m
//  VK320
//
//  Created by Roman Silin on 13.07.14.
//  Copyright (c) 2014 Roman Silin. All rights reserved.
//

#import "RSDownloadItem.h"

@implementation RSDownloadItem

+ (RSDownloadItem *)initWithAudioItem:(RSAudioItem *)audioItem {
    
    RSDownloadItem *downloadItem = [[RSDownloadItem alloc] init];
    
    NSString  *downloadsDirectory = [[NSUserDefaults standardUserDefaults] objectForKey:kDownloadPath];
    
    NSString *filename = [NSString stringWithFormat:@"%@ - %@", [audioItem.artist clearBadPathSymbols], [audioItem.title clearBadPathSymbols]];
    if ([filename length] > 251) {
        filename = [filename substringWithRange:NSMakeRange(0, 251)];
    }

    downloadItem.path = [NSString stringWithFormat:@"%@/%@.mp3", downloadsDirectory, filename];
    downloadItem.duration = audioItem.duration;
    downloadItem.kbps = audioItem.kbps;
    downloadItem.size = audioItem.size;
    downloadItem.sizeDownloaded = 0;
    downloadItem.url = audioItem.url;
    downloadItem.status = RSDownloadAddedJustNow;
    downloadItem.operation = nil;
    downloadItem.audioItem = audioItem;
    
    return downloadItem;
    
}

- (void)startDownload {
    
    if ([self.delegate readyForStartDownload]) {
        
        if (![self.delegate internetAvailable]) {
            [[self.delegate alertView] showAlert:ALERT_CONNECTION_OFF withcolor:[NSColor pxColorWithHexValue:COLOR_ALERT_RED] autoHide:YES];
            self.status = RSDownloadReady;
            return;
        }

        self.status = RSDownloadAddedJustNow;
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.url]];
        __weak typeof(self)weakSelf = self;
        
        AFHTTPRequestOperationManager *manager = [self.delegate networkManager];
        AFHTTPRequestOperation *operation = [manager HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
            __strong typeof(weakSelf)blocksafeSelf = weakSelf;
            blocksafeSelf.status = RSDownloadCompleted;
            blocksafeSelf.operation = nil;
            [blocksafeSelf.delegate updateDownloadItem:blocksafeSelf];
            [blocksafeSelf.delegate downloadCompleted];

        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            if (error.code == -1005) {
                [[self.delegate alertView] showAlert:ALERT_CONNECTION_OFF withcolor:[NSColor pxColorWithHexValue:COLOR_ALERT_RED] autoHide:YES];

                [self setStatus:RSDownloadReady];
                [self setSizeDownloaded:0];
                [self.delegate updateDownloadItem:self];
                
            } else if (error.code == 2) {
                
                [self.delegate.alertView showAlert:ALERT_DOWNLOADS_PATH withcolor:[NSColor pxColorWithHexValue:COLOR_ALERT_RED] autoHide:YES];
                [self setStatus:RSDownloadReady];
                [self setSizeDownloaded:0];
                [self.delegate updateDownloadItem:self];                
                
            } else {
                
                [self.delegate showError:error withType:RSErrorNetwork];
                
            }
            
        }];
        
        [operation setOutputStream:[NSOutputStream outputStreamToFileAtPath:self.path append:NO]];
        [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
            __strong typeof(weakSelf)blocksafeSelf = weakSelf;
            if (blocksafeSelf.status == RSDownloadAddedJustNow) {
                blocksafeSelf.status = RSDownloadInProgress;
                [self.delegate updateDownloadsButtons];
            }
                blocksafeSelf.sizeDownloaded = totalBytesRead;
                [blocksafeSelf.delegate updateDownloadItem:blocksafeSelf];
            
        }];
        
        [operation start];
        [self setOperation:operation];
        
    } else {
        
        self.status = RSDownloadReady;
        
    }
    
}

- (void)pauseDownload {
    
    if (self.operation && [self.operation isExecuting]) {
        [self.operation pause];
        [self setStatus:RSDownloadPause];
        [self.delegate updateDownloadItem:self];
    }
    
}

- (void)resumeDownload {

    if (self.operation && [self.operation isPaused]) {
        
        if (![self.delegate internetAvailable]) {
            [self.delegate showError:[NSError errorWithDomain:@"" code:-1009 userInfo:nil] withType:RSErrorNetwork];
            return;
        }

        [self.operation resume];
        [self setStatus:RSDownloadInProgress];
        [self.delegate updateDownloadItem:self];        
    } else {
        NSLog(@"Resume download Error");
    }

}

- (void)removeFile {
    
    NSError *error;
    if ([[NSFileManager defaultManager] isDeletableFileAtPath:self.path]) {
        BOOL success = [[NSFileManager defaultManager] removeItemAtPath:self.path error:&error];
        if (!success) {
            NSLog(@"Error removing file at path: %@", error.localizedDescription);
        }
    }
    
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
	[encoder encodeObject:self.path forKey:@"path"];
	[encoder encodeInteger:self.duration forKey:@"duration"];
	[encoder encodeInteger:self.size forKey:@"size"];
   	[encoder encodeInteger:self.kbps forKey:@"kbps"];
	[encoder encodeObject:self.url forKey:@"url"];
    if (self.status != RSDownloadCompleted) {
        self.status = RSDownloadReady;
    }
	[encoder encodeInteger:self.status forKey:@"status"];
    
}

- (id)initWithCoder:(NSCoder *)decoder
{
	self = [super init];
	if( self != nil )
	{
        self.path = [decoder decodeObjectForKey:@"path"];
        self.duration = [decoder decodeIntegerForKey:@"duration"];
        self.size = [decoder decodeIntegerForKey:@"size"];
        self.kbps = [decoder decodeIntegerForKey:@"kbps"];
        self.url = [decoder decodeObjectForKey:@"url"];
        self.status = [decoder decodeIntegerForKey:@"status"];
        self.sizeDownloaded = (self.status == RSDownloadCompleted)? self.size : 0;
        self.operation = nil;
        
	}
	return self;
}

@end
