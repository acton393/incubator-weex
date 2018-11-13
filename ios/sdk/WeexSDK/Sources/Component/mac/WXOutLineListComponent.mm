//
//  WXOutLineListComponent.m
//  WeexSDK MacOS
//
//  Created by zifan.zx on 2018/11/9.
//  Copyright © 2018年 taobao. All rights reserved.
//

#if WEEX_MAC
#import "WXOutLineListComponent.h"
#import "WXDefine.h"
#import "WXComponent+Layout.h"
#import "WXComponent_internal.h"

@interface WXOutLineListComponent()<NSOutlineViewDelegate, NSOutlineViewDataSource> {
    
    // vertical & horizontal
    WXScrollDirection _scrollDirection;
    BOOL _needsPlatformLayout;
}
@end

@implementation WXOutLineListComponent

#pragma mark private component life cycle

- (BOOL)_insertSubcomponent:(WXComponent *)subcomponent atIndex:(NSInteger)index
{
    BOOL inserted = [super _insertSubcomponent:subcomponent atIndex:index];
    
    // If a vertical list is added to a horizontal scroller, we need platform dependent layout
    if (_flexCssNode && [self isKindOfClass:[WXOutLineListComponent class]] &&
        [subcomponent isKindOfClass:[WXOutLineListComponent class]] &&
        subcomponent->_positionType != WXPositionTypeFixed &&
        (((WXOutLineListComponent*)subcomponent)->_scrollDirection == WXScrollDirectionVertical)) {
        if (subcomponent->_flexCssNode) {
            if (subcomponent->_flexCssNode->getFlex() > 0 && !isnan(subcomponent->_flexCssNode->getStyleWidth())) {
                _needsPlatformLayout = YES;
                _flexCssNode->setNeedsPlatformDependentLayout(true);
            }
        }
    }
    
    return inserted;
}

- (instancetype)initWithRef:(NSString *)ref type:(NSString *)type styles:(NSDictionary *)styles attributes:(NSDictionary *)attributes events:(NSArray *)events weexInstance:(WXSDKInstance *)weexInstance
{
    if (self = [super initWithRef:ref type:type styles:styles attributes:attributes events:events weexInstance:weexInstance]) {
        // customization
        
        _scrollDirection = [self scrollDirection:attributes[@"scrollDirection"]];
    }
    return self;
}

- (NSView *)loadView
{
    return [NSOutlineView new];
}

- (void)viewDidLoad
{
    NSOutlineView * outLineView = (NSOutlineView*)self.view;
    outLineView.delegate = self;
    outLineView.dataSource = self;
}

- (void)viewWillUnload
{
    [super viewWillUnload];
}

- (void)dealloc
{
    
}

- (WXScrollDirection)scrollDirection:(NSString*)direction
{
    if ([direction isKindOfClass:[NSString class]]) {
        return [WXConvert WXScrollDirection:direction];
    }
    return WXScrollDirectionVertical;
}

@end
#endif
