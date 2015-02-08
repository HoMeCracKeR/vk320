//
//  RSMainWindow.m
//  VK320
//
//  Created by Roman Silin on 20.06.14.
//  Copyright (c) 2014 Roman Silin. All rights reserved.
//

#import "RSMainWindow.h"

@implementation RSMainWindow

static NSString *PlayerContext = @"PlayerContext";
static NSString *PlayerItemContext = @"PlayerItemContext";


#pragma mark Lazy Initializations

- (AFHTTPRequestOperationManager *)networkManager {
    if (!_networkManager) {
        _networkManager = [AFHTTPRequestOperationManager manager];
    }
    return _networkManager;
}

- (NSMutableDictionary *)funcKeysPressedNow {
    if (!_funcKeysPressedNow) {
        _funcKeysPressedNow = [[NSMutableDictionary alloc] init];
    }
    return _funcKeysPressedNow;
}


#pragma mark NSWindow

- (void)awakeFromNib {
    
    if (!self.access_token) {
        //once initilization
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"vkapi" ofType:@"plist"];
        self.configuration = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
        self.appId = self.configuration[@"APP_ID"];
        
        [self.altSearchView.layer setBackgroundColor:[[NSColor whiteColor] CGColor]];
        [self.altSearchView setHidden:YES];
        [self.webView setFrame:self.splitView.frame];
        [self.webView setHidden:YES];
        [self.resultsTableView setTarget:self];
        [self.resultsTableView setDoubleAction:@selector(doubleClickOnResult:)];
        [self.downloadsTableView setTarget:self];
        [self.downloadsTableView setDoubleAction:@selector(doubleClickOnDownload:)];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowResized) name:NSWindowDidResizeNotification object:nil];
        [[self.resultsScrollView contentView] setPostsBoundsChangedNotifications:YES];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resultsScrolled:) name:NSViewBoundsDidChangeNotification object:[self.resultsScrollView contentView]];
        
        NSString *key = [userDefaults objectForKey:kSortDescriptorColumn];
        if (key) {
            if ([key isEqualToString:@"default"]) {
                [self.resultsTableView setSortDescriptors:@[]];
            } else {
                BOOL ascending = [userDefaults boolForKey:kSortDescriptorAscending];
                NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:key ascending:ascending];
                [self.resultsTableView setSortDescriptors:@[sortDescriptor]];
            }
        }
        
        [self.playerTrackSlider setBarLeftAgeImage:[NSImage imageNamed:@"slider@start"]];
        [self.playerTrackSlider setBarFillBeforeKnobImage:[NSImage imageNamed:@"slider@before"]];
        [self.playerTrackSlider setKnobImage:[NSImage imageNamed:@"slider@button"]];
        [self.playerTrackSlider setBarFillImage:[NSImage imageNamed:@"slider@after"]];
        [self.playerTrackSlider setBarFillNotCachedImage:[NSImage imageNamed:@"slider@after_notcached"]];
        [self.playerTrackSlider setBarRightAgeImage:[NSImage imageNamed:@"slider@end"]];
        [self.playerTrackSlider setBarRightAgeNotCachedImage:[NSImage imageNamed:@"slider@end_notcached"]];
        [self.playerTrackSlider setTarget:self];
        [self.playerTrackSlider setAction:@selector(sliderChanged)];
        [self.playerTrackSlider setCaching:YES];
        
        double volumeLevel = [userDefaults doubleForKey:kVolumeLevel];
        [self.playerVolumeSlider setDoubleValue:volumeLevel*100];
        [self.playerVolumeSlider setTarget:self];
        [self.playerVolumeSlider setAction:@selector(volumeSliderChanged)];
        [self.playerVolumeSlider setBarLeftAgeImage:[[NSImage imageNamed:@"slider@end"] imageRotated:90.0f]];
        [self.playerVolumeSlider setBarFillBeforeKnobImage:[[NSImage imageNamed:@"slider@after"] imageRotated:90.0f]];
        [self.playerVolumeSlider setKnobImage:[[NSImage imageNamed:@"slider@button"] imageRotated:90.0f]];
        [self.playerVolumeSlider setBarFillImage:[[NSImage imageNamed:@"slider@before"] imageRotated:90.0f]];
        [self.playerVolumeSlider setBarRightAgeImage:[[NSImage imageNamed:@"slider@start"] imageRotated:90.0f]];

        [self setShuffle:[userDefaults boolForKey:kShuffle]];
        [self setBroadcast:[userDefaults boolForKey:kBroadcast]];
        [self updatePlayerUI];
        
        __block RSMainWindow *blocksafeSelf = self;
        [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
//            NSLog(@"Reachability: %@", AFStringFromNetworkReachabilityStatus(status));
            switch (status) {
                case AFNetworkReachabilityStatusNotReachable:
                    [blocksafeSelf setInternetAvailable:NO];
                    break;
                case AFNetworkReachabilityStatusReachableViaWiFi:
                    [blocksafeSelf setInternetAvailable:YES];
                    break;
                case AFNetworkReachabilityStatusReachableViaWWAN:
                    [blocksafeSelf setInternetAvailable:YES];
                    break;
                default:
                    [blocksafeSelf setInternetAvailable:NO];
                    break;
            }
        }];
        [[AFNetworkReachabilityManager sharedManager] startMonitoring];
        
        [self login];
        
        if ([[userDefaults objectForKey:kCheckUpdates] boolValue]) {
            [self checkUpdates:nil];
        }
    
    }
    
}

- (IBAction)checkUpdates:(id)sender {
        
    NSURL *url = [NSURL URLWithString:LAST_VERSION_URL];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest];
    [operation setCompletionBlockWithSuccess: ^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSString *lastVersion = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSString *currentVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        
        if (![lastVersion isEqualToString:currentVersion]) {
            
            NSAlert *alert = [[NSAlert alloc] init];
            [alert setMessageText:@"Обновление VK320!"];
            [alert setInformativeText:[NSString stringWithFormat:@"Новая версия %@ доступна для загрузки.\nОтключить уведомления можно в настройках.", lastVersion]];
            [alert addButtonWithTitle:@"Подробнее"];
            [alert addButtonWithTitle:@"Позже"];
            [alert beginSheetModalForWindow:self completionHandler:^(NSModalResponse returnCode) {
                
                if (returnCode == 1000) {
                    [[NSWorkspace sharedWorkspace] openURL: [NSURL URLWithString:UPDATES_URL]];
                }
                
            }];
            
        } else if ([sender isKindOfClass:[NSMenuItem class]]) {
            
            [self.alertView showAlert:ALERT_CHECK_UPDATES_ACTUAL withcolor:[NSColor pxColorWithHexValue:COLOR_ALERT_BLUE] autoHide:YES];
            
        }
        
    } failure: ^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [self.alertView showAlert:ALERT_CHECK_UPDATES_FAIL withcolor:[NSColor pxColorWithHexValue:COLOR_ALERT_RED] autoHide:YES];
        
    }];
    
    [operation start];
    
}

- (void)setInternetAvailable:(BOOL)internetAvailable {
    
    _internetAvailable = internetAvailable;
    if (internetAvailable && !self.isUserLoggedIn) {
        [self login];
    }
        
}

- (BOOL)splitView:(NSSplitView *)aSplitView shouldAdjustSizeOfSubview:(NSView *)subview {
    
    return (subview == self.resultsScrollView);
    
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMinimumPosition ofSubviewAt:(NSInteger)dividerIndex {
    
    return SPLIT_SUBVIEW_MIN_HEIGHT;
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainMaxCoordinate:(CGFloat)proposedMaximumPosition ofSubviewAt:(NSInteger)dividerIndex {
    
    return (self.splitView.frame.size.height - SPLIT_SUBVIEW_MIN_HEIGHT);
    
}

- (void)windowResized {
    
    self.searchProcessAnimatedIcon.layer.position = CGPointMake(self.searchProcessAnimatedIcon.frame.origin.x+self.searchProcessAnimatedIcon.frame.size.width/2, self.searchProcessAnimatedIcon.frame.origin.y+self.searchProcessAnimatedIcon.frame.size.height/2);
    self.searchProcessAnimatedIcon.layer.anchorPoint = CGPointMake(0.5f, 0.5f);

    
    NSRect topFrame = [self.resultsScrollView frame];
    NSRect bottomFrame = [self.downloadsView frame];
    NSRect splitFrame = [self.splitView frame];
    
    if (topFrame.size.height < SPLIT_SUBVIEW_MIN_HEIGHT) {
        topFrame.size.height = SPLIT_SUBVIEW_MIN_HEIGHT;
        
        bottomFrame.size.height = splitFrame.size.height - topFrame.size.height - [self.splitView dividerThickness];
        bottomFrame.origin.y = splitFrame.size.height - bottomFrame.size.height;
        
        [self.resultsScrollView setFrame:topFrame];
        [self.downloadsView setFrame:bottomFrame];
        
    }
    
    if (!self.webView.isHidden) {
        [self updateWebSnapshotFrom:self.webView];
    }
    
}

- (void)resultsScrolled:(NSNotification *)aNotification {
    
    [self.resultsTableView updateTrackingAreas];
    
}

- (void)showWebView {
    
    if (!self.webView.isHidden) {
        return;
    }
    
    [self updateWebSnapshotFrom:self.splitView];
    [[self contentView] addSubview:self.webViewSnapshot];
    [self.webViewSnapshot display];
    [self.splitView setHidden:YES];
    [self.webView setHidden:NO];
    [self.webView setAlphaValue:1.0];
    
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context){
        [context setDuration:0.3];
        [[self.webViewSnapshot animator] setAlphaValue:0.0];
        [self.webViewSnapshot setNeedsDisplay:YES];
    } completionHandler:^{
        [self.webViewSnapshot removeFromSuperview];
        [self updateWebSnapshotFrom:self.webView];
    }];
    
    [self updateDownloadsButtons];
    
}

- (void)hideWebView {
    
    if (self.webView.isHidden) {
        return;
    }
    
    [[self contentView] addSubview:self.webViewSnapshot];
    [self.webViewSnapshot display];
    [self.webView setHidden:YES];
    [self.splitView setHidden:NO];
    [self.splitView setAlphaValue:1.0];
    
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context){
        [context setDuration:0.3];
        [[self.webViewSnapshot animator] setAlphaValue:0.0];
        [self.webViewSnapshot setNeedsDisplay:YES];
    } completionHandler:^{
        [self.webViewSnapshot removeFromSuperview];
    }];
    
    [self updateDownloadsButtons];

}

- (BOOL)isCurrentAudioRow:(RSRowView *)rowView {
    
    NSInteger row = [self.resultsTableView rowForView:rowView];
    if (row > -1 && row == [self currentAudioRow]) {
        return YES;
    }
    return NO;
}

