//
//  LADSliderCell.m
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


#import "LADSliderCell.h"

@interface LADSliderCell () {
    NSRect _currentKnobRect;
    NSRect _barRect;
    
    BOOL _flipped;
}

@end

@implementation LADSliderCell

- (id)init {
    self = [super init];
    
    if( self ) {
        
    }
    
    return self;
}


- (id)initWithKnobImage:(NSImage *)knob {
    if( nil == knob ) {
        return nil;
    }
    
    self = [self init];
    
    if( self ) {
        _knobImage = knob;
    }
    
    return self;
}

- (id)initWithKnobImage:(NSImage *)knob barFillImage:(NSImage *)barFill
        barLeftAgeImage:(NSImage *)barLeftAge andbarRightAgeImage:(NSImage *)barRightAge {
    if( nil == knob && nil == barFill &&
       nil == barLeftAge && nil == barRightAge ) {
        return nil;
    }
    
    self = [self init];
    
    if( self ) {
        _knobImage = knob;
        _barFillImage = barFill;
        _barFillBeforeKnobImage = barFill;
        _barLeftAgeImage = barLeftAge;
        _barRightAgeImage = barRightAge;
        _barFillNotCachedImage = barFill;
        _barRightAgeNotCachedImage = barRightAge;
    }
    
    return self;
}

- (id)initWithKnobImage:(NSImage *)knob barFillImage:(NSImage *)barFill
 barFillBeforeKnobImage:(NSImage *)barFillBeforeKnob
        barLeftAgeImage:(NSImage *)barLeftAge barRightAgeImage:(NSImage *)barRightAge {
    if( nil == knob && nil == barFill &&
       nil == barFillBeforeKnob &&
       nil == barLeftAge && nil == barRightAge ) {
        return nil;
    }
    
    self = [self init];
    
    if( self ) {
        _knobImage = knob;
        _barFillImage = barFill;
        _barFillBeforeKnobImage = barFillBeforeKnob;
        _barLeftAgeImage = barLeftAge;
        _barRightAgeImage = barRightAge;
        _barFillNotCachedImage = barFill;
        _barRightAgeNotCachedImage = barRightAge;
    }
    
    return self;
}

- (NSRect)knobRectFlipped:(BOOL)flipped
{
    NSImage *drawImage = [self knobImage];
    NSRect drawRect = [super knobRectFlipped:flipped];
    drawRect.size = drawImage.size;
    
    if (!self.isVertical) {
        
        NSRect bounds = NSInsetRect(self.controlView.bounds, ceil(drawRect.size.width / 2), 0);
        CGFloat val = MIN(self.maxValue, MAX(self.minValue, self.doubleValue));
        val = (val - self.minValue) / (self.maxValue - self.minValue);
        CGFloat x = val * NSWidth(bounds) + NSMinX(bounds);
        drawRect = NSOffsetRect(drawRect, x - NSMidX(drawRect) + 1, 0);
        
    } else {
        
        NSRect bounds = NSInsetRect(self.controlView.bounds, ceil(drawRect.size.height / 2), 0);
        CGFloat val = MIN(self.maxValue, MAX(self.minValue, self.doubleValue));
        val = (val - self.minValue) / (self.maxValue - self.minValue);
        CGFloat y = val * NSHeight(bounds) + NSMinY(bounds);
        drawRect = NSOffsetRect(drawRect, y - NSMidY(drawRect) + 1, 0);
        
    }
    
    return drawRect;
}

