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

#import "WXComponent+Layout.h"
#import "WXComponent_internal.h"
#import "WXTransform.h"
#import "WXAssert.h"
#import "WXComponent_internal.h"
#import "WXSDKInstance_private.h"
#import "WXComponent+BoxShadow.h"
#import "Yoga.c"

@implementation WXComponent (Layout)

#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"

#pragma mark Public

- (void)setNeedsLayout
{
    _isLayoutDirty = YES;
    WXComponent *supercomponent = [self supercomponent];
    if(supercomponent){
        [supercomponent setNeedsLayout];
    }
}

- (BOOL)needsLayout
{
    return _isLayoutDirty;
}

- (CGSize (^)(CGSize))measureBlock
{
    return nil;
}

- (void)layoutDidFinish
{
    WXAssertMainThread();
}

#pragma mark Private

- (void)_initCSSNodeWithStyles:(NSDictionary *)styles
{
    _cssNode = YGNodeNew();
    YGNodeSetPrintFunc(_cssNode, cssNodePrint);
//    _cssNode->print = cssNodePrint; // 参数类型不一致，传入更多信息
    
//    _cssNode->get_child = cssNodeGetChild;// 不再需要
//    _cssNode->is_dirty = cssNodeIsDirty;// 待定
    
    if ([self measureBlock]) {
        YGNodeSetMeasureFunc(_cssNode, cssNodeMeasure);
        YGNodeMarkDirty(_cssNode);
//        _cssNode->measure = cssNodeMeasure;
    }
    
    YGNodeSetContext(_cssNode, (__bridge void *)self);
    
//    [self _recomputeCSSNodeChildren]; // no use
    [self _fillCSSNode:styles];
    
    // To be in conformity with Android/Web, hopefully remove this in the future.
    if ([self.ref isEqualToString:WX_SDK_ROOT_REF]) {
        
        if (YGFloatIsUndefined(YGNodeStyleGetHeight(_cssNode).value) && self.weexInstance.frame.size.height) {
            YGNodeStyleSetHeight(_cssNode, self.weexInstance.frame.size.height);
        }
        
        if (YGFloatIsUndefined(YGNodeStyleGetWidth(_cssNode).value) && self.weexInstance.frame.size.width) {
            YGNodeStyleSetWidth(_cssNode, self.weexInstance.frame.size.width);
        }
    }
}

- (void)_updateCSSNodeStyles:(NSDictionary *)styles
{
    [self _fillCSSNode:styles];
}

-(void)_resetCSSNodeStyles:(NSArray *)styles
{
    [self _resetCSSNode:styles];
}

//- (void)_recomputeCSSNodeChildren
//{
////    _cssNode->children_count = (int)[self _childrenCountForLayout];
//}

- (NSUInteger)_childrenCountForLayout
{
    NSArray *subcomponents = _subcomponents;
    NSUInteger count = subcomponents.count;
    for (WXComponent *component in subcomponents) {
        if (!component->_isNeedJoinLayoutSystem) {
            count--;
        }
    }
    return (int)(count);
}

- (void)_frameDidCalculated:(BOOL)isChanged
{
    WXAssertComponentThread();
    
    if ([self isViewLoaded] && isChanged && [self isViewFrameSyncWithCalculated]) {
        
        __weak typeof(self) weakSelf = self;
        [self.weexInstance.componentManager _addUITask:^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (strongSelf->_transform && !CATransform3DEqualToTransform(strongSelf.layer.transform, CATransform3DIdentity)) {
                // From the UIView's frame documentation:
                // https://developer.apple.com/reference/uikit/uiview#//apple_ref/occ/instp/UIView/frame
                // Warning : If the transform property is not the identity transform, the value of this property is undefined and therefore should be ignored.
                // So layer's transform must be reset to CATransform3DIdentity before setFrame, otherwise frame will be incorrect
                strongSelf.layer.transform = CATransform3DIdentity;
            }
            
            if (!CGRectEqualToRect(strongSelf.view.frame,strongSelf.calculatedFrame)) {
                strongSelf.view.frame = strongSelf.calculatedFrame;
                strongSelf->_absolutePosition = CGPointMake(NAN, NAN);
                [strongSelf configBoxShadow:_boxShadow];
            } else {
                if (![strongSelf equalBoxShadow:_boxShadow withBoxShadow:_lastBoxShadow]) {
                    [strongSelf configBoxShadow:_boxShadow];
                }
            }
            
            [self _resetNativeBorderRadius];
            
            if (strongSelf->_transform) {
                [strongSelf->_transform applyTransformForView:strongSelf.view];
            }
            
            if (strongSelf->_backgroundImage) {
                [strongSelf setGradientLayer];
            }
            [strongSelf setNeedsDisplay];
            [strongSelf _configWXComponentA11yWithAttributes:nil];
        }];
    }
}