- (void)mouseMoved:(NSEvent *)theEvent {

    if (self.altSearchButton.mouseHover) {
        [[NSCursor arrowCursor] set];
    }
    [super mouseMoved:theEvent];

}

- (IBAction)clickAltSearchButton:(id)sender {
 
    [self.altSearchView setHidden:!self.altSearchView.isHidden];
    [self.searchField setEnabled:self.altSearchView.isHidden];
    if (self.searchField.isEnabled) {
        [self makeFirstResponder:self.searchField];
    }
    
}

- (IBAction)clickMyMusic:(id)sender {
    
    if ([sender isKindOfClass:[HoverButtonView class]]) {
        [sender mouseExited:nil];
    }
    [self.altSearchView setHidden:YES];
    [self.searchField setEnabled:YES];
    [self.searchField setStringValue:@""];
    [self startSearchWithPhrase:SEARCH_CODE_MYMUSIC];
    
}

- (IBAction)clickRecommendations:(id)sender {

    if ([sender isKindOfClass:[HoverButtonView class]]) {
        [sender mouseExited:nil];
    }
    [self.altSearchView setHidden:YES];
    [self.searchField setEnabled:YES];
    [self.searchField setStringValue:@""];
    [self startSearchWithPhrase:SEARCH_CODE_RECOMMEND];
    
}

- (IBAction)clickLinkInfo:(id)sender {

    if ([sender isKindOfClass:[HoverButtonView class]]) {
        [sender mouseExited:nil];
    }
    [self.altSearchView setHidden:YES];
    [self.searchField setEnabled:YES];
    [self.searchField setStringValue:@""];
    
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:@"Получение аудиозаписей по ссылке"];
    [alert setInformativeText:@"Поддерживаемые форматы:\n\nvk.com/xxxxx (пользователь или группа)\nvk.com/audiosxxxxx (аудиозаписи)\nvk.com/audiosxxxxx?album_id=xxxxx (альбом)\nvk.com/audiosxxxxxfriend=xxxxx (друзья)\nvk.com/wallxxxxx (стена)\nvk.com/wallxxxxx_xxxxx (пост)\n\nПросто скопируйте ссылку из браузера и вставьте в поле поиска вместо поискового запроса."];
    [alert addButtonWithTitle:@"Спасибо, я все понял"];
    [alert beginSheetModalForWindow:self completionHandler:^(NSModalResponse returnCode) {
    
        [self makeFirstResponder:self.searchField];
        [[self.searchField cell] setPlaceholderString:@"Просто вставьте ссылку сюда"];
//        [self.searchField setPlaceholderString:@"Просто вставьте ссылку сюда"];
        
    }];
    
}

- (IBAction)sayThanx:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL: [NSURL URLWithString:THANX_URL]];
}


#pragma mark Downloads

- (void)addDownloadFromAudioItem:(RSAudioItem *)audioItem {
    
    if (![self internetAvailable]) {
        [self showError:[NSError errorWithDomain:@"" code:-1009 userInfo:nil] withType:RSErrorNetwork];
        return;
    }
    
    if (audioItem.size == 0) {

        [self.networkManager HEAD:audioItem.url parameters:nil success:^(AFHTTPRequestOperation *operation) {
            
            [self didReceiveResponse:[operation response] forVkID:audioItem.vkID];
            RSDownloadItem *downloadItem = [RSDownloadItem initWithAudioItem:audioItem];
            [self startDownloadItem:downloadItem];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//            [self.alertView showAlert:ALERT_CONNECTION_FILESIZE_ERROR withcolor:[NSColor pxColorWithHexValue:COLOR_ALERT_YELLOW] autoHide:YES];
            NSLog(@"Error: %@", error);            
        }];
        
    } else {
        
        RSDownloadItem *downloadItem = [RSDownloadItem initWithAudioItem:audioItem];
        [self startDownloadItem:downloadItem];
        
    }
    
    [self updatePlayerUI];
    [self.resultsTableView reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:[self.results indexOfObject:audioItem]] columnIndexes:[NSIndexSet indexSetWithIndex:[self.resultsTableView columnWithIdentifier:@"Actions"]]];
    
}

- (void)startDownloadItem:(RSDownloadItem *)downloadItem {
    
    [downloadItem setDelegate:self];
    [downloadItem.audioItem setInDownloads:YES];
    if (!self.downloads) {
        self.downloads = [[NSMutableArray alloc]initWithObjects:downloadItem, nil];
    } else {
        [self.downloads insertObject:downloadItem atIndex:0];
    }
    [downloadItem startDownload];
    [self.downloadsTableView reloadData];
    [self updateDownloadsButtons];
    if ([self.downloadsTableView numberOfRows] > 0) {
        NSRect rowRect = [self.downloadsTableView rectOfRow:0];
        NSRect viewRect = [[self.downloadsTableView superview] frame];
        NSPoint scrollOrigin = rowRect.origin;
        scrollOrigin.y = scrollOrigin.y + (rowRect.size.height - viewRect.size.height) / 2;
        if (scrollOrigin.y < 0) scrollOrigin.y = 0;
        [[[self.downloadsTableView superview] animator] setBoundsOrigin:scrollOrigin];
        
    }
    
}

- (void)updateDownloadItem:(RSDownloadItem *)downloadItem {
    
    if (!downloadItem) {
        NSLog(@"!!! downloadItem = nil");
    }
    
    if ([self.downloads containsObject:downloadItem]) {
        NSInteger row = [self.downloads indexOfObject:downloadItem];
        [self.downloadsTableView reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:row]
                                           columnIndexes:[NSIndexSet indexSetWithIndex:[self.downloadsTableView columnWithIdentifier:@"DownloadBar"]]];
    }

}

- (void)updateAfterCloseSettings {
    
    [self.downloadsTableView reloadDataForRowIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [self.downloads count])] columnIndexes:[NSIndexSet indexSetWithIndex:[self.downloadsTableView columnWithIdentifier:@"File"]]];
    
}

- (BOOL)readyForStartDownload {
    
    int currentStreams = 0;
    currentStreams = currentStreams - 1 ; // Убираем добавляемый поток со статусом RSDownloadAddedJustNow
                                          // Необходимо, чтобы правильно обработать добавление массовых загрузок
    for (RSDownloadItem *downloadItem in self.downloads) {
        if (downloadItem.status == RSDownloadInProgress || downloadItem.status == RSDownloadAddedJustNow) {
            currentStreams ++;
        }
    }
    
    return (currentStreams < [self streamsLimit])? YES : NO;
    
}

- (void)downloadCompleted {
    
    int currentStreams = 0;
    NSMutableArray *readyDownloadItems = [[NSMutableArray alloc] init];
    for (RSDownloadItem *downloadItem in self.downloads) {
        if (downloadItem.status == RSDownloadInProgress) {
            currentStreams ++;
        }
        if (downloadItem.status == RSDownloadReady) {
            [readyDownloadItems addObject:downloadItem];
        }
    }
    
    if (([readyDownloadItems count] > 0) && (currentStreams < [self streamsLimit])) {
        
        [readyDownloadItems[readyDownloadItems.count-1] startDownload];
        
    }

    [self updateDownloadsButtons];
    
}

- (NSInteger)streamsLimit {
    
    NSInteger streamsLimit = [[NSUserDefaults standardUserDefaults] integerForKey:kStreamLimit];
    if (!streamsLimit) {
        streamsLimit = [STREAMS_DEFAULT_LIMIT intValue];
    } else if (streamsLimit > [STREAMS_MAX_LIMIT intValue]) {
        streamsLimit = [STREAMS_MAX_LIMIT intValue];
    }
    return streamsLimit;
    
}

- (NSInteger)requestLimit {
    
    NSInteger requestLimit = [[NSUserDefaults standardUserDefaults] integerForKey:kRequestLimit];
    if (!requestLimit) {
        requestLimit = [REQUEST_DEFAULT_LIMIT intValue];
    } else if (requestLimit > [REQUEST_MAX_LIMIT intValue]) {
        requestLimit = [REQUEST_MAX_LIMIT intValue];
    }
    return requestLimit;
    
}

- (NSInteger)myMusicLimit {
    
    NSInteger myMusicLimit = [[NSUserDefaults standardUserDefaults] integerForKey:kMyMusicLimit];
    if (!myMusicLimit) {
        myMusicLimit = [MYMUSIC_DEFAULT_LIMIT intValue];
    } else if (myMusicLimit > [MYMUSIC_MAX_LIMIT intValue]) {
        myMusicLimit = [MYMUSIC_MAX_LIMIT intValue];
    }
    return myMusicLimit;
    
}

- (IBAction)clickDownloadsStartButton:(id)sender {

    if ([self.downloadsTableView selectedRowIndexes].count > 0) {
        
        NSIndexSet *selectedIndexes = [self.downloadsTableView selectedRowIndexes];
        NSMutableArray *readyDownloadItemsInSelected = [[NSMutableArray alloc] init];
        NSInteger currentStreams = 0;
        
        for (RSDownloadItem *downloadItem in self.downloads) {
            if (downloadItem.status == RSDownloadInProgress) {
                currentStreams ++;
            }
            if ((downloadItem.status == RSDownloadReady || downloadItem.status == RSDownloadPause) && [selectedIndexes containsIndex:[self.downloads indexOfObject:downloadItem]]) {
                [readyDownloadItemsInSelected addObject:downloadItem];
            }
        }
        
        if (readyDownloadItemsInSelected > 0) {
            NSArray *readyDownloadItemsInSelectedReversed = [[readyDownloadItemsInSelected reverseObjectEnumerator] allObjects];
            for (RSDownloadItem *downloadItem in readyDownloadItemsInSelectedReversed) {
                if (currentStreams < [self streamsLimit]) {
                    if (downloadItem.status == RSDownloadReady) {
                        [downloadItem startDownload];
                    } else if (downloadItem.status == RSDownloadPause) {
                        [downloadItem resumeDownload];
                    }
                    currentStreams ++;
                }
                
            }
        }
        
    }
    
    [self updateDownloadsButtons];

}

- (IBAction)clickDownloadsPauseButton:(id)sender {

    if ([self.downloadsTableView selectedRowIndexes].count > 0) {
        
        NSIndexSet *selectedIndexes = [self.downloadsTableView selectedRowIndexes];
        NSMutableArray *currentStreamsInSelected = [[NSMutableArray alloc] init];
        
        for (RSDownloadItem *downloadItem in self.downloads) {
            if (downloadItem.status == RSDownloadInProgress && [selectedIndexes containsIndex:[self.downloads indexOfObject:downloadItem]]) {
                [currentStreamsInSelected addObject:downloadItem];
            }
        }
        
        if ([currentStreamsInSelected count] > 0) {
            for (RSDownloadItem *downloadItem in currentStreamsInSelected) {
              [downloadItem pauseDownload];
            }
        }
        
    }
    
    [self updateDownloadsButtons];

}

