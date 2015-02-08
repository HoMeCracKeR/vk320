//
//  RSRowView.h
//  VK320
//
//  Created by Roman Silin on 17.07.14.
//  Copyright (c) 2014 Roman Silin. All rights reserved.
//

#import "NSColor+PXExtentions.h"
#import "Protocols.h"

@interface RSRowView : NSTableRowView

@property (weak, nonatomic) id <RSPlayer> delegate;

@end
