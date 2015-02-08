//
//  RSAppDelegate.h
//  VK320
//
//  Created by Roman Silin on 20.06.14.
//  Copyright (c) 2014 Roman Silin. All rights reserved.
//

#import "RSMainWindow.h"
#import "RSOptionsWindow.h"
#import "Protocols.h"
#import "NSImage+Rotate.h"

@interface RSAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet RSMainWindow *window;
@property (assign) IBOutlet RSOptionsWindow *sheet;
@property (nonatomic) BOOL optionsMenuEnabled;


- (IBAction)activateSheet:(id)sender;
- (IBAction)closeSheet:(id)sender;

@end