- (IBAction)clickDownloadsRemoveButton:(id)sender {
    
    NSIndexSet *selectedIndexes = [self.downloadsTableView selectedRowIndexes];
    
    if ([selectedIndexes count] > 0) {
        for (RSDownloadItem *downloadItem in self.downloads) {
            if ([selectedIndexes containsIndex:[self.downloads indexOfObject:downloadItem]]) {
                if (downloadItem.operation) {
                    [downloadItem pauseDownload];
                    [downloadItem removeFile];
                }
                [downloadItem.audioItem setInDownloads:NO];
                
                if (downloadItem.audioItem != nil) {
                    NSIndexSet *setOfRows = [NSIndexSet indexSetWithIndex:[self.results indexOfObject:downloadItem.audioItem]];
                    NSIndexSet *setOfColumns = [NSIndexSet indexSetWithIndex:[self.resultsTableView columnWithIdentifier:@"Actions"]];
                    
                    [self.resultsTableView reloadDataForRowIndexes:setOfRows columnIndexes:setOfColumns];
                }
                
            }
        }
        
        [self.downloads removeObjectsAtIndexes:selectedIndexes];
        [self.downloadsTableView reloadData];
        [self updateDownloadsButtons];
        [self updatePlayerUI];
        
    }
    
}

- (IBAction)clickDownloadsSelectAllButton:(id)sender {
    
    NSIndexSet *selectedRows = [self.downloadsTableView selectedRowIndexes];
    if ([selectedRows count] == [self.downloads count]) {
        [self.downloadsTableView deselectAll:self];
    } else {
        [self.downloadsTableView selectAll:self];
    }
    [self updateDownloadsButtons];
    
}

- (IBAction)startAllDownloads:(id)sender {
    
    NSIndexSet *selectedRows = [self.downloadsTableView selectedRowIndexes];
    [self.downloadsTableView selectAll:self];
    [self clickDownloadsStartButton:self];
    [self.downloadsTableView selectRowIndexes:selectedRows byExtendingSelection:NO];
    [self updateDownloadsButtons];
    
}

- (IBAction)pauseAllDownloads:(id)sender {

    NSIndexSet *selectedRows = [self.downloadsTableView selectedRowIndexes];
    [self.downloadsTableView selectAll:self];
    [self clickDownloadsPauseButton:self];
    [self.downloadsTableView selectRowIndexes:selectedRows byExtendingSelection:NO];
    [self updateDownloadsButtons];
    
}

- (IBAction)removeAllDownloads:(id)sender {
    
    NSIndexSet *selectedRows = [self.downloadsTableView selectedRowIndexes];
    [self.downloadsTableView selectAll:self];
    [self clickDownloadsRemoveButton:self];
    [self.downloadsTableView selectRowIndexes:selectedRows byExtendingSelection:NO];
    [self updateDownloadsButtons];
    
}

- (void)updateDownloadsButtons {
    
    if (!self.webView.isHidden) {
        [self.downloadsSelectAllButton setEnabled:NO];
        [self.downloadsStartButton setEnabled:NO];
        [self.downloadsPauseButton setEnabled:NO];
        [self.downloadsRemoveButton setEnabled:NO];
        return;
    }
    
    [self.downloadsSelectAllButton setEnabled:(self.downloads.count > 0)?YES:NO];
    [self.downloadsRemoveButton setEnabled:([self.downloadsTableView selectedRow] != -1)?YES:NO];
    
    if ([self.downloadsTableView selectedRowIndexes].count > 0) {
        
        NSIndexSet *selectedIndexes = [self.downloadsTableView selectedRowIndexes];
        NSInteger readyDownloadItemsInSelected = 0;
        NSInteger currentStreams = 0;
        NSInteger currentStreamsInSelected = 0;
        
        for (RSDownloadItem *downloadItem in self.downloads) {
            if (downloadItem.status == RSDownloadInProgress) {
                currentStreams ++;
                if ([selectedIndexes containsIndex:[self.downloads indexOfObject:downloadItem]]) {
                    currentStreamsInSelected ++;
                }
            }
            if ((downloadItem.status == RSDownloadReady || downloadItem.status == RSDownloadPause) && [selectedIndexes containsIndex:[self.downloads indexOfObject:downloadItem]]) {
                readyDownloadItemsInSelected ++;
            }
        }
        
        [self.downloadsStartButton setEnabled:((readyDownloadItemsInSelected > 0) && (currentStreams < [self streamsLimit]))? YES:NO];
        [self.downloadsPauseButton setEnabled:(currentStreamsInSelected > 0)? YES:NO];
        
    } else {
        
        [self.downloadsStartButton setEnabled:NO];
        [self.downloadsPauseButton setEnabled:NO];
        
    }
    
}

- (BOOL)downloadsMenuOperationsEnabled {
    
    return (self.downloads.count > 0);
    
}

- (IBAction)clickDownloadTheList:(id)sender {

    if (!self.resultsTableView.selectedRowIndexes.count) {
        return;
    }
    
    NSIndexSet *selectedIndexes = [self.resultsTableView selectedRowIndexes];
    
    for (RSAudioItem *audioItem in self.results) {
        if ([selectedIndexes containsIndex:[self.results indexOfObject:audioItem]]) {
            
            if (!audioItem.inDownloads) {
                [self addDownloadFromAudioItem:audioItem];
            }
            
        }
    }
    
    [self updateAddListButton];

    
}


#pragma mark Player

- (AVPlayer *)player {

    if (!_player) {
        
        NSString *silentPath = [[NSBundle mainBundle] pathForResource:@"silent" ofType:@"mp3"];
        _player = [AVPlayer playerWithURL:[[NSURL alloc] initFileURLWithPath: silentPath]];
        [_player addObserver:self forKeyPath:@"status" options:0 context:&PlayerContext];

        CMTime interval = CMTimeMakeWithSeconds(1.0, NSEC_PER_SEC); // 1 second
        __block RSMainWindow *blocksafeSelf = self;
        self.playbackTimeObserver =
        [self.player addPeriodicTimeObserverForInterval:interval queue:NULL usingBlock:^(CMTime time) {
            
            // Обновляем время и позицию слайдера каждую секунду в отдельном потоке
            int currentTime = 0;
            if (blocksafeSelf.player.currentTime.timescale > 0) {
                currentTime = (int)((blocksafeSelf.player.currentTime.value) / blocksafeSelf.player.currentTime.timescale);
            }
            [blocksafeSelf.playerTrackSlider setDoubleValue:currentTime];
            [blocksafeSelf.playerTime1 setStringValue:[blocksafeSelf stringFromDuration:CMTimeGetSeconds(blocksafeSelf.player.currentTime)]];
            [blocksafeSelf.playerTime2 setStringValue:[NSString stringWithFormat:@"-%@",[blocksafeSelf stringFromDuration:CMTimeGetSeconds([[blocksafeSelf.player currentItem] duration]) - CMTimeGetSeconds(blocksafeSelf.player.currentTime)]]];
            
        }];
        
        [self.player setVolume:[self.playerVolumeSlider doubleValue]/100];

    }

    return _player;
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change context:(void *)context {
    
    if (context == &PlayerContext) {
        if ([keyPath isEqualToString:@"status"]) {
            if (self.player.status == AVPlayerStatusFailed) {
                NSError *error = [self.player error];
                NSLog(@"AVPlayer = Failed: %@", [error description]);
                return;
            } else if (self.player.status == AVPlayerStatusReadyToPlay) {
                // Нет необходимости включать плеер, т.к. иницилизируем мы его еще до авторизации
                //[self.player play];
                //NSLog(@"AVPlayer = ReadyToPlay");
            } else if(self.player.status == AVPlayerItemStatusUnknown) {
                NSLog(@"AVPlayer = UnknownStatus");
            }
        }
    }
    
    if (context == &PlayerItemContext) {
        if ([keyPath isEqualToString:@"status"]) {
            if (self.playerItem.status == AVPlayerItemStatusFailed) {
                NSError *error = [self.playerItem error];
                NSLog(@"AVPlayerItem = Failed: %@", [error description]);
                return;
                
            } else if (self.playerItem.status == AVPlayerItemStatusReadyToPlay) {
                // Включаем плеер по готовности аудиозаписи в воспроизведению
                [self.player play];
                // Обновлеем UI
                [self.alertView hideAlert];
                if (self.broadcast) { [self updateVKMusicTranslate]; };
                [self updatePlayerUI];
                if ([self currentAudioRow] >= 0) {
                    [self.resultsTableView reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:[self currentAudioRow]] columnIndexes:[NSIndexSet indexSetWithIndex:[self.resultsTableView columnWithIdentifier:@"Actions"]]];
                }
                //NSLog(@"AVPlayerItem = ReadyToPlay");
                
            } else if(self.playerItem.status == AVPlayerItemStatusUnknown) {
                NSLog(@"AVPlayerItem = UnknownStatus");
                
            }
        }
    }
    
    return;
}

- (void)playFromActionsCell:(RSActionsCell *)actionsCell {
    
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    [indexSet addIndex:[self.resultsTableView rowForView:actionsCell]];
    
    if ([self.currentAudioItem.url isEqualToString:actionsCell.audioItem.url]) {
        
        [self clickPlayerPlayPause:nil];
        [self.resultsTableView reloadDataForRowIndexes:indexSet columnIndexes:[NSIndexSet indexSetWithIndex:[self.resultsTableView columnWithIdentifier:@"Actions"]]];
        [self updatePlayerUI];
        
    } else {
        
        if (![self internetAvailable]) {
            [self showError:[NSError errorWithDomain:@"" code:-1009 userInfo:nil] withType:RSErrorNetwork];
            return;
        }
        
        RSRowView *oldRowView;
        if ([self currentAudioRow] >= 0) {
            [indexSet addIndex:[self currentAudioRow]];
            
            oldRowView = (RSRowView *)[self.resultsTableView rowViewAtRow:[self currentAudioRow] makeIfNecessary:YES];
        }
        [self setCurrentAudioItem:actionsCell.audioItem];

        [self.playerItem removeObserver:self forKeyPath:@"status" context:&PlayerItemContext];
        
        NSURL *url = [NSURL URLWithString:actionsCell.audioItem.url];
        AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:url options:nil];
        NSArray *keys     = [NSArray arrayWithObject:@"playable"];
        self.playerItem = [AVPlayerItem playerItemWithAsset:asset];
        [self.playerItem addObserver:self forKeyPath:@"status" options:0 context:&PlayerItemContext];
        
        [asset loadValuesAsynchronouslyForKeys:keys completionHandler:^() {
          
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.alertView showAlert_ConnectionLag];
                [self.player pause];
                [self.player replaceCurrentItemWithPlayerItem:self.playerItem];
                
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(endOfTrack) name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem];
                self.cacheUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateCachedProgress) userInfo:nil repeats:YES];

            });
        }];
        
        NSString *clearedSongTitle = [NSString stringWithFormat:@"%@ - %@", [self.currentAudioItem.artist clearBadPathSymbols], [self.currentAudioItem.title clearBadPathSymbols]];
        [self.trackTitle setText:clearedSongTitle];
        
        RSRowView *newRowView = (RSRowView *)[self.resultsTableView rowViewAtRow:[self currentAudioRow] makeIfNecessary:YES];
        if (oldRowView) {
            [oldRowView setNeedsDisplay:YES];
        }
        [newRowView setNeedsDisplay:YES];
        
        [self.resultsTableView reloadDataForRowIndexes:indexSet columnIndexes:[NSIndexSet indexSetWithIndex:[self.resultsTableView columnWithIdentifier:@"Actions"]]];
        [self updatePlayerUI];
        
    }
}

