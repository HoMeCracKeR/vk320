//
//  RSAppDelegate.m
//  VK320
//
//  Created by Roman Silin on 20.06.14.
//  Copyright (c) 2014 Roman Silin. All rights reserved.
//

#import "RSAppDelegate.h"

@implementation RSAppDelegate

+ (void)initialize {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSURL *downloadsURL = [[NSFileManager defaultManager] URLForDirectory:NSDownloadsDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
    NSDictionary *appDefaults = [NSDictionary dictionaryWithObjectsAndKeys:[downloadsURL path], kDownloadPath,
                                 [NSNumber numberWithInt:[REQUEST_DEFAULT_LIMIT intValue]], kRequestLimit,
                                 [NSNumber numberWithInt:[MYMUSIC_DEFAULT_LIMIT intValue]], kMyMusicLimit,
                                 [NSNumber numberWithInt:[STREAMS_DEFAULT_LIMIT intValue]], kStreamLimit,
                                 [NSNumber numberWithInt:[FILTER_KBPS_DEFAULT intValue]], kFilterKbps,
                                 [NSNumber numberWithBool:NO], kUseFullPaths,
                                 [NSNumber numberWithBool:NO], kSaveDownloadHistory,
                                 [NSNumber numberWithBool:NO], kDoubleClickDownload,
                                 [NSNumber numberWithBool:YES], kAutoPlayNextTrack,
                                 @"default", kSortDescriptorColumn,
                                 [NSNumber numberWithBool:YES], kSortDescriptorAscending,
                                 [NSNumber numberWithBool:YES], kCorrector,
                                 [NSNumber numberWithBool:YES], kCheckUpdates,
                                 [NSNumber numberWithBool:NO], kShuffle,
                                 [NSNumber numberWithBool:NO], kBroadcast,
                                 [NSNumber numberWithInt:VOLUME_DEFAULT_LEVEL], kVolumeLevel,
                                 nil];
    [defaults registerDefaults:appDefaults];
        
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag {
    
    if ( flag ) {
        [self.window orderFront:self];
    }
    else {
        [self.window makeKeyAndOrderFront:self];
    }
    
    return YES;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
        
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kSaveDownloadHistory]) {
        
        NSData *encodedDownloads = [[NSUserDefaults standardUserDefaults] objectForKey:kDownloadsHistory];
        
        if (encodedDownloads) {
            NSMutableArray *arrayOfDownloads = [[NSKeyedUnarchiver unarchiveObjectWithData: encodedDownloads] mutableCopy];
            for (RSDownloadItem *downloadItem in arrayOfDownloads) {
                [downloadItem setDelegate:self.window];
            }
            
            self.window.downloads = arrayOfDownloads;
            [self.window.downloadsTableView reloadData];
            [self.window updateDownloadsButtons];
        }
        
    }
    
    NSData *encodedTopFrame = [[NSUserDefaults standardUserDefaults] objectForKey:kTopFrame];
    NSData *encodedBottomFrame = [[NSUserDefaults standardUserDefaults] objectForKey:kBottomFrame];
    
    if (encodedTopFrame && encodedBottomFrame) {
        NSValue *valueTopFrame = [NSKeyedUnarchiver unarchiveObjectWithData:encodedTopFrame];
        NSValue *valueBottomFrame = [NSKeyedUnarchiver unarchiveObjectWithData:encodedBottomFrame];
        [self.window.resultsScrollView setFrame:[valueTopFrame rectValue]];
        [self.window.downloadsView setFrame:[valueBottomFrame rectValue]];
    }
    
    [self setOptionsMenuEnabled:YES];
    
    self.window.titlebarColor = [NSColor colorWithCalibratedWhite:0.9 alpha:1.0];
    self.window.enableGradients = NO;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [self.sheet.downloadsPathField setStringValue:[userDefaults objectForKey:kDownloadPath]];
    [self.sheet.requestLimitField setStringValue:[NSString stringWithFormat:@"%li",(long)[userDefaults integerForKey:kRequestLimit]]];
    [self.sheet.myMusicLimitField setStringValue:[NSString stringWithFormat:@"%li",(long)[userDefaults integerForKey:kMyMusicLimit]]];
    [self.sheet.streamsLimitField setStringValue:[NSString stringWithFormat:@"%li",(long)[userDefaults integerForKey:kStreamLimit]]];
    if ([self.sheet.requestLimitField.stringValue isEqualToString:@"0"]) {
        [self.sheet.requestLimitField setStringValue:@""];
    }
    if ([self.sheet.myMusicLimitField.stringValue isEqualToString:@"0"]) {
        [self.sheet.myMusicLimitField setStringValue:@""];
    }
    if ([self.sheet.streamsLimitField.stringValue isEqualToString:@"0"]) {
        [self.sheet.streamsLimitField setStringValue:@""];
    }
    [self.sheet.filterKbpsField setStringValue:[NSString stringWithFormat:@"%li Kbps",(long)[userDefaults integerForKey:kFilterKbps]]];
    [self.sheet.filterKbpsSlider setMaxValue:320/FILTER_KBPS_STEP];
    [self.sheet.filterKbpsSlider setNumberOfTickMarks:320/FILTER_KBPS_STEP];
    [self.sheet.filterKbpsSlider setDoubleValue:[userDefaults integerForKey:kFilterKbps]/FILTER_KBPS_STEP];
    
    [self.sheet.fullPathCheckbox setOn:[userDefaults boolForKey:kUseFullPaths]];
    [self.sheet.saveHistoryCheckbox setOn:[userDefaults boolForKey:kSaveDownloadHistory]];
    [self.sheet.doubleClickCheckbox setOn:[userDefaults boolForKey:kDoubleClickDownload]];
    [self.sheet.autoplayCheckbox setOn:[userDefaults boolForKey:kAutoPlayNextTrack]];
    [self.sheet.correctorCheckbox setOn:[userDefaults boolForKey:kCorrector]];
    [self.sheet.checkUpdatesCheckbox setOn:[userDefaults boolForKey:kCheckUpdates]];
    
}

