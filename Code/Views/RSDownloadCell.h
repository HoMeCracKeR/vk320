//
//  RSDownloadCell.h
//  VK320
//
//  Created by Roman Silin on 13.07.14.
//  Copyright (c) 2014 Roman Silin. All rights reserved.
//

#import "RSDownloadItem.h"
#import "Protocols.h"
#import "NSColor+PXextentions.h"

@interface RSDownloadCell : NSTableCellView

@property float progress; // from 0.0 to 1.0
@property (strong, nonatomic) NSColor *barColor;
@property (weak, nonatomic) IBOutlet NSTextField *sizeField;

@end