- (void)drawKnob:(NSRect)knobRect {
    
    //  If don't have the knobImage
    //  just call the super method
    if( nil == _knobImage ) {
        [super drawKnob:knobRect];
        return;
    }
    
    // Чтобы вертикальный слайдер понимал - кто он черт возьми такой
    if (self.isVertical) {
        knobRect.origin.y = (self.controlView.bounds.size.height-knobRect.size.height) -
        (self.controlView.bounds.size.height-knobRect.size.height-_barLeftAgeImage.size.height-_barRightAgeImage.size.height)*(self.doubleValue/self.maxValue);
    }
    
    //  We need to save the knobRect to redraw the bar correctly
    _currentKnobRect = knobRect;
    
    //---------------------Interesting-bug----------------------
    //  Sometimes slider may have some bugs when you
    //  just click on it and hold the mouse down.
    //  To prevent this I call this method once again
    //  right here.
    //  !!!- If you know other way how to prevent it
    //  please tell me about it -!!!
    [self drawBarInside:_barRect flipped:_flipped];
    //---------------------Interesting-bug----------------------
    
    // [self.controlView lockFocus];
    //  Закомментил, иначе возникают проблемы с Ctrl+W
    
    //  We crete this to make a right proportion for the knob rect
    //  For example you knobImage width is longer then allowable
    //  this line will position you knob normally inside the slider
    
    if (!self.isVertical) {

        CGFloat newOriginX = knobRect.origin.x - knobRect.size.width * (self.doubleValue/self.maxValue);
        [_knobImage drawAtPoint:NSMakePoint(newOriginX, 7)
                       fromRect:CGRectZero
                      operation:NSCompositeSourceOver
                       fraction:1.0];
        
    } else {

        CGFloat newOriginY =  knobRect.origin.y - knobRect.size.height * (self.doubleValue/self.maxValue) - knobRect.size.height * (self.doubleValue/self.maxValue);
        [_knobImage drawAtPoint:NSMakePoint(7, newOriginY)
                       fromRect:CGRectZero
                      operation:NSCompositeSourceOver
                       fraction:1.0];
        
    }
    
//    [self.controlView unlockFocus];
//    Закомментил, иначе возникают проблемы с Ctrl+W
    
}

- (void)drawBarInside:(NSRect)cellFrame flipped:(BOOL)flipped {
    //  If don't have any of the bar images
    //  just call the super method
    if( nil == _knobImage && nil == _barFillImage &&
       nil == _barFillBeforeKnobImage &&
       nil == _barLeftAgeImage && nil == _barRightAgeImage ) {
        [super drawBarInside:cellFrame flipped:flipped];
        return;
    }
    
    //---------------------Interesting-bug----------------------
    //   Again we save this to prevent the same bug
    //   I've wrote inside the drawKnob: method
    _barRect = cellFrame;
    _flipped = flipped;
    //---------------------Interesting-bug----------------------
    
    NSRect beforeKnobRect = [self createBeforeKnobRect];
    NSRect afterKnobRect = [self createAfterKnobRect];
    
    //  Sometimes you can see the ages off you bar
    //  even if your knob is at the end or
    //  at the beginning of it. It's about one pixel
    //  but this help to hide that edges
    if (self.minValue != self.doubleValue) {
        if (!self.isVertical) {
            NSDrawThreePartImage(beforeKnobRect, _barLeftAgeImage, _barFillBeforeKnobImage, _barFillBeforeKnobImage, NO, NSCompositeSourceOver, 1.0, flipped);
        } else {
            NSDrawThreePartImage(afterKnobRect, _barFillImage, _barFillImage, _barRightAgeImage,
                                 YES, NSCompositeSourceOver, 1.0, flipped);
        }
    }
    
    // Если слайдер на в конечном значении
    if (self.maxValue != self.doubleValue) {
        
        // Если слайдер горизонтальный
        if (!self.isVertical) {
            
            // Если слайдер должен отображать прогресс кеширования
            if (self.caching) {
                
                float cacheSliderPart = self.cacheProgress - self.doubleValue / self.maxValue;
                NSRect afterKnobRectCached = afterKnobRect;
                afterKnobRectCached.size.width = cellFrame.size.width * cacheSliderPart;
                NSRect afterKnobRectNotCached = afterKnobRect;
                afterKnobRectNotCached.size.width = cellFrame.size.width * (1-cacheSliderPart);
                afterKnobRectNotCached.origin.x += afterKnobRectCached.size.width;
                
                // Если прогресс кеша равен прогрессу трека
                if (self.cacheProgress <= (self.doubleValue/self.maxValue)) {
                    NSDrawThreePartImage(afterKnobRect, _barFillNotCachedImage, _barFillNotCachedImage, _barRightAgeNotCachedImage,
                                         NO, NSCompositeSourceOver, 1.0, flipped);
                    
                // Иначе если трек кеширован
                } else if (self.cacheProgress == 1) {
                    NSDrawThreePartImage(afterKnobRect, _barFillImage, _barFillImage, _barRightAgeImage,
                                         NO, NSCompositeSourceOver, 1.0, flipped);
                    
                // Иначе прогресс кеша между текущей позицией трека и его окончанием
                } else {
                    NSDrawThreePartImage(afterKnobRectCached, _barFillImage, _barFillImage, _barFillImage,
                                         NO, NSCompositeSourceOver, 1.0, flipped);
                    NSDrawThreePartImage(afterKnobRectNotCached, _barFillNotCachedImage, _barFillNotCachedImage, _barRightAgeNotCachedImage,
                                         NO, NSCompositeSourceOver, 1.0, flipped);
                }
                
            // Обычный горизонтальный слайдер без кеширования
            } else {
                
                NSDrawThreePartImage(afterKnobRect, _barFillImage, _barFillImage, _barRightAgeImage,
                                     NO, NSCompositeSourceOver, 1.0, flipped);
            }
            
        // Вертикальный слайдер
        } else {
            NSDrawThreePartImage(beforeKnobRect, _barLeftAgeImage, _barFillBeforeKnobImage, _barFillBeforeKnobImage,YES, NSCompositeSourceOver, 1.0, flipped);
        }
    }
}

