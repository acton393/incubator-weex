# coding: utf-8
Pod::Spec.new do |s|

  s.name         = "WeexSDK"

  s.version      = "0.18.0"

  s.summary      = "WeexSDK Source ."

  s.description  = <<-DESC
                   A framework for building Mobile cross-platform UI
                   DESC

  s.homepage     = "https://github.com/apache/incubator-weex"
  s.license = {
    :type => 'Copyright',
    :text => <<-LICENSE
           Alibaba-INC copyright
    LICENSE
  }
  s.authors      = { "cxfeng1"      => "cxfeng1@gmail.com",
                     "boboning"     => "ningli928@163.com",
                     "acton393"     => "zhangxing610321@gmail.com"
                   }
  s.platform     = :ios
  s.ios.deployment_target = '8.0'
  s.source_files = 'ios/sdk/WeexSDK/Sources/**/*.{h,m,mm,c}'
  s.resources = 'pre-build/native-bundle-main.js', 'ios/sdk/WeexSDK/Resources/wx_load_error@3x.png'
  s.private_header_files = 'ios/sdk/WeexSDK/Sources/Component/RecycleList/WXJSASTParser.h'
  s.public_header_files = 'ios/sdk/WeexSDK/Sources/WeexSDK.h',
                          'ios/sdk/WeexSDK/Sources/Debug/WXDebugTool.h',
                          'ios/sdk/WeexSDK/Sources/Loader/WXResourceLoader.h',
                          'ios/sdk/WeexSDK/Sources/Layout/Layout.h',
                          'ios/sdk/WeexSDK/Sources/Layout/WXLayoutDefine.h',
                          'ios/sdk/WeexSDK/Sources/WebSocket/WXWebSocketHandler.h',
                          'ios/sdk/WeexSDK/Sources/Module/WXVoiceOverModule.h',
                          'ios/sdk/WeexSDK/Sources/Module/WXPrerenderManager.h',
                          'ios/sdk/WeexSDK/Sources/Module/WXModalUIModule.h',
                          'ios/sdk/WeexSDK/Sources/Component/WXListComponent.h',
                          'ios/sdk/WeexSDK/Sources/Component/WXScrollerComponent.h',
                          'ios/sdk/WeexSDK/Sources/Component/WXIndicatorComponent.h',
                          'ios/sdk/WeexSDK/Sources/Component/WXAComponent.h',
                          'ios/sdk/WeexSDK/Sources/Controller/WXBaseViewController.h',
                          'ios/sdk/WeexSDK/Sources/Controller/WXRootViewController.h',
                          'ios/sdk/WeexSDK/Sources/View/WXView.h',
                          'ios/sdk/WeexSDK/Sources/View/WXErrorView.h',
                          'ios/sdk/WeexSDK/Sources/Protocol/*.h',
                          'ios/sdk/WeexSDK/Sources/Network/WXResourceRequestHandler.h',
                          'ios/sdk/WeexSDK/Sources/Network/WXResourceRequest.h',
                          'ios/sdk/WeexSDK/Sources/Network/WXResourceResponse.h',
                          'ios/sdk/WeexSDK/Sources/Model/WXSDKInstance.h',
                          'ios/sdk/WeexSDK/Sources/Model/WXJSExceptionInfo.h',
                          'ios/sdk/WeexSDK/Sources/Model/WXComponent.h',
                          'ios/sdk/WeexSDK/Sources/Monitor/WXMonitor.h',
                          'ios/sdk/WeexSDK/Sources/Manager/WXTracingManager.h',
                          'ios/sdk/WeexSDK/Sources/Manager/WXSDKManager.h',
                          'ios/sdk/WeexSDK/Sources/Manager/WXBridgeManager.h',
                          'ios/sdk/WeexSDK/Sources/Manager/WXComponentManager.h',
                          'ios/sdk/WeexSDK/Sources/Engine/WXSDKEngine.h',
                          'ios/sdk/WeexSDK/Sources/Engine/WXSDKError.h',
                          'ios/sdk/WeexSDK/Sources/Utility/WXConvert.h',
                          'ios/sdk/WeexSDK/Sources/Utility/WXUtility.h',
                          'ios/sdk/WeexSDK/Sources/Utility/WXLog.h',
                          'ios/sdk/WeexSDK/Sources/Utility/WXDefine.h',
                          'ios/sdk/WeexSDK/Sources/Utility/WXType.h',
                          'ios/sdk/WeexSDK/Sources/Utility/NSObject+WXSwizzle.h',
                          'ios/sdk/WeexSDK/Sources/Utility/WXAppConfiguration.h'

  s.requires_arc = true
  # s.prefix_header_file = 'ios/sdk/WeexSDK/Sources/Supporting Files/WeexSDK-Prefix.pch'

#  s.xcconfig = { "GCC_PREPROCESSOR_DEFINITIONS" => '$(inherited) DEBUG=1' }

  s.xcconfig = { "OTHER_LINK_FLAG" => '$(inherited) -ObjC'}

  s.frameworks = 'CoreMedia','MediaPlayer','AVFoundation','AVKit','JavaScriptCore', 'GLKit', 'OpenGLES', 'CoreText', 'QuartzCore', 'CoreGraphics'
  s.libraries = 'stdc++'

end