//
//  RSMainWindow.h
//  VK320
//
//  Created by Roman Silin on 20.06.14.
//  Copyright (c) 2014 Roman Silin. All rights reserved.
//

#import "RSAudioItem.h"
#import "RSActionsCell.h"
#import "RSDownloadItem.h"
#import "RSDownloadCell.h"
#import "Protocols.h"
#import "NSString+Bonus.h"
#import "RSResultsTableView.h"
#import "RSRowView.h"
#import "AFNetworking.h"
#import "RSTextCell.h"
#import "GRCustomizableWindow.h"
#import "LADSlider.h"
#import "NSImage+Rotate.h"
#import "HoverButtonView.h"
#import "NSColor+PXExtentions.h"
#import "RSHandScrollView.h"
#import "ScrollingTextView.h"
#import "RSAlertView.h"
#import "AVPlayer+Bonus.h"
#import "NSMutableArray+Shuffle.h"

@interface RSMainWindow : GRCustomizableWindow <NSTableViewDataSource, NSTableViewDelegate, RSPlayer, NSWindowDelegate, NSSplitViewDelegate, NSURLConnectionDelegate>

@property (weak) IBOutlet NSTextField *searchField;
@property (weak) IBOutlet WebView *webView;
@property (strong, nonatomic) NSString *access_token;
@property (strong, nonatomic) NSString *user_id;
@property (nonatomic) BOOL isUserLoggedIn;
@property (strong, nonatomic) NSImageView *webViewSnapshot;
@property (strong, nonatomic) RSAudioItem *currentAudioItem;
@property (strong, nonatomic) NSArray *unsortedResults;
@property (strong, nonatomic) NSMutableArray *filteredItems;
@property (nonatomic) BOOL shuffle;
@property(strong, nonatomic) NSString *appId;
@property (strong, nonatomic) NSDictionary *configuration;

@property (weak) IBOutlet HoverButtonView *likeButton;
@property (weak) IBOutlet HoverButtonView *playerPrevButton;
@property (weak) IBOutlet HoverButtonView *playerPlayPauseButton;
@property (weak) IBOutlet HoverButtonView *playerNextButton;
@property (weak) IBOutlet NSTextField *playerTime1;
@property (weak) IBOutlet LADSlider *playerTrackSlider;
@property (weak) IBOutlet NSTextField *playerTime2;
@property (weak) IBOutlet LADSlider *playerVolumeSlider;
@property (strong, nonatomic) id playbackTimeObserver;
@property (strong, nonatomic) NSTimer *cacheUpdateTimer;
@property (weak) IBOutlet NSButton *playerShuffleButton;

@property (weak) IBOutlet NSButton *broadcastButton;

@property (weak) IBOutlet HoverButtonView *playerDownloadButton;
@property (weak) IBOutlet HoverButtonView *playerAddToVKButton;
@property (weak) IBOutlet ScrollingTextView *trackTitle;
@property (nonatomic) BOOL broadcast;

@property (weak) IBOutlet HoverButtonView *downloadsStartButton;
@property (weak) IBOutlet HoverButtonView *downloadsPauseButton;
@property (weak) IBOutlet HoverButtonView *downloadsRemoveButton;
@property (weak) IBOutlet HoverButtonView *downloadsSelectAllButton;
@property (weak) IBOutlet HoverButtonView *AddListButton;
@property (nonatomic) BOOL downloadsMenuOperationsEnabled;

@property (weak) IBOutlet NSSplitView *splitView;
@property (weak) IBOutlet NSScrollView *resultsScrollView;
@property (weak) IBOutlet NSScrollView *downloadsScrollView;
@property (weak) IBOutlet NSView *downloadsView;

@property (strong, nonatomic) AVPlayer *player;
@property (strong, nonatomic) AVPlayerItem *playerItem;
@property (weak) IBOutlet RSResultsTableView *resultsTableView;
@property (weak) IBOutlet NSTableView *downloadsTableView;
@property (strong, nonatomic) NSArray *results; //of RSAudioItems
@property (strong, nonatomic) NSMutableArray *downloads; //of RSDownloadItem
@property (strong, nonatomic) NSArray *shuffleResults; //of RSAudioItems
@property (strong, nonatomic) AFHTTPRequestOperationManager *networkManager;
@property (weak) IBOutlet RSAlertView *alertView;
@property (nonatomic) BOOL internetAvailable;
@property (nonatomic) BOOL searchProcess;

@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSImage *avatar_50;

@property (weak) IBOutlet NSView *altSearchView;
@property (weak) IBOutlet HoverButtonView *altSearchButton;
@property (weak) IBOutlet NSImageView *searchProcessAnimatedIcon;

@property (nonatomic, strong) NSMutableDictionary *funcKeysPressedNow;


- (void)logout;
- (void)playFromActionsCell:(RSActionsCell *)actionsCell;
- (void)endOfTrack;
- (void)updateDownloadItem:(RSDownloadItem *)downloadItem;
- (void)updateAfterCloseSettings;
- (void)sortResults;
- (void)updateDownloadsButtons;
- (void)updateVKMusicTranslate;
- (void)showError:(NSError *)error withType:(RSErrorType)errorType;

- (IBAction)clickPlayerPlayPause:(id)sender;
- (IBAction)clickPlayerPrev:(id)sender;
- (IBAction)clickPlayerNext:(id)sender;

@end
