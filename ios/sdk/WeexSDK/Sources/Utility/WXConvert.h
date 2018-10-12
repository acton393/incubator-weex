/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 * 
 *   http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */
#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#elif TARGET_OS_MAC
#import <AppKit/AppKit.h>
#endif
#import <objc/runtime.h>
#import "WXLog.h"
#import "WXType.h"

@class WXLength;
@class WXBoxShadow;
@interface WXConvert : NSObject

+ (BOOL)BOOL:(id)value;

/**
 *  @abstract       convert value to CGFloat value
 *  @param value    value
 *  @return         CGFloat value
 */
+ (CGFloat)CGFloat:(id)value;

/**
 *  @abstract       convert value to CGFloat value, notice that it will return nan if input value is unsupported
 *  @param value    value
 *  @return         CGFloat value or nan(unsupported input)
 */
+ (CGFloat)flexCGFloat:(id)value;

+ (NSUInteger)NSUInteger:(id)value;
+ (NSInteger)NSInteger:(id)value;
+ (NSString *)NSString:(id)value;

/**
 *  750px Adaptive
 */
typedef CGFloat WXPixelType;
// @parameter scaleFactor: please use weexInstance's pixelScaleFactor property
+ (WXPixelType)WXPixelType:(id)value scaleFactor:(CGFloat)scaleFactor;
// WXPixelType that use flexCGFloat to convert
+ (WXPixelType)WXFlexPixelType:(id)value scaleFactor:(CGFloat)scaleFactor;

#if TARGET_OS_IPHONE
+ (UIViewContentMode)UIViewContentMode:(id)value;
#endif
+ (WXImageQuality)WXImageQuality:(id)value;
+ (WXImageSharp)WXImageSharp:(id)value;
#if TARGET_OS_IPHONE
+ (UIAccessibilityTraits)WXUIAccessibilityTraits:(id)value;
#endif

#if TARGET_OS_IPHONE
+ (UIColor *)UIColor:(id)value;
#elif TARGET_OS_MAC
+ (NSColor *)NSColor:(id)value;
#endif
+ (CGColorRef)CGColor:(id)value;
#if TARGET_OS_IPHONE
+ (NSString *)HexWithColor:(UIColor *)color;
#elif TARGET_OS_MAC
+ (NSString *)HexWithColor:(NSColor *)color;
#endif
+ (WXBorderStyle)WXBorderStyle:(id)value;
typedef BOOL WXClipType;
+ (WXClipType)WXClipType:(id)value;
+ (WXPositionType)WXPositionType:(id)value;

+ (WXTextStyle)WXTextStyle:(id)value;
/**
 * @abstract UIFontWeightRegular ,UIFontWeightBold,etc are not support by the system which is less than 8.2. weex sdk set the float value.
 *
 * @param value support normal,blod,100,200,300,400,500,600,700,800,900
 *
 * @return A float value.
 *
 */
+ (CGFloat)WXTextWeight:(id)value;
+ (WXTextDecoration)WXTextDecoration:(id)value;
+ (NSTextAlignment)NSTextAlignment:(id)value;
#if TARGET_OS_IPHONE
+ (UIReturnKeyType)UIReturnKeyType:(id)value;
#endif

+ (WXScrollDirection)WXScrollDirection:(id)value;
#if TARGET_OS_IPHONE
+ (UITableViewRowAnimation)UITableViewRowAnimation:(id)value;
+ (UIViewAnimationOptions)UIViewAnimationTimingFunction:(id)value;
#endif
+ (CAMediaTimingFunction *)CAMediaTimingFunction:(id)value;

+ (WXVisibility)WXVisibility:(id)value;

+ (WXGradientType)gradientType:(id)value;

+ (WXLength *)WXLength:(id)value isFloat:(BOOL)isFloat scaleFactor:(CGFloat)scaleFactor;
+ (WXBoxShadow *)WXBoxShadow:(id)value scaleFactor:(CGFloat)scaleFactor;

@end

@interface WXConvert (Deprecated)

+ (WXPixelType)WXPixelType:(id)value DEPRECATED_MSG_ATTRIBUTE("Use [WXConvert WXPixelType:scaleFactor:] instead");

@end