- (void)updateCachedProgress {
    
    // Обновляем кеш
    NSTimeInterval availableDuration = [self.player availableDuration];
    float roundedAvailableDuration = round(availableDuration);
    float roundedItemDuration = round(CMTimeGetSeconds([[self.playerItem asset] duration]));
    
    //NSLog(@"### cached: %f/%f",roundedAvailableDuration, roundedItemDuration);
    float cachedPart = roundedAvailableDuration / roundedItemDuration ;
    if (cachedPart == 1) {
        [self.cacheUpdateTimer invalidate];
        self.cacheUpdateTimer = nil;
    }
    [self.playerTrackSlider setCacheProgress:cachedPart];
    
}
    
- (void)endOfTrack {

    BOOL playNextTrack = [[NSUserDefaults standardUserDefaults] boolForKey:kAutoPlayNextTrack];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem];
    
    if (playNextTrack) {
        [self playNextTrack];
    } else {
        [self stopMusic];
    }
    
}

- (NSString *)stringFromDuration:(NSInteger)duration {
    
    NSUInteger h = (int)duration / 3600;
    NSUInteger m = ((int)duration / 60) % 60;
    NSUInteger s = (int)duration % 60;
    NSString *durationSring = [NSString stringWithFormat:@"%lu:%02lu:%02lu", (unsigned long)h, (unsigned long)m, (unsigned long)s];
    if (h <1) {
        durationSring = [NSString stringWithFormat:@"%02lu:%02lu", (unsigned long)m, (unsigned long)s];
    }
    
    return durationSring;
}

- (NSInteger)currentAudioRow {
    
    NSInteger row = -1;
    for (RSAudioItem *audioItem in self.results) {
        if ([audioItem.url isEqualToString:self.currentAudioItem.url]) {
            row = [self.results indexOfObject:audioItem];
        }
    }
    return row;
    
}

- (void)playNextTrack {
    
    NSInteger currentRow = [self currentAudioRow];
    NSInteger nextRow = currentRow + 1;
    
    if (self.shuffle) {
        nextRow = [self shuffleRowForward:YES];
    }
    
    if (nextRow < self.results.count) {
        RSActionsCell *actionsCell = [self.resultsTableView viewAtColumn:[self.resultsTableView columnWithIdentifier:@"Actions"] row:nextRow makeIfNecessary:YES];
        [self playFromActionsCell:actionsCell];
    } else {
        [self stopMusic];
    }
    
}

- (void)playPrevTrack {
    
    NSInteger currentRow = [self currentAudioRow];
    NSInteger prevRow = (self.shuffle)? [self shuffleRowForward:NO] : currentRow - 1;
    CMTime t = CMTimeMake(self.playerTrackSlider.doubleValue, 1);
    CMTime tZero = CMTimeMake(0, 1);
    
    if (CMTimeGetSeconds(t) < TIME_FOR_REWARD && prevRow >= 0) {

        RSActionsCell *actionsCell = [self.resultsTableView viewAtColumn:[self.resultsTableView columnWithIdentifier:@"Actions"] row:prevRow makeIfNecessary:YES];
        [self playFromActionsCell:actionsCell];
        
    } else {
        
        [self.playerTime1 setStringValue:[self stringFromDuration:CMTimeGetSeconds(tZero)]];
        [self.playerTime2 setStringValue:[NSString stringWithFormat:@"-%@",[self stringFromDuration:CMTimeGetSeconds([[self.player currentItem] duration]) - CMTimeGetSeconds(tZero)]]];
        [self.player seekToTime:tZero];
        
    }
    
    
}

- (NSInteger)shuffleRowForward:(BOOL)forward {
    
    if (![self.shuffleResults containsObject:self.currentAudioItem]) {
        return 0;
    }

    NSInteger indexInShuffleList = [self.shuffleResults indexOfObject:self.currentAudioItem];
    
    if (forward) {
        
        indexInShuffleList = indexInShuffleList + 1;
        if (indexInShuffleList == [self.shuffleResults count]) {
            indexInShuffleList = 0;
        }
        
    } else {
        
        indexInShuffleList = indexInShuffleList -1;
        if (indexInShuffleList == -1) {
            indexInShuffleList = [self.shuffleResults count]-1;
        }

    }
    
    NSInteger newIndex = [self.results indexOfObject:[self.shuffleResults objectAtIndex:indexInShuffleList]];
    
    return newIndex;
    
}

- (void)stopMusic {
    
    [self.player pause];
    if ([self currentAudioRow] != -1) {
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:[self currentAudioRow]];
        [self.resultsTableView reloadDataForRowIndexes:indexSet columnIndexes:[NSIndexSet indexSetWithIndex:[self.resultsTableView columnWithIdentifier:@"Actions"]]];
    }
    [self updatePlayerUI];
    
}

- (IBAction)clickPlayerPlayPause:(id)sender {
    
    if (self.player.rate == 0.0f) {
        [self.player play];
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:[self currentAudioRow]];
        [self.resultsTableView reloadDataForRowIndexes:indexSet columnIndexes:[NSIndexSet indexSetWithIndex:[self.resultsTableView columnWithIdentifier:@"Actions"]]];
    } else {
        [self stopMusic];
    }
    [self updatePlayerUI];
    
}

- (IBAction)clickPlayerPrev:(id)sender {
    
    [self playPrevTrack];
    
}

- (IBAction)clickPlayerNext:(id)sender {
    
    [self playNextTrack];
    
}

- (void)sliderChanged {

    CMTime tNew = CMTimeMake(self.playerTrackSlider.doubleValue, 1);
    CMTime tCache = CMTimeMake([self.player availableDuration], 1);

    if (tNew.value > tCache.value) {
        tNew.value = tCache.value - 10.f;
        [self.playerTrackSlider setDoubleValue:tNew.value];
    }

    [self.playerTime1 setStringValue:[self stringFromDuration:CMTimeGetSeconds(tNew)]];
    [self.playerTime2 setStringValue:[NSString stringWithFormat:@"-%@",[self stringFromDuration:CMTimeGetSeconds([[self.player currentItem] duration]) - CMTimeGetSeconds(tNew)]]];
    [self.player seekToTime:tNew];
    
}

- (void)volumeSliderChanged {
    
    [self.player setVolume:self.playerVolumeSlider.doubleValue/100];
    
}

- (IBAction)clickShuffle:(id)sender {
    
    [self setShuffle:self.playerShuffleButton.state];
    if (self.shuffle) {
        NSMutableArray *shuffleResults = [self.results mutableCopy];
        [shuffleResults shuffle];
        self.shuffleResults = shuffleResults;
    }
    [self updatePlayerUI];
    
}

- (IBAction)clickBroadcast:(id)sender {
    
    [self setBroadcast:self.broadcastButton.state];
    [self updatePlayerUI];
    
}

- (IBAction)clickPlayerDownload:(id)sender {
    
    [self addDownloadFromAudioItem:self.currentAudioItem];
    
}

- (IBAction)clickPlayerAddToVK:(id)sender {
    
    if (self.access_token && self.user_id && self.currentAudioItem && self.currentAudioItem.vkID && self.currentAudioItem.owner_id) {

        NSString *method_audioAdd = @"https://api.vk.com/method/audio.add";
        
        
        NSDictionary *addParameters = @{@"audio_id": self.currentAudioItem.vkID,
                                        @"owner_id": self.currentAudioItem.owner_id,
                                        @"v": VK_API_VERSION,
                                        @"access_token": self.access_token};
        
        [self.networkManager POST:method_audioAdd parameters:addParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            if ([self checkResponseForError:responseObject]) {
                
                [self.currentAudioItem setAddedToVK:YES];
                [self updatePlayerUI];
                [self.alertView showAlert:ALERT_ADDTOVK_SUCCESS withcolor:[NSColor pxColorWithHexValue:COLOR_ALERT_BLUE] autoHide:YES];

            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            NSLog(@"# Error description: %@", error);
            [self.alertView showAlert:ALERT_ADDTOVK_FAILURE withcolor:[NSColor pxColorWithHexValue:COLOR_ALERT_RED] autoHide:YES];
            
        }];
        
    } else {
        
        [self.alertView showAlert:ALERT_ADDTOVK_FAILURE withcolor:[NSColor pxColorWithHexValue:COLOR_ALERT_YELLOW] autoHide:YES];
        
    }
    
}