- (void)_calculateFrameWithSuperAbsolutePosition:(CGPoint)superAbsolutePosition
                           gatherDirtyComponents:(NSMutableSet<WXComponent *> *)dirtyComponents
{
    WXAssertComponentThread();
    
// TODO:generationCount?
//    if (!_cssNode->layout.should_update) {
//        return;
//    }
//    _cssNode->layout.should_update = false;
    _cssNode->isDirty = NO;
    _isLayoutDirty = NO;
    CGRect newFrame = CGRectMake(WXRoundPixelValue(_cssNode->layout.position[YGEdgeLeft]),
                                 WXRoundPixelValue(_cssNode->layout.position[YGEdgeTop]),
                                 WXRoundPixelValue(!isnan(_cssNode->layout.dimensions[YGDimensionWidth])?:0),
                                 WXRoundPixelValue(!isnan(_cssNode->layout.dimensions[YGDimensionHeight])?:0));
    
    BOOL isFrameChanged = NO;
    if (!CGRectEqualToRect(newFrame, _calculatedFrame)) {
        isFrameChanged = YES;
        _calculatedFrame = newFrame;
        [dirtyComponents addObject:self];
    }
    
    CGPoint newAbsolutePosition = [self computeNewAbsolutePosition:superAbsolutePosition];
    
    _cssNode->layout.dimensions[YGDimensionWidth] = YGUndefined;
    _cssNode->layout.dimensions[YGDimensionHeight] = YGUndefined;
    _cssNode->layout.position[YGEdgeLeft] = 0;
    _cssNode->layout.position[YGEdgeTop] = 0;
    
    [self _frameDidCalculated:isFrameChanged];
    
    for (WXComponent *subcomponent in _subcomponents) {
        [subcomponent _calculateFrameWithSuperAbsolutePosition:newAbsolutePosition gatherDirtyComponents:dirtyComponents];
    }
}

- (CGPoint)computeNewAbsolutePosition:(CGPoint)superAbsolutePosition
{
    // Not need absolutePosition any more
    return superAbsolutePosition;
}

- (void)_layoutDidFinish
{
    WXAssertMainThread();
    
    if (_positionType == WXPositionTypeSticky) {
        [self.ancestorScroller adjustSticky];
    }
    [self layoutDidFinish];
}

