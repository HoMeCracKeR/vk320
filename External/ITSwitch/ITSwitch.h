//
//  ITSwitch.h
//  ITSwitch-Demo
//
//  Created by Ilija Tovilo on 01/02/14.
//  Modified by Roman Silin on 03/08/14.
//
//  Copyright 2014 Ilija Tovilo
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>

/**
 *  ITSwitch is a replica of UISwitch for Mac OS X
 */
@interface ITSwitch : NSControl

/**
 *  @property isOn - Gets or sets the switches state
 */
@property (nonatomic, setter = setOn:) BOOL isOn;

/**
 *  @property tintColor - Gets or sets the switches tint
 */
@property (nonatomic, strong) NSColor *tintColor;

/**
 *  @property enabled - Gets or sets whether the switch is disabled or not
 *                      The Property is inherited from NSControl, which is why we override it's accessors
 */
- (BOOL)isEnabled;
- (void)setEnabled:(BOOL)enabled;


@end