- (void)updatePlayerUI {
    
    // Если скорость воспроизведения > 0
    if (self.player.rate > 0.0f) {
        [self.playerPlayPauseButton setImageTmp:(self.playerPlayPauseButton.mouseHover)?[NSImage imageNamed:@"pause@gray"]:nil];
        [self.playerPlayPauseButton setAlternateImage:[NSImage imageNamed:@"pause@blue"]];
        [self.playerPlayPauseButton setImage:(self.playerPlayPauseButton.mouseHover)?[NSImage imageNamed:@"pause@blue"]:[NSImage imageNamed:@"pause@gray"]];

    // Если скорость воспроизведения = 0
    } else {
        [self.playerPlayPauseButton setImageTmp:(self.playerPlayPauseButton.mouseHover)?[NSImage imageNamed:@"play@gray"]:nil];
        [self.playerPlayPauseButton setAlternateImage:[NSImage imageNamed:@"play@blue"]];
        [self.playerPlayPauseButton setImage:(self.playerPlayPauseButton.mouseHover)?[NSImage imageNamed:@"play@blue"]:[NSImage imageNamed:@"play@gray"]];

    }

    if (self.currentAudioItem) {
        
        [self.playerPlayPauseButton setEnabled:YES];
        [self.playerNextButton setEnabled:(self.results.count > 0 && [self currentAudioRow] != self.results.count-1)? YES:NO];
        [self.playerPrevButton setEnabled:YES];
        
        if (self.results.count > 1 && self.shuffle) {
            [self.playerNextButton setEnabled:YES];
            [self.playerPrevButton setEnabled:YES];
        }
        
        [self.playerTrackSlider setEnabled:YES];
        [self.playerTrackSlider setMaxValue:self.currentAudioItem.duration];
        [self.playerTime1 setStringValue:[self stringFromDuration:CMTimeGetSeconds([self.player currentTime])]];
        [self.playerTime2 setStringValue:[NSString stringWithFormat:@"-%@",[self stringFromDuration:CMTimeGetSeconds([[self.player currentItem] duration]) - CMTimeGetSeconds([self.player currentTime])]]];
        
        [self.playerDownloadButton setEnabled:!self.currentAudioItem.inDownloads];
        
        BOOL addedToVK = NO;
        if (self.currentAudioItem.owner_id == self.user_id || self.currentAudioItem.addedToVK) {
            addedToVK = YES;
        }
        [self.playerAddToVKButton setEnabled:!addedToVK];

        
    } else {

        [self.playerPlayPauseButton setEnabled:NO];
        [self.playerNextButton setEnabled:NO];
        [self.playerPrevButton setEnabled:NO];
        [self.playerTrackSlider setEnabled:NO];
        [self.trackTitle setText:@"Добро пожаловать в VK320!"];
        [self.playerTime1 setStringValue:@"-:--"];
        [self.playerTime2 setStringValue:@"-:--"];
        [self.playerAddToVKButton setEnabled:NO];
        [self.playerDownloadButton setEnabled:NO];
        
    }
    
    [self.playerShuffleButton setState:[[NSNumber numberWithBool:self.shuffle] intValue]];
    [self.playerShuffleButton setImage:[NSImage imageNamed:(self.shuffle)?@"shuffle@blue":@"shuffle@gray"]];
    [self.playerShuffleButton setAlternateImage:[NSImage imageNamed:(self.shuffle)?@"shuffle@gray":@"shuffle@blue"]];
    [self.broadcastButton setState:[[NSNumber numberWithBool:self.broadcast] intValue]];
    [self.broadcastButton setImage:[NSImage imageNamed:(self.broadcast)?@"broadcast@blue":@"broadcast@gray"]];
    [self.broadcastButton setAlternateImage:[NSImage imageNamed:(self.broadcast)?@"broadcast@gray":@"broadcast@blue"]];
    
}


#pragma mark VK_Autorizing

- (BOOL)isUserLoggedIn {
    if (self.access_token) {
        return YES;
    } else {
        return NO;
    }
}

- (void)login {
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://oauth.vk.com/authorize?client_id=%@&scope=%@&redirect_uri=https://oauth.vk.com/blank.html&display=mobile&v=%@&response_type=token", self.appId, VK_SCOPE, VK_API_VERSION]];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    [self.alertView showAlert:ALERT_CONNECTION_TRY_API withcolor:[NSColor pxColorWithHexValue:COLOR_ALERT_BLUE] autoHide:NO];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest];
    [operation setCompletionBlockWithSuccess: ^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSString *responseUrl = [[[operation response] URL] absoluteString];
        [self.webView setMainFrameURL:responseUrl];
        
    } failure: ^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [self showError:error withType:RSErrorNetwork];
        
    }];
    
    [operation start];
    
}

- (void)logout {
    
    [self.alertView showAlert:ALERT_LOGOUT withcolor:[NSColor pxColorWithHexValue:COLOR_ALERT_BLUE] autoHide:NO];
    
    if (self.access_token) {

        NSString *logoutUrl = self.configuration[@"LOGOUT_URL"];
        NSString *domain = self.configuration[@"DOMAIN"];
        NSString *urlString = [NSString stringWithFormat:@"%@?aid=%@&scope=%@&token=%@&domain=%@", logoutUrl, self.appId, VK_SCOPE, self.access_token, domain];
        NSURL *url = [NSURL URLWithString:urlString];
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest];
        [operation setCompletionBlockWithSuccess: ^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSString *responseHtml = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            NSString *responseUrl = [[[operation response] URL] absoluteString];
            [self.webView setMainFrameURL:responseUrl];
            [[self.webView mainFrame] loadHTMLString:responseHtml baseURL:[[operation response] URL]];
            [self.alertView showAlert:ALERT_CONNECTION_TRY_API withcolor:[NSColor pxColorWithHexValue:COLOR_ALERT_BLUE] autoHide:NO];
            
        } failure: ^(AFHTTPRequestOperation *operation, NSError *error) {
            
            [self showError:error withType:RSErrorNetwork];
            
        }];
        
        [operation start];
        self.access_token = nil;
        self.user_id = nil;
        [self.searchField setEnabled:NO];
        [self.searchField setStringValue:@""];
        self.results = nil;
        [self.resultsTableView reloadData];
        [self updateUsernameAndAvatar];
        
    } else {
        
        [self login];
        NSLog(@"user is already logged out");
        
    }
}

- (void)updateUsernameAndAvatar {
    
    if (self.user_id) {
        
        if (![self internetAvailable]) {
            [self showError:[NSError errorWithDomain:@"" code:-1009 userInfo:nil] withType:RSErrorNetwork];
            return;
        }
        
        NSString *method = @"https://api.vk.com/method/users.get";
        NSDictionary *postParameters = @{  @"user_ids": self.user_id,
                                           @"fields": @"photo_50",
                                           @"v": VK_API_VERSION};
        [self.networkManager POST:method parameters:postParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSMutableDictionary *rootLevel = [responseObject copy];
            NSDictionary *responseLevel = rootLevel[@"response"];
            
            for (NSDictionary *item in responseLevel) {
                NSString *first_name = (NSString *)item[@"first_name"];
                NSString *last_name = (NSString *)item[@"last_name"];
                NSString *photo_50_link = (NSString *)item[@"photo_50"];
                NSImage *photo_50 = [[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:photo_50_link]];
                
                self.username = [NSString stringWithFormat:@"%@ %@",first_name,last_name];
                self.avatar_50 = photo_50;
                
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
           
            [self showError:error withType:RSErrorNetwork];
            
        }];
        
    } else {
        
        self.username = UNKNOWN_USERNAME;
        self.avatar_50 = nil;
        
    }
    
}

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame {
    
    NSString *URLString = [sender mainFrameURL];
    
    if (![URLString isEqualToString:[[[[[sender mainFrame] dataSource] request] URL] absoluteString]]) {
        NSLog(@"webView error: mainURL != requestURL");
    }
    
    NSString *accessPrefix = @"https://oauth.vk.com/blank.html#";
    NSRange rangeOfSuccessPrefix = [URLString rangeOfString:accessPrefix];
    if (rangeOfSuccessPrefix.location != NSNotFound) {
        NSString *URLQuery = [URLString substringFromIndex:rangeOfSuccessPrefix.length];
        NSMutableDictionary *queryStringDictionary = [[NSMutableDictionary alloc] init];
        NSArray *urlComponents = [URLQuery componentsSeparatedByString:@"&"];
        for (NSString *keyValuePair in urlComponents)
        {
            NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
            NSString *key = [pairComponents objectAtIndex:0];
            NSString *value = [pairComponents objectAtIndex:1];
            [queryStringDictionary setObject:value forKey:key];
        }
        
        if ([queryStringDictionary objectForKey:@"access_token"]) {
            self.access_token = [queryStringDictionary objectForKey:@"access_token"];
            self.user_id = [queryStringDictionary objectForKey:@"user_id"];
            [self.searchField setEnabled:YES];
            
            self.results = nil;
            self.unsortedResults = nil;
            self.filteredItems = nil;
            self.shuffleResults = nil;
            [self.resultsTableView reloadData];
            [self makeFirstResponder:self.searchField];
            
            [self hideWebView];
            [self.alertView showAlert:ALERT_CONNECTION_ON withcolor:[NSColor pxColorWithHexValue:COLOR_ALERT_BLUE] autoHide:YES];
            [self trackVisitor];
            [self updateUsernameAndAvatar];
            
        } else  {
            
            self.access_token = nil;
            self.user_id = nil;
            [self.searchField setEnabled:NO];
            [self.searchField setStringValue:@""];
            if ([queryStringDictionary objectForKey:@"error"]) {
                
                if ([[queryStringDictionary objectForKey:@"error"] isEqualToString:@"access_denied"]) {
                    
                    [self.alertView showAlert:ALERT_CONNECTION_VK_DENIED withcolor:[NSColor pxColorWithHexValue:COLOR_ALERT_RED] autoHide:NO];
                    
                } else {
                    
                    NSString *text = [NSString stringWithFormat:@"%@: %@, %@",ALERT_CONNECTION_VK_ERROR,[queryStringDictionary objectForKey:@"error"],[queryStringDictionary objectForKey:@"error_description"]];
                    [self.alertView showAlert:text withcolor:[NSColor pxColorWithHexValue:COLOR_ALERT_RED] autoHide:NO];
                    
                }
                
            } else {

                [self.alertView showAlert:ALERT_CONNECTION_VK_ERROR withcolor:[NSColor pxColorWithHexValue:COLOR_ALERT_RED] autoHide:NO];
            }
            
            [self hideWebView];
            [self login];
            
        }
        
    } else {
        
        [self showWebView];
        
    }
}

- (void)trackVisitor {
    
    if (!TRACKING_VK) {
        return;
    }
    
    NSString *method_trackVisitor = METHOD_TRACKING_URL;
    NSDictionary *addParameters = @{@"v": VK_API_VERSION,
                                    @"access_token": self.access_token};
    
    [self.networkManager POST:method_trackVisitor parameters:addParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // OK!
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"# Unable connect to %@", method_trackVisitor);
        NSLog(@"# Error description: %@", error);
        
    }];
    
}

- (void)updateWebSnapshotFrom:(NSView *)view {
    
    NSRect webViewRect = view.bounds;
    NSSize imgSize = NSMakeSize(webViewRect.size.width, webViewRect.size.height);
    
    NSBitmapImageRep *bir = [view bitmapImageRepForCachingDisplayInRect:webViewRect];
    [bir setSize:imgSize];
    [view cacheDisplayInRect:webViewRect toBitmapImageRep:bir];
    
    NSImage* snapshot = [[NSImage alloc]initWithSize:imgSize];
    [snapshot addRepresentation:bir];
    
    self.webViewSnapshot = [[NSImageView alloc] initWithFrame:view.frame];
    [self.webViewSnapshot setImage:snapshot];
    
}


#pragma mark VK_Search

- (IBAction)searchFieldEnterPressed:(NSTextField *)sender {

    [self startSearchWithPhrase:self.searchField.stringValue];
}

