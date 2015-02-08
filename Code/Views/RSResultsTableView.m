//
//  RSResultsTableView.m
//  VK320
//
//  Created by Roman Silin on 17.07.14.
//  Copyright (c) 2014 Roman Silin. All rights reserved.
//

#import "RSResultsTableView.h"

@implementation RSResultsTableView

#pragma mark General

- (void)awakeFromNib
{
	[[self window] setAcceptsMouseMovedEvents:YES];
	self.hoverRow = -1;
	self.prevRow = -1;
}

- (void)updateTrackingAreas {
    
    if (self.trackingArea != nil) {
        [self removeTrackingArea:self.trackingArea];
    }
    
    int opts = (NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways | NSTrackingMouseMoved);
    self.trackingArea = [[NSTrackingArea alloc] initWithRect:[self bounds]
                                                     options:opts
                                                       owner:self
                                                    userInfo:nil];
    // NSLog(@"tracking area updated: (%f:%f) (%f:%f)", self.trackingArea.rect.origin.x, self.trackingArea.rect.origin.y, self.trackingArea.rect.size.width, self.trackingArea.rect.size.height);
    [self addTrackingArea:self.trackingArea];
    
}

- (void)viewDidEndLiveResize {
    
    [super viewDidEndLiveResize];
    [self updateTrackingAreas];

}



#pragma mark Mouse Events

- (void)mouseMoved:(NSEvent*)theEvent
{
    NSView *superView = [[self superview] superview];
    NSPoint point = [superView convertPoint:[theEvent locationInWindow] fromView:nil];
    NSRect rect = superView.frame;
//    NSLog(@"point: %f:%f",point.x,point.y);

    if (NSPointInRect(point, rect)) {

		self.hoverRow = [self rowAtPoint:[self convertPoint:[theEvent locationInWindow] fromView:nil]];
        // NSLog(@"hover row: %li",(long)self.hoverRow);
		
		if (self.prevRow == self.hoverRow) {
			return;
        } else {
            if (self.prevRow != -1) {
                [self reloadActionButtonsOnHoverRow:self.prevRow];
            }
            if (self.hoverRow != -1) {
                [self reloadActionButtonsOnHoverRow:self.hoverRow];
            }
			self.prevRow = self.hoverRow;
		}
        
    } else if (self.prevRow != -1) {
        
        [self mouseExited:nil];
        
    }
    
}

- (void)mouseExited:(NSEvent *)theEvent {
    
	self.hoverRow = -1;
    [self reloadActionButtonsOnHoverRow:self.prevRow];
	self.prevRow = -1;
}

- (void)reloadActionButtonsOnHoverRow:(NSInteger)row {
    
    NSMutableIndexSet *columnsSet = [[NSMutableIndexSet alloc] init];
    [columnsSet addIndex:[self columnWithIdentifier:@"Actions"]];
    [columnsSet addIndex:[self columnWithIdentifier:@"Kbps"]];
    [columnsSet addIndex:[self columnWithIdentifier:@"Size"]];

    [self reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:row]
                                       columnIndexes:columnsSet];
}



@end
