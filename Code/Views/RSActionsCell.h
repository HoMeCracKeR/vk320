//
//  RSActionsCell.h
//  VK320
//
//  Created by Roman Silin on 22.06.14.
//  Copyright (c) 2014 Roman Silin. All rights reserved.
//

#import "RSAudioItem.h"
#import "RSDownloadItem.h"
#import "Protocols.h"

@interface RSActionsCell : NSTableCellView
@property (strong, nonatomic) RSAudioItem *audioItem;
@property (weak, nonatomic) id <RSPlayer> delegate;
@property (nonatomic) BOOL play;
@property (nonatomic) BOOL hover;
@property (nonatomic) BOOL currentTrack;
@property (weak, nonatomic) IBOutlet NSButton *playButton;
@property (weak, nonatomic) IBOutlet NSButton *downloadButton;
@property (nonatomic) NSTrackingArea *trackingArea;

@end