- (void)startSearchWithPhrase:(NSString *)searchPhrase {
    
    if (!self.isUserLoggedIn) {
        [self.alertView showAlert:ALERT_CONNECTION_VK_LOGGEDOUT withcolor:[NSColor pxColorWithHexValue:COLOR_ALERT_RED] autoHide:YES];
        NSLog(@"user is not logged in for search");
        return;
    }
    if (![self internetAvailable]) {
        [self showError:[NSError errorWithDomain:@"" code:-1009 userInfo:nil] withType:RSErrorNetwork];
        return;
    }

    NSString *method;
    NSString *searchMessage;
    NSDictionary *parameters;
    
    if ([searchPhrase isEqualToString:@""]) {
        searchPhrase = SEARCH_CODE_MYMUSIC;
    }
    
    if ([searchPhrase isEqualToString:SEARCH_CODE_MYMUSIC]) {
        [self.searchField setStringValue:@""];
        [[self.searchField cell] setPlaceholderString:@""];
        method = METHOD_AUDIOGET_URL;
        searchMessage = PROCESS_SEARCH_MESSAGE_MYMUSIC;
        parameters = @{@"owner_id": self.user_id,
                       @"offset": @"0",
                       @"count": [NSString stringWithFormat:@"%li",(long)[self myMusicLimit]],
                       @"v": VK_API_VERSION,
                       @"access_token": self.access_token};
        
    } else if ([searchPhrase isEqualToString:SEARCH_CODE_RECOMMEND]) {
        [self.searchField setStringValue:@""];
        [[self.searchField cell] setPlaceholderString:@""];
        method = METHOD_RECOMMEND_URL;
        searchMessage = PROCESS_SEARCH_MESSAGE_RECOMMEND;
        parameters = @{@"shuffle": @"0",
                       @"offset": @"0",
                       @"count": [NSString stringWithFormat:@"%li",(long)[self requestLimit]],
                       @"v": VK_API_VERSION,
                       @"access_token": self.access_token};
        
    } else if ([searchPhrase rangeOfString:@"vk.com/"].location != NSNotFound) {
        
        NSRange rangeOfDomain = [searchPhrase rangeOfString:@"vk.com/"];
        NSUInteger positionOfParametrs = rangeOfDomain.location + rangeOfDomain.length;
        NSString *stringAfterDomain = [searchPhrase substringFromIndex:positionOfParametrs];

        if ([searchPhrase rangeOfString:@"?w="].location != NSNotFound) {
            stringAfterDomain = [[stringAfterDomain componentsSeparatedByString:@"?w="] objectAtIndex:1];
        }
        
        if (stringAfterDomain.length > 4 && [[stringAfterDomain substringWithRange:NSMakeRange(0, 4)] isEqualToString:@"wall"]) {
            
            // wall
            NSString *wall_id = [stringAfterDomain substringFromIndex:4];
            if ([wall_id rangeOfString:@"?"].location != NSNotFound) {
                NSUInteger positionOfFirstSeparator = [wall_id rangeOfString:@"?"].location;
                wall_id = [wall_id substringToIndex:positionOfFirstSeparator];
            }
            if ([wall_id rangeOfString:@"_"].location != NSNotFound) {
                method = METHOD_POSTGET_URL;
                searchMessage = PROCESS_SEARCH_MESSAGE_LINK;
                parameters = @{@"posts": wall_id,
                               @"extended": @"1",
                               @"copy_history_depth": @"2",
                               @"v": VK_API_VERSION};
            
            } else {
                method = METHOD_WALLGET_URL;
                searchMessage = PROCESS_SEARCH_MESSAGE_LINK;
                parameters = @{@"owner_id": wall_id,
                               @"offset": @"0",
                               @"count": @"100",
                               @"v": VK_API_VERSION};
            }
            
        } else if (stringAfterDomain.length > 6 && [[stringAfterDomain substringWithRange:NSMakeRange(0, 6)] isEqualToString:@"audios"]) {
            
            // audios
            NSString *stringAfterAudios = [stringAfterDomain substringFromIndex:6];
            NSString *owner_id = stringAfterAudios;
            
            if ([owner_id rangeOfString:@"?"].location != NSNotFound) {
                NSUInteger positionOfFirstSeparator = [owner_id rangeOfString:@"?"].location;
                owner_id = [owner_id substringToIndex:positionOfFirstSeparator];
            }
            
            // audios->friend
            if ([stringAfterAudios rangeOfString:@"?friend="].location != NSNotFound) {
                NSRange rangeOfFriendSeparator = [stringAfterAudios rangeOfString:@"?friend="];
                NSUInteger positionOfFriend = rangeOfFriendSeparator.location + rangeOfFriendSeparator.length;
                owner_id = [stringAfterAudios substringFromIndex:positionOfFriend];
            }

            method = METHOD_AUDIOGET_URL;
            searchMessage = PROCESS_SEARCH_MESSAGE_LINK;
            parameters = @{@"owner_id": owner_id,
                           @"offset": @"0",
                           @"count": [NSString stringWithFormat:@"%li",(long)[self myMusicLimit]],
                           @"v": VK_API_VERSION,
                           @"access_token": self.access_token};
            
            // album
            NSString *album_id = nil;
            if ([stringAfterAudios rangeOfString:@"?album_id="].location != NSNotFound) {
                NSRange rangeOfAlbumSeparator = [stringAfterAudios rangeOfString:@"?album_id="];
                NSUInteger positionOfAlbumId = rangeOfAlbumSeparator.location + rangeOfAlbumSeparator.length;
                album_id = [stringAfterAudios substringFromIndex:positionOfAlbumId];
                parameters = @{@"owner_id": owner_id,
                               @"album_id": album_id,
                               @"offset": @"0",
                               @"count": [NSString stringWithFormat:@"%li",(long)[self myMusicLimit]],
                               @"v": VK_API_VERSION,
                               @"access_token": self.access_token};
            }
            
            
        } else {
            
            // Получаем ID и тип по тому что после домена
            NSString *method_checkNickname = @"https://api.vk.com/method/utils.resolveScreenName";
            NSDictionary *addParameters = @{@"screen_name": stringAfterDomain,
                                            @"v": VK_API_VERSION};
            [self.networkManager POST:method_checkNickname parameters:addParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                NSString *owner_id = [self vkIdFromJSON:responseObject];
                NSString *method = METHOD_AUDIOGET_URL;
                NSString *searchMessage = PROCESS_SEARCH_MESSAGE_LINK;
                NSDictionary *parameters = @{@"owner_id": owner_id,
                               @"offset": @"0",
                               @"count": [NSString stringWithFormat:@"%li",(long)[self myMusicLimit]],
                               @"v": VK_API_VERSION,
                               @"access_token": self.access_token};
                [self startSearchMethod:method parameters:parameters searchMessage:searchMessage];
                
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                
                [self setSearchProcess:NO];
                [self showError:error withType:RSErrorNetwork];
                
            }];
            return;
            
        }
        
    } else {
        
        // Поисковой запрос
        [self.searchField setStringValue:[searchPhrase clearBadUrlSymbols]];
        method = METHOD_SEARCH_URL;
        searchMessage = PROCESS_SEARCH_MESSAGE_OTHER;
        parameters = @{@"q": searchPhrase,
                       @"auto_complete": [NSString stringWithFormat:@"%li",(long)[[NSUserDefaults standardUserDefaults] integerForKey:kCorrector]],
                       @"lyrics": @"0",
                       @"performer_only": @"0",
                       @"sort": @"0",
                       @"search_own": @"0",
                       @"offset": @"0",
                       @"count": [NSString stringWithFormat:@"%li",(long)[self requestLimit]],
                       @"v": VK_API_VERSION,
                       @"access_token": self.access_token};
    }
    
    [self startSearchMethod:method parameters:parameters searchMessage:searchMessage];
    
}

- (void)startSearchMethod:(NSString *)method parameters:(NSDictionary *)parameters searchMessage:(NSString *)searchMessage {
    
    [self setSearchProcess:YES];
    [self.alertView showAlert:searchMessage withcolor:[NSColor pxColorWithHexValue:COLOR_ALERT_BLUE] autoHide:NO];
    [self.networkManager POST:method parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        self.results = [self audioItemsFromJSON:responseObject];
        self.unsortedResults = [NSArray arrayWithArray:self.results];
        [self sortResults];
        
        NSMutableArray *shuffleResults = [self.results mutableCopy];
        [shuffleResults shuffle];
        self.shuffleResults = shuffleResults;
        self.filteredItems = [NSMutableArray array];
        
        if ([self.resultsTableView numberOfRows] > 0) {
            [self.resultsTableView scrollRowToVisible:0];
        }
        [self setSearchProcess:NO];
        [self updatePlayerUI];
        
        if (self.unsortedResults.count) {
            NSString *text = [NSString stringWithFormat:@"%@ %lu",PROCESS_SEARCH_FIN_TEXT,(unsigned long)self.unsortedResults.count];
            [self.alertView showAlert:text withcolor:[NSColor pxColorWithHexValue:COLOR_ALERT_BLUE] autoHide:YES];
        } else {
            [self.alertView showAlert:PROCESS_SEARCH_EMPTY_TEXT withcolor:[NSColor pxColorWithHexValue:COLOR_ALERT_YELLOW] autoHide:YES];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

        [self setSearchProcess:NO];
        [self showError:error withType:RSErrorNetwork];
        
    }];
    
}

- (void)setSearchProcess:(BOOL)searchProcess {
    
    [self.searchField setEnabled:!searchProcess];
    [self.altSearchButton setHidden:searchProcess];
    [self.searchProcessAnimatedIcon setHidden:!searchProcess];
    
    if (searchProcess) {
        
        self.searchProcessAnimatedIcon.layer.position = CGPointMake(self.searchProcessAnimatedIcon.frame.origin.x+self.searchProcessAnimatedIcon.frame.size.width/2, self.searchProcessAnimatedIcon.frame.origin.y+self.searchProcessAnimatedIcon.frame.size.height/2);
        self.searchProcessAnimatedIcon.layer.anchorPoint = CGPointMake(0.5f, 0.5f);
        [self startRefreshAnimation];
        
    } else {
        
        [self makeFirstResponder:self.searchField];
        [[self.searchField cell] setPlaceholderString:@"Что будем искать?"];
        [self.searchProcessAnimatedIcon.layer removeAllAnimations];
    }
    
}

- (void)startRefreshAnimation {
 
    CABasicAnimation *rotateAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    rotateAnimation.fromValue = [NSNumber numberWithDouble:0.0f];
    rotateAnimation.toValue = [NSNumber numberWithDouble:(M_PI * 2.0f)];
    rotateAnimation.duration = 1.5f;
    rotateAnimation.delegate = self;
    [rotateAnimation setAutoreverses:NO];
    [rotateAnimation setRepeatCount:1]; // Perfrom animation 1 time
    [self.searchProcessAnimatedIcon.layer addAnimation:rotateAnimation forKey:@"transform"];
    
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    
    if (![self.searchProcessAnimatedIcon isHidden]) {
        [self startRefreshAnimation];
    }

}

