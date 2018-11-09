//
//  WXOutLineListComponent.m
//  WeexSDK MacOS
//
//  Created by zifan.zx on 2018/11/9.
//  Copyright © 2018年 taobao. All rights reserved.
//

#import "WXOutLineListComponent.h"
#import "WXDefine.h"

@interface WXOutLineListComponent()<NSOutlineViewDelegate, NSOutlineViewDataSource>
@end

@implementation WXOutLineListComponent

- (instancetype)initWithRef:(NSString *)ref type:(NSString *)type styles:(NSDictionary *)styles attributes:(NSDictionary *)attributes events:(NSArray *)events weexInstance:(WXSDKInstance *)weexInstance
{
    if (self = [super initWithRef:ref type:type styles:styles attributes:attributes events:events weexInstance:weexInstance]) {
        
        // customization
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

@end
