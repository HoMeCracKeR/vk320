//
//  LADSlider.m
//  LADSliderExample
//
//  Created by Alexander Lapshin on 04.10.13.
//  Copyright (c) 2014 Lapshin Alexandr Dmitryevich. All rights reserved.
//
//  Modified by Roman Silin on 03.08.14.
//
//  The MIT License (MIT)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.



#import "LADSlider.h"
#import "LADSliderCell.h"

@implementation LADSlider


//  We need to override it to prevent drawing bugs
//  Follow this link to know more about it:
//  http://stackoverflow.com/questions/3985816/custom-nsslidercell
- (void)setNeedsDisplayInRect:(NSRect)invalidRect {
    [super setNeedsDisplayInRect:[self bounds]];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    if( ![self.cell isKindOfClass:[LADSliderCell class]] ) {
        //Set our LADSlider.cell to LADSliderCell
        LADSliderCell *cell = [[LADSliderCell alloc] init];
        [self setCell:cell];
    }
    
}

- (id)initWithKnobImage:(NSImage *)knob {
    self = [super init];
    
    if( self ) {
        [self setCell:[[LADSliderCell alloc] initWithKnobImage:knob]];
        
        //      If the cell is nil we return nil
        return nil == self.cell ? nil : self;
    }
    
    return self;
}

- (id)initWithKnobImage:(NSImage *)knob barFillImage:(NSImage *)barFill
        barLeftAgeImage:(NSImage *)barLeftAge andbarRightAgeImage:(NSImage *)barRightAge {
    self = [super init];
    
    if( self ) {
        [self setCell:[[LADSliderCell alloc] initWithKnobImage:knob barFillImage:barFill
                                               barLeftAgeImage:barLeftAge andbarRightAgeImage:barRightAge]];
        
        //      If the cell is nil we return nil
        return nil == self.cell ? nil : self;
    }
    
    return self;
}

- (id)initWithKnobImage:(NSImage *)knob barFillImage:(NSImage *)barFill
 barFillBeforeKnobImage:(NSImage *)barFillBeforeKnob
        barLeftAgeImage:(NSImage *)barLeftAge barRightAgeImage:(NSImage *)barRightAge {
    self = [super init];
    
    if( self ) {
        [self setCell:[[LADSliderCell alloc] initWithKnobImage:knob barFillImage:barFill
                                        barFillBeforeKnobImage:barFillBeforeKnob
                                               barLeftAgeImage:barLeftAge barRightAgeImage:barRightAge]];
        
        //      If the cell is nil we return nil
        return nil == self.cell ? nil : self;
    }
    
    return self;
}

/*
 Also need to throw on some
 LADSliderCell setters and getters
 */
- (NSImage *)knobImage {
    return ((LADSliderCell *) self.cell).knobImage;
}

- (void)setKnobImage:(NSImage *)image {
    ((LADSliderCell *) self.cell).knobImage = image;
}

- (NSImage *)barFillImage {
    return ((LADSliderCell *) self.cell).barFillImage;
}

- (void)setBarFillImage:(NSImage *)image {
    ((LADSliderCell *) self.cell).barFillImage = image;
}

- (NSImage *)barFillBeforeKnobImage {
    return ((LADSliderCell *) self.cell).barFillBeforeKnobImage;
}

- (void)setBarFillBeforeKnobImage:(NSImage *)image {
    ((LADSliderCell *) self.cell).barFillBeforeKnobImage = image;
}

- (NSImage *)barLeftAgeImage {
    return ((LADSliderCell *) self.cell).barLeftAgeImage;
}

- (void)setBarLeftAgeImage:(NSImage *)image {
    ((LADSliderCell *) self.cell).barLeftAgeImage = image;
}

- (NSImage *)barRightAgeImage {
    return ((LADSliderCell *) self.cell).barRightAgeImage;
}

- (void)setBarRightAgeImage:(NSImage *)image {
    ((LADSliderCell *) self.cell).barRightAgeImage = image;
}

//----


- (NSImage *)barFillNotCachedImage {
    return ((LADSliderCell *) self.cell).barFillNotCachedImage;
}

- (void)setBarFillNotCachedImage:(NSImage *)image {
    ((LADSliderCell *) self.cell).barFillNotCachedImage = image;
}

- (NSImage *)barRightAgeNotCachedImage {
    return ((LADSliderCell *) self.cell).barRightAgeNotCachedImage;
}

- (void)setBarRightAgeNotCachedImage:(NSImage *)image {
    ((LADSliderCell *) self.cell).barRightAgeNotCachedImage = image;
}

- (BOOL)caching {
    return ((LADSliderCell *) self.cell).caching;
}

- (void)setCaching:(BOOL)caching {
    ((LADSliderCell *) self.cell).caching = caching;
}

- (float)cacheProgress {
    return ((LADSliderCell *) self.cell).cacheProgress;
}

- (void)setCacheProgress:(float)cacheProgress {
    ((LADSliderCell *) self.cell).cacheProgress = cacheProgress;
    [self setNeedsDisplay:YES];
}

@end