- (NSString *)vkIdFromJSON:(NSDictionary *)JSONdata {
    
    NSMutableDictionary *rootLevel = [JSONdata copy];
    
    if (![rootLevel objectForKey:@"response"]) { return @"id1"; }
    NSDictionary *responseLevel = rootLevel[@"response"];
    
    if (![responseLevel isKindOfClass:[NSDictionary class]] || ![responseLevel objectForKey:@"object_id"]) { return @"1"; }
    NSString *vkId = responseLevel[@"object_id"];
    NSString *idType = responseLevel[@"type"];
    
    if ([idType isEqualToString:@"group"]) {
        vkId = [NSString stringWithFormat:@"-%@",vkId];
    }
    
    return vkId;
    
}

- (NSArray *)audioItemsFromJSON:(NSDictionary *)JSONdata {
    
    NSMutableArray *arrayOfAudioItems = [[NSMutableArray alloc] init];
    NSMutableDictionary *rootLevel = [JSONdata copy];

    
    if ([self checkResponseForError:rootLevel]) {
        return @[];
    }
    
    NSDictionary *responseLevel = rootLevel[@"response"];
    
    if (![responseLevel objectForKey:@"items"]) { return @[]; }
    NSDictionary *itemsLevel = responseLevel[@"items"];
    
    for (NSDictionary *item in itemsLevel) {
        
        if ([item objectForKey:@"duration"]) {
            
            RSAudioItem *audioItem = [self audioItemFromJSONItem:item];
            [arrayOfAudioItems addObject:audioItem];
            
        } else if ([item objectForKey:@"post_type"]) {
            
            if ([item objectForKey:@"attachments"]) {
                NSDictionary *attachmentsLevel = item[@"attachments"];
                for (NSDictionary *attachment in attachmentsLevel) {
                    if ([[attachment objectForKey:@"type"] isEqualToString:@"audio"]) {
                        RSAudioItem *audioItem = [self audioItemFromJSONItem:[attachment objectForKey:@"audio"]];
                        [arrayOfAudioItems addObject:audioItem];
                    }
                }
            }
            
            if ([item objectForKey:@"copy_history"]) {
                NSArray *arrayOfHistory = item[@"copy_history"];
                
                for (NSDictionary *historyLevel in arrayOfHistory) {
                    
                    if ([historyLevel objectForKey:@"attachments"]) {
                        NSDictionary *attachmentsLevel = historyLevel[@"attachments"];
                        for (NSDictionary *attachment in attachmentsLevel) {
                            
                            if ([[attachment objectForKey:@"type"] isEqualToString:@"audio"]) {
                                RSAudioItem *audioItem = [self audioItemFromJSONItem:[attachment objectForKey:@"audio"]];
                                [arrayOfAudioItems addObject:audioItem];
                            }
                        }
                    }

                }
                
            }

        }
        
    }
    
    // Отправим запросы на размеры файлов
    [[self.networkManager operationQueue] setMaxConcurrentOperationCount:MAX_NETWORK_CONCURRENT_OPERATION_COUNT];
    for (RSAudioItem *audioItem in arrayOfAudioItems) {
        
        [self.networkManager HEAD:audioItem.url parameters:nil success:^(AFHTTPRequestOperation *operation) {
            [self didReceiveResponse:[operation response] forVkID:audioItem.vkID];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//            [self.alertView showAlert:ALERT_CONNECTION_FILESIZE_ERROR withcolor:[NSColor pxColorWithHexValue:COLOR_ALERT_YELLOW] autoHide:YES];
            NSLog(@"Error: %@", error);
        }];
        
    }
    
    return arrayOfAudioItems;
    
}

- (RSAudioItem *)audioItemFromJSONItem:(NSDictionary *)item {
 
    int duration = [(NSString *)item[@"duration"] intValue];
    NSString *vkID = [(NSNumber *)item[@"id"] stringValue];
    NSString *owner_id = [(NSNumber *)item[@"owner_id"] stringValue];
    NSString *clearVkUrl = [(NSString *)item[@"url"] componentsSeparatedByString:@"?"][0];
    
    RSAudioItem *audioItem = [RSAudioItem initWithArtist:item[@"artist"]
                                                   title:item[@"title"]
                                                duration:duration
                                                    kbps:0
                                                    size:0
                                                     url:clearVkUrl
                                                    vkID:vkID
                                                owner_id:owner_id
                                               addedToVK:NO];
    return audioItem;
    
}

- (void)didReceiveResponse:(NSHTTPURLResponse *)response forVkID:(NSString *)vkID {
    
    RSAudioItem *audioItem = nil;
    
    for (RSAudioItem *sortedAudioItem in self.results) {
        if ([sortedAudioItem.vkID isEqualToString: vkID]) {
                audioItem = sortedAudioItem;
        }
    }
    
    if (!audioItem) {
        return;
    }
    
    long long filesize = [response expectedContentLength];
    audioItem.size = filesize;

    NSInteger bitrate = (audioItem.duration)?(int)filesize/(int)audioItem.duration*8/1000/FILTER_KBPS_STEP:0;
    bitrate = bitrate * FILTER_KBPS_STEP;
    
    if (bitrate > 0 && bitrate < [[[NSUserDefaults standardUserDefaults] objectForKey:kFilterKbps] integerValue]) {
        NSMutableArray *mutableResults = [self.results mutableCopy];
        NSMutableArray *mutableUnsortedResults = [self.unsortedResults mutableCopy];
        [mutableResults removeObject:audioItem];
        [mutableUnsortedResults removeObject:audioItem];
        self.results = mutableResults;
        self.unsortedResults = mutableUnsortedResults;
        [self.filteredItems addObject:audioItem];
        [self.alertView showAlert:[NSString stringWithFormat:@"%@ %lu (%@ %lu)",PROCESS_SEARCH_FIN_TEXT, (unsigned long)self.results.count, PROCESS_SEARCH_FIN_FILTER, (unsigned long)self.filteredItems.count] withcolor:[NSColor pxColorWithHexValue:COLOR_ALERT_BLUE] autoHide:YES];
        [self.resultsTableView reloadData];
        
        return;
    }
    
    audioItem.kbps = bitrate;
    
    NSSortDescriptor *sortDesctiptor;
    if (self.resultsTableView.sortDescriptors.count > 0) {
        sortDesctiptor = [self.resultsTableView sortDescriptors][0];
    }
    
    if ((sortDesctiptor) &&
        (([sortDesctiptor.key isEqualToString:@"kbps"]) || ([sortDesctiptor.key isEqualToString:@"size"]))) {
        [self sortResults];
        
    } else {
        
        [self.resultsTableView reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:[self.results indexOfObject:audioItem]] columnIndexes:[NSIndexSet indexSetWithIndex:[self.resultsTableView columnWithIdentifier:@"Size"]]];
        [self.resultsTableView reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:[self.results indexOfObject:audioItem]] columnIndexes:[NSIndexSet indexSetWithIndex:[self.resultsTableView columnWithIdentifier:@"Kbps"]]];
    }
    
}


#pragma mark VK Other Methods

- (void)setBroadcast:(BOOL)broadcast {
    
    _broadcast = broadcast;
    [self updateVKMusicTranslate];
}

- (void)updateVKMusicTranslate {
        
    NSString *owner_audio = @"";
    if (self.broadcast) {
        owner_audio = [NSString stringWithFormat:@"%@_%@", self.currentAudioItem.owner_id, self.currentAudioItem.vkID];
    }
    
    // Установить в ВК музыкальный статус
    if (self.access_token && self.user_id) {
        
        NSString *method_audioBroadcast = @"https://api.vk.com/method/audio.setBroadcast";
        NSDictionary *addParameters = @{@"audio": owner_audio,
                                        @"v": VK_API_VERSION,
                                        @"access_token": self.access_token};
        [self.networkManager POST:method_audioBroadcast parameters:addParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            if ([self checkResponseForError:responseObject]) {
                [self.alertView showAlert:(self.broadcast)? ALERT_BROADCAST_ON : ALERT_BROADCAST_OFF withcolor:[NSColor pxColorWithHexValue:COLOR_ALERT_BLUE] autoHide:YES];
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            NSLog(@"# Unable connect to %@", method_audioBroadcast);
            NSLog(@"# Error description: %@", error);
            [self showError:error withType:RSErrorNetwork];
            
        }];
    }
    
}

- (BOOL)checkResponseForError:(NSDictionary *)rootLevel {
    
    BOOL error = NO;
    
    if ([rootLevel objectForKey:@"error"]) {

        error = YES;
        [self.alertView showAlert:[NSString stringWithFormat:@"Ошибка API: %@ (vk.com/dev/errors)", [rootLevel objectForKey:@"error_code"]] withcolor:[NSColor pxColorWithHexValue:COLOR_ALERT_RED] autoHide:YES];
        NSLog(@"VK API Error Code: %@, description: %@", [rootLevel objectForKey:@"error_code"], [rootLevel objectForKey:@"error_msg"]);
        
    }
    
    return error;
    
}

- (void)showError:(NSError *)error withType:(RSErrorType)errorType {
    
    if (errorType == RSErrorNetwork) {

        NSLog(@"###NETWORK_ERROR: %@", error.description);
        if (error.code == -1009) {
            [self.alertView showAlert:ALERT_CONNECTION_OFF withcolor:[NSColor pxColorWithHexValue:COLOR_ALERT_RED] autoHide:NO];
        } else {
            NSString *text = [NSString stringWithFormat:@"%@. Код: %li", ALERT_CONNECTION_OFF_UNKNOWN, error.code];
                [self.alertView showAlert:text withcolor:[NSColor redColor] autoHide:YES];
        }
        
    } else if (errorType == RSErrorVK) {
        
        NSLog(@"###VK_ERROR %li,: %@",(long)error.code, error.description);
        
    }
    
}


#pragma mark TableView Delegate Methods

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    
    if ([[notification object] isEqualTo:self.downloadsTableView]) {
        [self updateDownloadsButtons];
    }
    
    if ([[notification object] isEqualTo:self.resultsTableView]) {
        
        [self updateAddListButton];
    }
    
    
}

- (void)tableViewSelectionIsChanging:(NSNotification *)notification {
    
    if ([[notification object] isEqualTo:self.downloadsTableView]) {
        [self updateDownloadsButtons];
    }
    
    if ([[notification object] isEqualTo:self.resultsTableView]) {
        
        [self updateAddListButton];
    }
    
    
}

- (void)updateAddListButton {
    
    [self.AddListButton setEnabled:NO];
    NSIndexSet *selectedIndexes = [self.resultsTableView selectedRowIndexes];
    
    if ([selectedIndexes count] > 1) {
        
        NSInteger readyForDownloadCount = [selectedIndexes count];
        for (RSAudioItem *audioItem in self.results) {
            if ([selectedIndexes containsIndex:[self.results indexOfObject:audioItem]]) {
                
                if (audioItem.inDownloads) {
                    readyForDownloadCount--;
                }
                
            }
        }
        
        if (readyForDownloadCount > 1) {
            [self.AddListButton setEnabled:YES];
        }
        
    }
    
}

