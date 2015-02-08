//
//  RSOptionsWindow.m
//  VK320
//
//  Created by Roman Silin on 12.07.14.
//  Copyright (c) 2014 Roman Silin. All rights reserved.
//

#import "RSOptionsWindow.h"
@class RSAppDelegate;

@implementation RSOptionsWindow

- (void)awakeFromNib {

    [self.requestLimitField setFormatter:[RSNumberFormatter initWithLength:[REQUEST_MAX_LIMIT length]]];
    [self.myMusicLimitField setFormatter:[RSNumberFormatter initWithLength:[MYMUSIC_MAX_LIMIT length]]];
    [self.streamsLimitField setFormatter:[RSNumberFormatter initWithLength:[STREAMS_MAX_LIMIT length]]];
    
    [self.saveHistoryCheckbox setTintColor:[NSColor pxColorWithHexValue:COLOR_BUTTON_BLUE]];
    [self.autoplayCheckbox setTintColor:[NSColor pxColorWithHexValue:COLOR_BUTTON_BLUE]];
    [self.correctorCheckbox setTintColor:[NSColor pxColorWithHexValue:COLOR_BUTTON_BLUE]];
    [self.fullPathCheckbox setTintColor:[NSColor pxColorWithHexValue:COLOR_BUTTON_BLUE]];
    [self.doubleClickCheckbox setTintColor:[NSColor pxColorWithHexValue:COLOR_BUTTON_BLUE]];
    [self.checkUpdatesCheckbox setTintColor:[NSColor pxColorWithHexValue:COLOR_BUTTON_BLUE]];

    [[self.requestLimitField cell] setPlaceholderString:REQUEST_DEFAULT_LIMIT];
    [[self.myMusicLimitField cell] setPlaceholderString:MYMUSIC_DEFAULT_LIMIT];
    [[self.streamsLimitField cell] setPlaceholderString:STREAMS_DEFAULT_LIMIT];
    
}

- (IBAction)choosePath:(id)sender {
    
    NSOpenPanel* panel = [NSOpenPanel openPanel];
    [panel setCanChooseDirectories:YES];
    [panel setCanCreateDirectories:YES];
    [panel setCanChooseFiles:NO];
    [panel setResolvesAliases:YES];
    [panel setAllowsMultipleSelection:NO];
    [panel setDirectoryURL:[NSURL URLWithString:self.downloadsPathField.stringValue]];
    
    [panel beginSheetModalForWindow:self completionHandler:^(NSInteger result){
        if (result == NSFileHandlingPanelOKButton) {
            [self.downloadsPathField setStringValue:[[panel URL] path]];
        }
    }];
    
}

- (IBAction)checkValues:(id)sender {

    if ([self.requestLimitField.stringValue intValue] > [REQUEST_MAX_LIMIT intValue]) {
        [self.requestLimitField setStringValue:REQUEST_MAX_LIMIT];
    }
    if ([self.streamsLimitField.stringValue intValue] > [STREAMS_MAX_LIMIT intValue]) {
        [self.streamsLimitField setStringValue:STREAMS_MAX_LIMIT];
    }
    if ([self.myMusicLimitField.stringValue intValue] > [MYMUSIC_MAX_LIMIT intValue]) {
            [self.myMusicLimitField setStringValue:MYMUSIC_MAX_LIMIT];
    }
    
    if ([self.requestLimitField.stringValue intValue] == 0) {
        [self.requestLimitField setStringValue:@""];
    }
    if ([self.streamsLimitField.stringValue intValue] == 0) {
        [self.streamsLimitField setStringValue:@""];
    }
    if ([self.myMusicLimitField.stringValue intValue] == 0) {
        [self.myMusicLimitField setStringValue:@""];
    }
    
    [self.filterKbpsField setStringValue:[NSString stringWithFormat:@"%i Kbps", (int)self.filterKbpsSlider.doubleValue*FILTER_KBPS_STEP]];
    
    
    [self makeFirstResponder:self.downloadsPathField];
    
}

- (IBAction)openWWW:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL: [NSURL URLWithString:VK320_URL]];
}


@end
