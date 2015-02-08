//
//  RSOptionsWindow.h
//  VK320
//
//  Created by Roman Silin on 12.07.14.
//  Copyright (c) 2014 Roman Silin. All rights reserved.
//

#import "RSNumberFormatter.h"
#import "Protocols.h"
#import "ITSwitch.h"
#import "NSColor+PXExtentions.h"

@interface RSOptionsWindow : NSWindow <NSTextFieldDelegate>

@property (weak) IBOutlet NSTextField *downloadsPathField;
@property (weak) IBOutlet NSTextField *requestLimitField;
@property (weak) IBOutlet NSTextField *myMusicLimitField;
@property (weak) IBOutlet NSTextField *streamsLimitField;
@property (weak) IBOutlet ITSwitch *fullPathCheckbox;
@property (weak) IBOutlet ITSwitch *saveHistoryCheckbox;
@property (weak) IBOutlet ITSwitch *doubleClickCheckbox;
@property (weak) IBOutlet ITSwitch *autoplayCheckbox;
@property (weak) IBOutlet ITSwitch *correctorCheckbox;
@property (weak) IBOutlet ITSwitch *checkUpdatesCheckbox;
@property (weak) IBOutlet NSSlider *filterKbpsSlider;
@property (weak) IBOutlet NSTextField *filterKbpsField;
@property (weak) IBOutlet NSTextField *currentUser;
@property (unsafe_unretained) IBOutlet NSImageView *avatarView;

- (IBAction)checkValues:(id)sender;

@end