- (void)flagsChanged:(NSEvent *)theEvent {
    
    if([theEvent modifierFlags] & NSAlternateKeyMask)
    {
        [self.funcKeysPressedNow setObject:[NSNumber numberWithBool:YES] forKey:@"alt"];
    }
    else if([theEvent keyCode] == 58 || [theEvent keyCode] == 61)
    {
        [self.funcKeysPressedNow setObject:[NSNumber numberWithBool:NO] forKey:@"alt"];
    }
    
    [super flagsChanged:theEvent];
}

- (void)doubleClickOnResult:(id)sender {
    
    NSInteger rowNumber = [self.resultsTableView clickedRow];
    if (rowNumber < 0) { return; }
    
    RSActionsCell *clickedActionsView = [self.resultsTableView viewAtColumn:[self.resultsTableView columnWithIdentifier:@"Actions"] row:rowNumber makeIfNecessary:YES];
    
    if ([[NSUserDefaults standardUserDefaults] integerForKey:kDoubleClickDownload] == 0 && [[self.funcKeysPressedNow objectForKey:@"alt"] boolValue] != YES) {
        
        [self playFromActionsCell:clickedActionsView];
        
    } else {
        
        [self addDownloadFromAudioItem:clickedActionsView.audioItem];
        
    }
    
}

- (void)doubleClickOnDownload:(id)sender {
    
    NSInteger rowNumber = [self.downloadsTableView clickedRow];
    if (rowNumber < 0) { return; }
    
    RSDownloadItem *downloadItem = [self.downloads objectAtIndex:rowNumber];
    
    if (downloadItem.status == RSDownloadCompleted) {
        
        NSURL *fileURL = [NSURL fileURLWithPath: downloadItem.path];
        [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:@[fileURL]];
    }
    
}

- (void)tableView:(NSTableView *)tableView sortDescriptorsDidChange:(NSArray *)oldDescriptors {
    
    if ([tableView isEqual:self.downloadsTableView]) {
        return;
    }
    
    NSSortDescriptor *newSortDescriptor;
    if (self.resultsTableView.sortDescriptors.count > 0) {
        newSortDescriptor = self.resultsTableView.sortDescriptors[0];
    }
    
    if (self.resultsTableView.sortDescriptors.count > 1) {
        self.resultsTableView.sortDescriptors = @[newSortDescriptor];
        return; //because it autocall again, when we set new sortdescriptors;
    }
    
    if ((oldDescriptors.count == 1) && (self.resultsTableView.sortDescriptors.count == 1)) {
        
        NSSortDescriptor *oldSortDescriptor = oldDescriptors[0];
        if ([oldSortDescriptor.key isEqualToString:newSortDescriptor.key]) {
            if (newSortDescriptor.ascending) {
                self.resultsTableView.sortDescriptors = @[];
                return; //because it autocall again, when we set new sortdescriptors;
            }
        }
        
    }
    
    if (self.resultsTableView.sortDescriptors && self.resultsTableView.sortDescriptors.count > 0) {
        newSortDescriptor = [self.resultsTableView.sortDescriptors objectAtIndex:0];
        [[NSUserDefaults standardUserDefaults] setObject:newSortDescriptor.key forKey:kSortDescriptorColumn];
        [[NSUserDefaults standardUserDefaults] setBool:newSortDescriptor.ascending forKey:kSortDescriptorAscending];
    } else {
        [[NSUserDefaults standardUserDefaults] setObject:@"default" forKey:kSortDescriptorColumn];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kSortDescriptorAscending];
    }
    
    [self sortResults];
    
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    
    if ([tableView isEqual:self.resultsTableView]) {
        return [self.results count];
    } else if ([tableView isEqual:self.downloadsTableView]) {
        return [self.downloads count];
    }
    
    NSLog(@"error: numberOfRowsInTableView = 0");
    return 0;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    
    NSString *identifier = [tableColumn identifier];
    
    if ([tableView isEqual:self.resultsTableView]) {
        
        RSAudioItem *audioItem = (RSAudioItem *)self.results[row];
        
        if ([identifier isEqualToString:@"Actions"]) {
            
            RSActionsCell *actionsCell = [tableView makeViewWithIdentifier:identifier owner:self];
            actionsCell.audioItem = audioItem;
            actionsCell.delegate = self;
            [actionsCell setPlay: ([audioItem.url isEqual:self.currentAudioItem.url] && self.player.rate > 0.0f)];
            
            if (row == self.resultsTableView.hoverRow) {
                [actionsCell.downloadButton setImage:actionsCell.downloadButton.alternateImage];
                [actionsCell.playButton setImage:actionsCell.playButton.alternateImage];
            } else {
                if ([self currentAudioRow] == row) {
                    self.currentAudioItem = audioItem;
                    [actionsCell.playButton setImage:actionsCell.playButton.alternateImage];
                }
            }
            
            [actionsCell.downloadButton setHidden:audioItem.inDownloads];

            return actionsCell;
            
        } else {
            
            RSTextCell *textCell = [tableView makeViewWithIdentifier:identifier owner:self];
            if ([identifier isEqualToString:@"Artist"]) [textCell.textField setStringValue:audioItem.artist];
            if ([identifier isEqualToString:@"Title"]) [textCell.textField setStringValue:audioItem.title];
            if ([identifier isEqualToString:@"Duration"]) {
                [textCell.textField setStringValue:[self stringFromDuration:audioItem.duration]];
            }
            if ([identifier isEqualToString:@"Kbps"]) {
                if (audioItem.kbps) {
                    [textCell.textField setStringValue:[NSString stringWithFormat:@"%li kbps", audioItem.kbps]];
                } else {
                    [textCell.textField setStringValue:(row == self.resultsTableView.hoverRow)?@"?":@""];
                }
            }
            if ([identifier isEqualToString:@"Size"]) {
                if (audioItem.size) {
                    [textCell.textField setStringValue:[NSString stringWithFormat:@"%.2f Мб",(float)audioItem.size/1024/1024]];
                } else {
                    [textCell.textField setStringValue:(row == self.resultsTableView.hoverRow)?@"?":@""];
                }

            }

            return textCell;
            
        }
        
    } else if ([tableView isEqual:self.downloadsTableView]) {
        
        RSDownloadItem *downloadItem = (RSDownloadItem *)self.downloads[row];
        
        if ([identifier isEqualToString:@"DownloadBar"]) {
            
            RSDownloadCell *downloadCell = [tableView makeViewWithIdentifier:identifier owner:self];
            downloadCell.progress = (float)downloadItem.sizeDownloaded / (float)downloadItem.size;
            NSString *progressString = @"В очереди";
            if (downloadItem.status == RSDownloadReady) {
                progressString = [NSString stringWithFormat:@"В очереди"];
            } else if (downloadItem.status == RSDownloadAddedJustNow) {
                progressString = @"Подключение...";
            } else if (downloadItem.status == RSDownloadInProgress) {
                [downloadCell setBarColor:[NSColor pxColorWithHexValue:COLOR_BAR_BLUE]];
                progressString = [NSString stringWithFormat:@"%.2f Мб [%.0f%%]",(float)downloadItem.sizeDownloaded/1024/1024, downloadCell.progress*100];
            } else if (downloadItem.status == RSDownloadPause) {
                [downloadCell setBarColor:[NSColor pxColorWithHexValue:COLOR_BAR_YELLOW]];
                progressString = [NSString stringWithFormat:@"Пауза %.2f Мб [%.0f%%]", (float)downloadItem.sizeDownloaded/1024/1024, downloadCell.progress*100];
            } else if (downloadItem.status == RSDownloadCompleted) {
                [downloadCell setBarColor:[NSColor pxColorWithHexValue:COLOR_BAR_GREEN]];
                progressString = [NSString stringWithFormat:@"%.2f Мб", (float)downloadItem.size/1024/1024];
            }
            [downloadCell.textField setStringValue:progressString];
            
            return downloadCell;
            
        } else {
            
            NSTableCellView *cellView = [tableView makeViewWithIdentifier:identifier owner:self];
            if ([identifier isEqualToString:@"File"]) {
                if ([[NSUserDefaults standardUserDefaults] integerForKey:kUseFullPaths] == 0) {
                    [cellView.textField setStringValue:[downloadItem.path lastPathComponent]];
                } else {
                    [cellView.textField setStringValue:downloadItem.path];
                }
            }
            if ([identifier isEqualToString:@"Duration"]) {
                NSUInteger h = (int)downloadItem.duration / 3600;
                NSUInteger m = ((int)downloadItem.duration / 60) % 60;
                NSUInteger s = (int)downloadItem.duration % 60;
                NSString *durationSring = [NSString stringWithFormat:@"%lu:%02lu:%02lu", (unsigned long)h, (unsigned long)m, (unsigned long)s];
                if (h <1) {
                    durationSring = [NSString stringWithFormat:@"%02lu:%02lu", (unsigned long)m, (unsigned long)s];
                }
                [cellView.textField setStringValue:durationSring];
            }
            if ([identifier isEqualToString:@"Kbps"]) {
                [cellView.textField setStringValue:[NSString stringWithFormat:@"%li kbps",downloadItem.kbps]];
            }
            if ([identifier isEqualToString:@"Size"]) {
                [cellView.textField setStringValue:[NSString stringWithFormat:@"%.2f Mб",(float)downloadItem.size/1024/1024]];
            }
            return cellView;
            
        }
        
    }
    
    NSLog(@"error: viewForTableColumn = nil");
    return nil;
    
}

- (NSTableRowView *)tableView:(NSTableView *)tableView
                rowViewForRow:(NSInteger)row {
    static NSString* const kRowIdentifier = @"RowView";
    RSRowView* rowView = [tableView makeViewWithIdentifier:kRowIdentifier owner:self];
    if (!rowView) {
        // Size doesn't matter, the table will set it
        rowView = [[RSRowView alloc] initWithFrame:NSZeroRect];
        
        // This seemingly magical line enables your view to be found
        // next time "makeViewWithIdentifier" is called.
        rowView.identifier = kRowIdentifier;
    }
    
    [rowView setDelegate:self];
    // Can customize properties here. Note that customizing
    // 'backgroundColor' isn't going to work at this point since the table
    // will reset it later. Use 'didAddRow' to customize if desired.
    
    return rowView;
}

- (void)sortResults {
    
    NSArray *sortResults = self.unsortedResults;
    
    if (self.resultsTableView.sortDescriptors.count > 0) {
        sortResults = [sortResults sortedArrayUsingDescriptors:[self.resultsTableView sortDescriptors]];
    }
    
    self.results = sortResults;
    [self.resultsTableView reloadData];
    [self updatePlayerUI];
    
}


@end