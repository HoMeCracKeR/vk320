//
//  RSActionsCell.m
//  VK320
//
//  Created by Roman Silin on 22.06.14.
//  Copyright (c) 2014 Roman Silin. All rights reserved.
//

#import "RSActionsCell.h"

@implementation RSActionsCell

- (IBAction)clickOnPlayButton:(id)sender {

    if (!self.play) {
        [self.delegate playFromActionsCell:self];
    } else {
        [self.delegate stopMusic];
    }
    
}

- (IBAction)clickOnDownloadButton:(id)sender {

    [self.delegate addDownloadFromAudioItem:self.audioItem];
    
}

- (void)setPlay:(BOOL)play {
    
    if (play) {
        [self.playButton setImage:[NSImage imageNamed:@"a_pause@gray"]];
        [self.playButton setAlternateImage:[NSImage imageNamed:@"a_pause@black"]];
    } else {
        [self.playButton setImage:[NSImage imageNamed:@"a_play@gray"]];
        [self.playButton setAlternateImage:[NSImage imageNamed:@"a_play@black"]];
    }
    [self.downloadButton setImage:[NSImage imageNamed:@"a_download@gray"]];
    [self.downloadButton setAlternateImage:[NSImage imageNamed:@"a_download@black"]];
    
    _play = play;
}


@end
