//
//  LADSlider.h
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



#import <Cocoa/Cocoa.h>

@interface LADSlider : NSSlider

/*
 Return LADSlider with custom knob and standard NSSlider bar
 If the argument is nil
 the method will return nil
 */
- (id)initWithKnobImage:(NSImage *)knob;

/*
 Return LADSlider with custom knob and tack
 isProgressType == NO
 If the one of the followings arguments is nil
 the method will return nil
 */
- (id)initWithKnobImage:(NSImage *)knob barFillImage:(NSImage *)barFill
        barLeftAgeImage:(NSImage *)barLeftAge andbarRightAgeImage:(NSImage *)barRightAge;

/*
 Return LADSlider with custom knob and bar
 isProgressType == YES
 If the one of the followings arguments is nil
 the method will return nil
 */
- (id)initWithKnobImage:(NSImage *)knob barFillImage:(NSImage *)barFill
 barFillBeforeKnobImage:(NSImage *)barFillBeforeKnob
        barLeftAgeImage:(NSImage *)barLeftAge barRightAgeImage:(NSImage *)barRightAge;


/*
 LADSliderCell properties
 you may find the description in
 LADSliderCell.h
 */

- (NSImage *)knobImage;
- (void)setKnobImage:(NSImage *)image;

- (NSImage *)barFillImage;
- (void)setBarFillImage:(NSImage *)image;

- (NSImage *)barFillBeforeKnobImage;
- (void)setBarFillBeforeKnobImage:(NSImage *)image;

- (NSImage *)barLeftAgeImage;
- (void)setBarLeftAgeImage:(NSImage *)image;

- (NSImage *)barRightAgeImage;
- (void)setBarRightAgeImage:(NSImage *)image;

//---

- (NSImage *)barFillNotCachedImage;
- (void)setBarFillNotCachedImage:(NSImage *)image;

- (NSImage *)barRightAgeNotCachedImage;
- (void)setBarRightAgeNotCachedImage:(NSImage *)image;

- (BOOL)caching;
- (void)setCaching:(BOOL)caching;

- (float)cacheProgress;
- (void)setCacheProgress:(float)cacheProgress;

@end
