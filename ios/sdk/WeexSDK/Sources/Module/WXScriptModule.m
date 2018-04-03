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

#import "WXScriptModule.h"
#import "WXConvert.h"
#import "WXSDKEngine.h"
#import "WXResourceLoader.h"
#import "WXResourceRequest.h"
#import "WXResourceResponse.h"
#import "WXSDKManager.h"

@implementation WXScriptModule

WX_EXPORT_METHOD(@selector(importScript:params:))

@synthesize weexInstance;
@synthesize methodOptions;

- (void)importScript:(NSString*)urlString params:(NSDictionary*)params
{
    NSURL * url = [NSURL URLWithString:urlString];
    
    NSArray * callbacks = nil;
    if (methodOptions&& [methodOptions count]) {
        callbacks = methodOptions[@"callback"];
    }
    NSString * successCallbackId = nil;
    NSString * failedCallbackId = nil;
    if (callbacks.count) {
        successCallbackId = callbacks[0];
    }
    if (callbacks.count >= 2) {
         failedCallbackId = callbacks[1];
    }
    if (!url) {
        WXLogError(@"url: %@ cannot be loaded correctly", urlString);
        return;
    }
    __weak typeof(self) weakSelf = self;
    WXResourceRequest * resourceRequest = [WXResourceRequest requestWithURL:url resourceType:WXResourceTypeScriptBundle referrer:nil cachePolicy:NSURLRequestUseProtocolCachePolicy];
    WXResourceLoader * scriptLoader = [[WXResourceLoader alloc] initWithRequest:resourceRequest];
    scriptLoader.onFailed = ^(NSError * error) {
        WXLogError(@"download script from %@ failed due to %@", url.absoluteString, error.description);
        if (failedCallbackId) {
            NSDictionary * params = @{@"ok":@NO,@"errorDesc":error.description};
            [[WXSDKManager bridgeMgr] callBack:weakSelf.weexInstance.instanceId funcId:failedCallbackId params:params keepAlive:NO];
        }
    };
    
    scriptLoader.onFinished = ^(const WXResourceResponse * response, NSData * data) {
        
        NSString *scriptString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if (!scriptString) {
            WXLogError(@"data convert to string failed downloaded from url %@", url.absoluteString);
            return;
        }
        
        JSValue * retValue = [JSValue valueWithUndefinedInContext:weakSelf.weexInstance.instanceJavaScriptContext.javaScriptContext];
        if (@available(iOS 8.0,*)) {
            retValue = [weakSelf.weexInstance.instanceJavaScriptContext executeJavascript:scriptString withSourceURL:url];
        } else {
            [weakSelf.weexInstance.instanceJavaScriptContext executeJavascript:scriptString];
        }
        if (weakSelf.weexInstance.instanceJavaScriptContext.exception) {
            // an exception throws while executing javaScript code
            if (failedCallbackId) {
                [[WXSDKManager bridgeMgr] callBack:weakSelf.weexInstance.instanceId funcId:failedCallbackId params:weakSelf.weexInstance.instanceJavaScriptContext.exception keepAlive:NO];
            }
            return;
        }
        if (successCallbackId) {
            [[WXSDKManager bridgeMgr] callBack:weakSelf.weexInstance.instanceId funcId:successCallbackId params:retValue keepAlive:NO];
        }
    };
    
    [scriptLoader start];
    
    
}
@end
