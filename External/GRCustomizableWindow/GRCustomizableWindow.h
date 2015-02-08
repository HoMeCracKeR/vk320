//
//  GRCustomizableWindow.h
//  GRCustomizableWindow
//
//  Created by Guilherme Rambo on 26/02/14.
//  Copyright (c) 2014 Guilherme Rambo. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  - Redistributions of source code must retain the above copyright notice, this
//  list of conditions and the following disclaimer.
//
//  - Redistributions in binary form must reproduce the above copyright notice,
//  this list of conditions and the following disclaimer in the documentation
//  and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
//  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
//  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
//  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
//  CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
//  OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
//  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import <Cocoa/Cocoa.h>

@interface GRCustomizableWindow : NSWindow

/*!
 @property titlebarHeight
 @abstract Defines the height of the window's titlebar
 */
@property (nonatomic, copy) NSNumber *titlebarHeight;

/*!
 @property titlebarColor
 @abstract Defines the background color of the window's titlebar
 @discussion
 Set the window's titlebar background color, It will be overlaid by a subtle gradient
 */
@property (nonatomic, copy) NSColor *titlebarColor;

/*!
 @property titleColor
 @abstract Defines the color used to draw the window's title
 @discussion
 If left nil, will use a darker version of titlebarColor
 */
@property (nonatomic, copy) NSColor *titleColor;

/*!
 @property titleFont
 @abstract Defines the font used to draw the window's title
 */
@property (nonatomic, copy) NSFont *titleFont;

/*!
 @property centerControls
 @abstract Defines if the window's buttons and title should be centered vertically
 */
@property (nonatomic, assign) BOOL centerControls;

/*!
 @property enableGradients
 @abstract Defines whether the window's title bar and content border should have a gradient added to them
 */
@property (nonatomic, assign) BOOL enableGradients;

@end