- (NSRect)createBeforeKnobRect {
    NSRect beforeKnobRect = _barRect;
    
    if (! self.isVertical) {

        beforeKnobRect.origin.x = 0;
        beforeKnobRect.origin.y = 7;
        beforeKnobRect.size.width = _currentKnobRect.origin.x;
        if (beforeKnobRect.size.width < _barLeftAgeImage.size.width) {
            beforeKnobRect.size.width = _barLeftAgeImage.size.width+_currentKnobRect.size.width;
        }
        beforeKnobRect.size.width -= _currentKnobRect.size.width * (self.doubleValue/self.maxValue);
        beforeKnobRect.size.height = _barFillBeforeKnobImage.size.height;

    } else {
        
        beforeKnobRect.origin.x = 7;
        beforeKnobRect.origin.y = 0;
        beforeKnobRect.size.height = _currentKnobRect.origin.y;
        if (beforeKnobRect.size.height < _barLeftAgeImage.size.height) {
            beforeKnobRect.size.height = _barLeftAgeImage.size.height+_currentKnobRect.size.height;
        }
        beforeKnobRect.size.height -= _currentKnobRect.size.height * (self.doubleValue/self.maxValue);
        beforeKnobRect.size.width = _barFillBeforeKnobImage.size.width;
        
    }
    
    return beforeKnobRect;
}

- (NSRect)createAfterKnobRect {
    NSRect afterKnobRect = _currentKnobRect;
    
    if (!self.isVertical) {
    
        afterKnobRect.origin.x = _currentKnobRect.origin.x + _knobImage.size.width;
        afterKnobRect.origin.x -= _currentKnobRect.size.width * (self.doubleValue/self.maxValue);
        if (afterKnobRect.origin.x > self.controlView.bounds.size.width-_barRightAgeImage.size.width) {
            afterKnobRect.origin.x = self.controlView.bounds.size.width-_barRightAgeImage.size.width+_currentKnobRect.size.width;
        }
        afterKnobRect.origin.y = 7;
        afterKnobRect.size.width = self.controlView.bounds.size.width - afterKnobRect.origin.x;
        afterKnobRect.size.height = _barFillImage.size.height;
    
    } else {
        
        afterKnobRect.origin.y = _currentKnobRect.origin.y + _knobImage.size.height;
        afterKnobRect.origin.y -= _currentKnobRect.size.height * (self.doubleValue/self.maxValue) + _currentKnobRect.size.height;
        if (afterKnobRect.origin.y > self.controlView.bounds.size.height-_barRightAgeImage.size.height) {
            afterKnobRect.origin.y = self.controlView.bounds.size.height-_barRightAgeImage.size.height+_currentKnobRect.size.height;
        }
        afterKnobRect.origin.x = 7;
        afterKnobRect.size.height = self.controlView.bounds.size.height - afterKnobRect.origin.y;
        afterKnobRect.size.width = _barFillImage.size.width;
        
    }
    
    return afterKnobRect;
}

- (void)setBarFillImage:(NSImage *)barFillImage {
    _barFillImage = barFillImage;
    
    if( nil == _barFillBeforeKnobImage ) {
        _barFillBeforeKnobImage = barFillImage;
    }
}

- (void)setBarFillBeforeKnobImage:(NSImage *)barFillBeforeKnobImage {
    _barFillBeforeKnobImage = barFillBeforeKnobImage;
    
    if( nil == _barFillImage ) {
        _barFillImage = barFillBeforeKnobImage;
    }
}


@end
