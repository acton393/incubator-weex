//
//  WXLottieComponent.m
//  WeexDemo
//
//  Created by zifan.zx on 2017/5/31.
//  Copyright © 2017年 taobao. All rights reserved.
//

#import "WXLottieComponent.h"

@interface WXLottieComponent()
@property (nonatomic) NSString *src;
@property (nonatomic) NSDictionary *sourceData;
@property void (^ondownLoadFinished)(NSDictionary * sourceData);
@end

@implementation WXLottieComponent
- (instancetype)initWithRef:(NSString *)ref type:(NSString *)type styles:(NSDictionary *)styles attributes:(NSDictionary *)attributes events:(NSArray *)events weexInstance:(WXSDKInstance *)weexInstance
{
    if (self = [super initWithRef:ref type:type styles:styles attributes:attributes events:events weexInstance:weexInstance]) {
        if (attributes[@"src"]) {
            _src = [WXConvert NSString:attributes[@"src"]];
        }
        
    }
    
    return self;
}

- (UIView *)loadView {
    return [LOTAnimationView animationFromJSON:nil];
}


- (void)updateSourceData:(NSString*)src
{
    id rewrite = [WXSDKEngine handlerForProtocol:@protocol(WXURLRewriteProtocol)];
    NSURL * newURL = [rewrite rewriteURL:src withResourceType:WXResourceTypeLink withInstance:self.weexInstance];
    WXResourceRequest * request = [WXResourceRequest requestWithURL:newURL resourceType:WXResourceTypeImage referrer:@"" cachePolicy:NSURLRequestUseProtocolCachePolicy];
    WXResourceLoader * sourceDataLoader = [[WXResourceLoader alloc]initWithRequest:request];
    __weak typeof(self) weakSelf = self;
    sourceDataLoader.onFinished = ^(const WXResourceResponse * response , NSData * data) {
        NSError * jsonParseError;
//        NSDictionary * parsedDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves|NSJSONReadingAllowFragments error:&jsonParseError];
        if (jsonParseError && weakSelf) {
            
        }
        
    };
    sourceDataLoader.onFailed =  ^(NSError* error) {
        WXLogError(@"download %@ error: %@",error, weakSelf.src);
    };
    
}

@end