#define WX_STYLE_FILL_CSS_NODE(key, cssProp, type)\
do {\
    id value = styles[@#key];\
    if (value) {\
        typeof(_cssNode->style.cssProp) convertedValue = (typeof(_cssNode->style.cssProp))[WXConvert type:value];\
        _cssNode->style.cssProp = convertedValue;\
        [self setNeedsLayout];\
    }\
} while(0);

#define WX_STYLE_FILL_CSS_NODE_PIXEL(key, cssProp)\
do {\
    id value = styles[@#key];\
    if (value) {\
        CGFloat pixel = [self WXPixelType:value];\
        if (isnan(pixel)) {\
            WXLogError(@"Invalid NaN value for style:%@, ref:%@", @#key, self.ref);\
        } else {\
            _cssNode->style.cssProp.value = pixel;\
            [self setNeedsLayout];\
        }\
    }\
} while(0);

#define WX_STYLE_FILL_CSS_NODE_ALL_DIRECTION(key, cssProp)\
do {\
    WX_STYLE_FILL_CSS_NODE_PIXEL(key, cssProp[YGEdgeTop])\
    WX_STYLE_FILL_CSS_NODE_PIXEL(key, cssProp[YGEdgeLeft])\
    WX_STYLE_FILL_CSS_NODE_PIXEL(key, cssProp[YGEdgeRight])\
    WX_STYLE_FILL_CSS_NODE_PIXEL(key, cssProp[YGEdgeBottom])\
} while(0);


- (CGFloat)WXPixelType:(id)value
{
    return [WXConvert WXPixelType:value scaleFactor:self.weexInstance.pixelScaleFactor];
}

- (void)_fillCSSNode:(NSDictionary *)styles;
{
    // flex
    WX_STYLE_FILL_CSS_NODE(flex, flex, CGFloat)
    WX_STYLE_FILL_CSS_NODE(flexDirection, flexDirection, YGFlexDirection)
    WX_STYLE_FILL_CSS_NODE(alignItems, alignItems, YGAlign)
    WX_STYLE_FILL_CSS_NODE(alignSelf, alignSelf, YGAlign)
    WX_STYLE_FILL_CSS_NODE(flexWrap, flexWrap, YGWrap)
    WX_STYLE_FILL_CSS_NODE(justifyContent, justifyContent, YGJustify)
    
    // position
    WX_STYLE_FILL_CSS_NODE(position, positionType, YGPositionType)
    WX_STYLE_FILL_CSS_NODE_PIXEL(top, position[YGEdgeTop])
    WX_STYLE_FILL_CSS_NODE_PIXEL(left, position[YGEdgeLeft])
    WX_STYLE_FILL_CSS_NODE_PIXEL(right, position[YGEdgeRight])
    WX_STYLE_FILL_CSS_NODE_PIXEL(bottom, position[YGEdgeBottom])
    
    // dimension
    WX_STYLE_FILL_CSS_NODE_PIXEL(width, dimensions[YGDimensionWidth])
    WX_STYLE_FILL_CSS_NODE_PIXEL(height, dimensions[YGDimensionHeight])
    WX_STYLE_FILL_CSS_NODE_PIXEL(minWidth, minDimensions[YGDimensionWidth])
    WX_STYLE_FILL_CSS_NODE_PIXEL(minHeight, minDimensions[YGDimensionHeight])
    WX_STYLE_FILL_CSS_NODE_PIXEL(maxWidth, maxDimensions[YGDimensionWidth])
    WX_STYLE_FILL_CSS_NODE_PIXEL(maxHeight, maxDimensions[YGDimensionHeight])
    
    // margin
    WX_STYLE_FILL_CSS_NODE_ALL_DIRECTION(margin, margin)
    WX_STYLE_FILL_CSS_NODE_PIXEL(marginTop, margin[YGEdgeTop])
    WX_STYLE_FILL_CSS_NODE_PIXEL(marginLeft, margin[YGEdgeLeft])
    WX_STYLE_FILL_CSS_NODE_PIXEL(marginRight, margin[YGEdgeRight])
    WX_STYLE_FILL_CSS_NODE_PIXEL(marginBottom, margin[YGEdgeBottom])
    
    // border
    WX_STYLE_FILL_CSS_NODE_ALL_DIRECTION(borderWidth, border)
    WX_STYLE_FILL_CSS_NODE_PIXEL(borderTopWidth, border[YGEdgeTop])
    WX_STYLE_FILL_CSS_NODE_PIXEL(borderLeftWidth, border[YGEdgeLeft])
    WX_STYLE_FILL_CSS_NODE_PIXEL(borderRightWidth, border[YGEdgeRight])
    WX_STYLE_FILL_CSS_NODE_PIXEL(borderBottomWidth, border[YGEdgeBottom])
    
    // padding
    WX_STYLE_FILL_CSS_NODE_ALL_DIRECTION(padding, padding)
    WX_STYLE_FILL_CSS_NODE_PIXEL(paddingTop, padding[YGEdgeTop])
    WX_STYLE_FILL_CSS_NODE_PIXEL(paddingLeft, padding[YGEdgeLeft])
    WX_STYLE_FILL_CSS_NODE_PIXEL(paddingRight, padding[YGEdgeRight])
    WX_STYLE_FILL_CSS_NODE_PIXEL(paddingBottom, padding[YGEdgeBottom])
}

#define WX_STYLE_RESET_CSS_NODE(key, cssProp, defaultValue)\
do {\
    if (styles && [styles containsObject:@#key]) {\
        _cssNode->style.cssProp = defaultValue;\
        [self setNeedsLayout];\
    }\
} while(0);

#define WX_STYLE_RESET_CSS_NODE_PIXEL(key, cssProp, defaultValue)\
do {\
    if (styles && [styles containsObject:@#key]) {\
        _cssNode->style.cssProp.value = defaultValue;\
        [self setNeedsLayout];\
    }\
} while(0);

#define WX_STYLE_RESET_CSS_NODE_ALL_DIRECTION(key, cssProp, defaultValue)\
do {\
    WX_STYLE_RESET_CSS_NODE_PIXEL(key, cssProp[YGEdgeTop], defaultValue)\
    WX_STYLE_RESET_CSS_NODE_PIXEL(key, cssProp[YGEdgeLeft], defaultValue)\
    WX_STYLE_RESET_CSS_NODE_PIXEL(key, cssProp[YGEdgeRight], defaultValue)\
    WX_STYLE_RESET_CSS_NODE_PIXEL(key, cssProp[YGEdgeBottom], defaultValue)\
} while(0);

- (void)_resetCSSNode:(NSArray *)styles;
{
    // flex
    WX_STYLE_RESET_CSS_NODE(flex, flex, 0.0)
    WX_STYLE_RESET_CSS_NODE(flexDirection, flexDirection, YGFlexDirectionColumn)
    WX_STYLE_RESET_CSS_NODE(alignItems, alignItems, YGAlignStretch)
    WX_STYLE_RESET_CSS_NODE(alignSelf, alignSelf, YGAlignAuto)
    WX_STYLE_RESET_CSS_NODE(flexWrap, flexWrap, YGWrapNoWrap)
    WX_STYLE_RESET_CSS_NODE(justifyContent, justifyContent, YGJustifyFlexStart)

    // position
    WX_STYLE_RESET_CSS_NODE(position, positionType, YGPositionTypeRelative)
    
    WX_STYLE_RESET_CSS_NODE_PIXEL(top, position[YGEdgeTop], YGUndefined)
    WX_STYLE_RESET_CSS_NODE_PIXEL(left, position[YGEdgeLeft], YGUndefined)
    WX_STYLE_RESET_CSS_NODE_PIXEL(right, position[YGEdgeRight], YGUndefined)
    WX_STYLE_RESET_CSS_NODE_PIXEL(bottom, position[YGEdgeBottom], YGUndefined)
    
    // dimension
    WX_STYLE_RESET_CSS_NODE_PIXEL(width, dimensions[YGDimensionWidth], YGUndefined)
    WX_STYLE_RESET_CSS_NODE_PIXEL(height, dimensions[YGDimensionHeight], YGUndefined)
    
    WX_STYLE_RESET_CSS_NODE_PIXEL(minWidth, minDimensions[YGDimensionWidth], YGUndefined)
    WX_STYLE_RESET_CSS_NODE_PIXEL(minHeight, minDimensions[YGDimensionHeight], YGUndefined)
    WX_STYLE_RESET_CSS_NODE_PIXEL(maxWidth, maxDimensions[YGDimensionWidth], YGUndefined)
    WX_STYLE_RESET_CSS_NODE_PIXEL(maxHeight, maxDimensions[YGDimensionHeight], YGUndefined)
    
    // margin
    WX_STYLE_RESET_CSS_NODE_ALL_DIRECTION(margin, margin, 0.0)
    WX_STYLE_RESET_CSS_NODE_PIXEL(marginTop, margin[YGEdgeTop], 0.0)
    WX_STYLE_RESET_CSS_NODE_PIXEL(marginLeft, margin[YGEdgeLeft], 0.0)
    WX_STYLE_RESET_CSS_NODE_PIXEL(marginRight, margin[YGEdgeRight], 0.0)
    WX_STYLE_RESET_CSS_NODE_PIXEL(marginBottom, margin[YGEdgeBottom], 0.0)
    
    // border
    WX_STYLE_RESET_CSS_NODE_ALL_DIRECTION(borderWidth, border, 0.0)
    WX_STYLE_RESET_CSS_NODE_PIXEL(borderTopWidth, border[YGEdgeTop], 0.0)
    WX_STYLE_RESET_CSS_NODE_PIXEL(borderLeftWidth, border[YGEdgeLeft], 0.0)
    WX_STYLE_RESET_CSS_NODE_PIXEL(borderRightWidth, border[YGEdgeRight], 0.0)
    WX_STYLE_RESET_CSS_NODE_PIXEL(borderBottomWidth, border[YGEdgeBottom], 0.0)
    
    // padding
    WX_STYLE_RESET_CSS_NODE_ALL_DIRECTION(padding, padding, 0.0)
    WX_STYLE_RESET_CSS_NODE_PIXEL(paddingTop, padding[YGEdgeTop], 0.0)
    WX_STYLE_RESET_CSS_NODE_PIXEL(paddingLeft, padding[YGEdgeLeft], 0.0)
    WX_STYLE_RESET_CSS_NODE_PIXEL(paddingRight, padding[YGEdgeRight], 0.0)
    WX_STYLE_RESET_CSS_NODE_PIXEL(paddingBottom, padding[YGEdgeBottom], 0.0)
}

#pragma mark CSS Node Override

static void cssNodePrint(YGNodeRef node)
{
    WXComponent *component = (__bridge WXComponent *)YGNodeGetContext(node);
    // TODO:
    printf("%s:%s ", component.ref.UTF8String, component->_type.UTF8String);
}

//static css_node_t * cssNodeGetChild(void *context, int i)
//{
//    WXComponent *component = (__bridge WXComponent *)context;
//    NSArray *subcomponents = component->_subcomponents;
//    for (int j = 0; j <= i && j < subcomponents.count; j++) {
//        WXComponent *child = subcomponents[j];
//        if (!child->_isNeedJoinLayoutSystem) {
//            i++;
//        }
//    }
//
//    if(i >= 0 && i < subcomponents.count){
//        WXComponent *child = subcomponents[i];
//        return child->_cssNode;
//    }
//
//
//    WXAssert(NO, @"Can not find component:%@'s css node child at index: %ld, totalCount:%ld", component, i, subcomponents.count);
//    return NULL;
//}

//static bool cssNodeIsDirty(void *context)
//{
//    WXAssertComponentThread();
//    
//    WXComponent *component = (__bridge WXComponent *)context;
//    BOOL needsLayout = [component needsLayout];
//    
//    return needsLayout;
//}

static YGSize cssNodeMeasure(YGNodeRef node, float width, YGMeasureMode widthMode, float height, YGMeasureMode heightMode)
{
    WXComponent *component = (__bridge WXComponent *)node->context;
    CGSize (^measureBlock)(CGSize) = [component measureBlock];
    
    if (!measureBlock) {
        return (YGSize){NAN, NAN};
    }
    
    CGSize constrainedSize = CGSizeMake(width, height);
    CGSize resultSize = measureBlock(constrainedSize);
    
    return (YGSize){resultSize.width, resultSize.height};
}

@end
