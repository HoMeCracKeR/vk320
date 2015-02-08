//
//  RSResultsTableView.h
//  VK320
//
//  Created by Roman Silin on 17.07.14.
//  Copyright (c) 2014 Roman Silin. All rights reserved.
//

#import "RSActionsCell.h"
#import "RSRowView.h"
#import "Protocols.h"

@interface RSResultsTableView : NSTableView

@property (nonatomic) NSTrackingArea *trackingArea;
@property (nonatomic) BOOL mouseInView;
@property (nonatomic) NSInteger hoverRow;
@property (nonatomic) NSInteger prevRow;

@end
