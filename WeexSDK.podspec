# coding: utf-8
Pod::Spec.new do |s|

  s.name         = "WeexSDK"

  s.version      = "0.18.0"

  s.summary      = "WeexSDK Source ."

  s.description  = <<-DESC
                   A framework for building Mobile cross-platform UI
                   DESC

  s.homepage     = "https://github.com/alibaba/weex"
  s.license = {
    :type => 'Copyright',
    :text => <<-LICENSE
           Alibaba-INC copyright
    LICENSE
  }
  s.authors      = { "cxfeng1"      => "cxfeng1@gmail.com",
                     "boboning"     => "ningli928@163.com",
                     "yangshengtao" => "yangshengtao1314@163.com",
                     "kfeagle"      => "sunjjbobo@163.com",
                     "acton393"     => "zhangxing610321@gmail.com"
                   }
  s.platform     = :ios
  s.ios.deployment_target = '8.0'
  s.source =  { :path => '.' }
  # s.source_files = 'ios/sdk/WeexSDK/Sources/**/*.{h,m,mm,c,cpp}'
  s.source_files = 'ios/sdk/WeexSDK/Sources/{Bridge,Controller,Debug,Display,Engine,Events,Layout,Loader,Manager,Model,Monitor,Network,Protocol,Utility,View}/*.{h,m,mm,c,cpp}', 'ios/sdk/WeexSDK/Sources/WeexSDK.h'
  s.resources = 'pre-build/*.js','ios/sdk/WeexSDK/Resources/wx_load_error@3x.png'

  s.user_target_xcconfig  = {
    'FRAMEWORK_SEARCH_PATHS' => "'$(PODS_ROOT)/WeexSDK'",
    'OTHER_LDFLAGS'  => '$(inherited) -undefined dynamic_lookup' }
  s.requires_arc = true

#  s.xcconfig = { "GCC_PREPROCESSOR_DEFINITIONS" => '$(inherited) DEBUG=1' }

  s.xcconfig = { "OTHER_LINK_FLAG" => '$(inherited) -ObjC'}

  s.frameworks = 'CoreMedia','MediaPlayer','AVFoundation','AVKit','JavaScriptCore', 'GLKit', 'OpenGLES', 'CoreText', 'QuartzCore', 'CoreGraphics'
  s.libraries = "stdc++"

  # s.subspec 'RecycleList' do |recyclelist|
  #   recyclelist.source_files ='ios/sdk/WeexSDK/Sources/Component/RecycleList/*.{h,mm,m}'
  # end
end