- (void)applicationWillTerminate:(NSNotification *)notification {
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [[NSUserDefaults standardUserDefaults] setDouble:self.window.player.volume forKey:kVolumeLevel];
    
    [userDefaults setBool:self.window.shuffle forKey:kShuffle];
    [userDefaults setBool:self.window.broadcast forKey:kBroadcast];
    [self.window setBroadcast:NO]; // для снятия статуса из контакта
    
    NSValue *topValue = [NSValue valueWithRect:[self.window.resultsScrollView frame]];
    NSValue *bottomValue = [NSValue valueWithRect:[self.window.downloadsView frame]];
    NSData *topData = [NSKeyedArchiver archivedDataWithRootObject:topValue];
    NSData *bottomData = [NSKeyedArchiver archivedDataWithRootObject:bottomValue];
    [userDefaults setObject:topData forKey:kTopFrame];
    [userDefaults setObject:bottomData forKey:kBottomFrame];
    [userDefaults synchronize];
    
    if ([userDefaults boolForKey:kSaveDownloadHistory]) {
        if (self.window.downloads) {
            NSData *myEncodedObject = [NSKeyedArchiver archivedDataWithRootObject:self.window.downloads];
            [userDefaults setObject:myEncodedObject forKey:kDownloadsHistory];
        }
    } else {
        [userDefaults removeObjectForKey:kDownloadsHistory];
    }
    
    for (RSDownloadItem *downloadItem in self.window.downloads) {
        if (downloadItem.status != RSDownloadCompleted) {
            [downloadItem removeFile];
        }
    }

}

- (IBAction)activateSheet:(id)sender {

    NSString *username = (self.window.username)?self.window.username:UNKNOWN_USERNAME;
    [self.sheet.currentUser setStringValue:username];
    NSImage *avatar = self.window.avatar_50;
    NSImage *emptyAvatart = [NSImage imageNamed:@"NSUserGuest"];
    [self.sheet.avatarView setImage:(avatar)?[NSImage roundCorners:avatar]:emptyAvatart];

    [NSApp beginSheet:self.sheet modalForWindow:self.window modalDelegate:nil didEndSelector:nil contextInfo:NULL];
    
    [self setOptionsMenuEnabled:NO];
    
}

- (IBAction)closeSheet:(id)sender {
    
    [self.sheet checkValues:self];
    [self.sheet.requestLimitField display];
    [self.sheet.myMusicLimitField display];
    [self.sheet.streamsLimitField display];
    
    BOOL needReloadDownloadsPaths = NO;
    BOOL needSortResultsWithFilter = NO;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults integerForKey:kUseFullPaths] != self.sheet.fullPathCheckbox.isEnabled) {
        needReloadDownloadsPaths = YES;
    }
    if ([userDefaults integerForKey:kFilterKbps] != self.sheet.filterKbpsField.integerValue) {
        needSortResultsWithFilter = YES;
    }
    
    [userDefaults setObject:self.sheet.downloadsPathField.stringValue forKey:kDownloadPath];
    [userDefaults setInteger:[self.sheet.requestLimitField.stringValue intValue] forKey:kRequestLimit];
    [userDefaults setInteger:[self.sheet.myMusicLimitField.stringValue intValue] forKey:kMyMusicLimit];
    [userDefaults setInteger:[self.sheet.streamsLimitField.stringValue intValue] forKey:kStreamLimit];
    [userDefaults setInteger:[self.sheet.filterKbpsField.stringValue intValue] forKey:kFilterKbps];
    [userDefaults setBool:self.sheet.fullPathCheckbox.isOn forKey:kUseFullPaths];
    [userDefaults setBool:self.sheet.saveHistoryCheckbox.isOn forKey:kSaveDownloadHistory];
    [userDefaults setBool:self.sheet.doubleClickCheckbox.isOn forKey:kDoubleClickDownload];
    [userDefaults setBool:self.sheet.autoplayCheckbox.isOn forKey:kAutoPlayNextTrack];
    [userDefaults setBool:self.sheet.correctorCheckbox.isOn forKey:kCorrector];
    [userDefaults setBool:self.sheet.checkUpdatesCheckbox.isOn forKey:kCheckUpdates];
    [userDefaults synchronize];

    if (needReloadDownloadsPaths) {
        [self.window updateAfterCloseSettings];
    }
    if (needSortResultsWithFilter) {
        [self.window sortResults];
        [self.window.resultsTableView reloadData];
    }
    
    [NSApp endSheet:self.sheet];
    [self.sheet close];
    [self setOptionsMenuEnabled:YES];
    
}

- (IBAction)logout:(id)sender {
    [self.window logout];
    [self closeSheet:sender];
}

@end
