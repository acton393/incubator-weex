# coding: utf-8
Pod::Spec.new do |s|

  s.name         = "WeexSDK"

  s.version      = "0.18.0"

  s.summary      = "WeexSDK Source ."

  s.description  = <<-DESC
                   A framework for building Mobile cross-platform UI
                   DESC

  s.homepage     = "https://github.com/apache/incubator-weex.git"
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
  s.source   = { :path=>'./' }
  s.resources = 'pre-build/*.js','ios/sdk/WeexSDK/Resources/wx_load_error@3x.png'
  s.user_target_xcconfig  = {
    'FRAMEWORK_SEARCH_PATHS' => "'$(PODS_ROOT)/WeexSDK'",
    # 'OTHER_LDFLAGS'  => '$(inherited) -undefined dynamic_lookup' 
  }
  s.requires_arc = true

#  s.xcconfig = { "GCC_PREPROCESSOR_DEFINITIONS" => '$(inherited) DEBUG=1' }

  s.xcconfig = { "OTHER_LINK_FLAG" => '$(inherited) -ObjC'}

  s.frameworks = 'CoreMedia','JavaScriptCore', 'QuartzCore', 'CoreGraphics'
  s.libraries = "stdc++"
  s.source_files = ''

  ## core including layout, component and module manager, js-native brige and model
  s.subspec 'Core' do |ss|
    ss.source_files = 'ios/sdk/WeexSDK/Sources/{Bridge,Controller,Debug,Display,Engine,Events,Layout,Loader,Manager,Model,Monitor,Network,Protocol,Utility,View}/*.{h,m,mm,c,cpp}'
    ss.public_header_files = 'ios/sdk/WeexSDK/Sources/Layout/*.h',
                             ''
  end

  s.subspec 'All' do |ss|
    ss.source_files = 'ios/sdk/WeexSDK/Sources/**/*.{h,m,mm,c,cpp}'
    ss.frameworks = 'CoreMedia','MediaPlayer','AVFoundation','AVKit','JavaScriptCore', 'GLKit', 'OpenGLES', 'CoreText', 'QuartzCore', 'CoreGraphics'
  end

  ## components
  s.subspec 'RecycleList' do |ss|
    ss.source_files = 'ios/sdk/WeexSDK/Sources/Component/RecycleList/*.{h,mm,m}'
    ss.dependency 'WeexSDK/Core'
    ss.dependency 'WeexSDK/ScrollerComponent'
  end
  s.subspec 'InputComponent' do |ss|
    ss.source_files = 'ios/sdk/WeexSDK/Sources/Component/input/*.{h,mm,m}'
    ss.dependency 'WeexSDK/Core'
  end
  s.subspec 'Waterfall' do |ss|
    ss.source_files = 'ios/sdk/WeexSDK/Sources/Component/recycler/*.{h,mm,m}'
    ss.dependency 'WeexSDK/Cell'
    ss.dependency 'WeexSDK/Footer'
    ss.dependency 'WeexSDK/Header'
  end

  s.subspec 'ScrollerComponent' do |ss|
    ss.source_files = 'ios/sdk/WeexSDK/Sources/Component/scroller/*.{h,m,mm}'
    ss.dependency 'WeexSDK/Core'
    ss.dependency 'WeexSDK/Refresh'
    ss.dependency 'WeexSDK/Loading'
  end

  s.subspec 'Loading' do |ss|
    ss.source_files = 'ios/sdk/WeexSDK/Sources/Component/loading/*.{h,m,mm}'
    ss.dependency 'WeexSDK/Indicator'
  end

  s.subspec 'SliderNeighbor' do |ss|
    ss.source_files = 'ios/sdk/WeexSDK/Sources/Component/sliderNeighbor/*.{mm,m,h}'
    ss.dependency 'WeexSDK/Core'
  end
  s.subspec 'Refresh' do |ss|
    ss.source_files = 'ios/sdk/WeexSDK/Sources/Component/refresh/*.{mm,m,h}'
    ss.dependency 'WeexSDK/Indicator'
  end

  s.subspec 'Embed' do |ss|
    ss.source_files = 'ios/sdk/WeexSDK/Sources/Component/embed/*.{mm,m,h}'
    ss.dependency 'WeexSDK/Core'
  end

  s.subspec 'Video' do |ss|
    ss.source_files = 'ios/sdk/WeexSDK/Sources/Component/video/*.{mm,m,h}'
    ss.frameworks = 'MediaPlayer','AVFoundation','AVKit'
    ss.dependency 'WeexSDK/Core'
  end

  s.subspec 'Div' do |ss|
    ss.source_files = 'ios/sdk/WeexSDK/Sources/Component/div/*.{mm,m,h}'
    ss.dependency 'WeexSDK/Core'
  end
  
  s.subspec 'Image' do |ss|
    ss.source_files = 'ios/sdk/WeexSDK/Sources/Component/image/*.{mm,m,h}'
    ss.dependency 'WeexSDK/Core'
  end

  s.subspec 'Text' do |ss|
    ss.source_files = 'ios/sdk/WeexSDK/Sources/Component/text/*.{mm,m,h}'
    ss.frameworks = 'CoreText'
    ss.dependency 'WeexSDK/Core'
  end
  s.subspec 'Slider' do |ss|
    ss.source_files = 'ios/sdk/WeexSDK/Sources/Component/slider/*.{mm,m,h}'
    ss.dependency 'WeexSDK/Core'
  end
  s.subspec 'Cell' do |ss|
    ss.source_files = 'ios/sdk/WeexSDK/Sources/Component/cell/*.{mm,m,h}'
    ss.dependency 'WeexSDK/Core'
  end
  
  s.subspec 'List' do |ss|
    ss.source_files = 'ios/sdk/WeexSDK/Sources/Component/list/*.{mm,m,h}'
    ss.dependency 'WeexSDK/ScrollerComponent'
    ss.dependency 'WeexSDK/Cell'
    ss.dependency 'WeexSDK/Header'
    ss.dependency 'WeexSDK/Footer'
  end

  s.subspec 'Indicator' do |ss|
    ss.source_files = 'ios/sdk/WeexSDK/Sources/Component/indicator/*.{mm,m,h}'
    ss.dependency 'WeexSDK/Core'
  end

  s.subspec 'WebComponent' do |ss|
    ss.source_files = 'ios/sdk/WeexSDK/Sources/Component/web/*.{mm,m,h}'
    ss.dependency 'WeexSDK/Core'
  end
  s.subspec 'switch' do |ss|
    ss.source_files = 'ios/sdk/WeexSDK/Sources/Component/switch/*.{mm,m,h}'
    ss.dependency 'WeexSDK/Core'
  end

  s.subspec 'AComponent' do |ss|
    ss.source_files = 'ios/sdk/WeexSDK/Sources/Component/AComponent/*.{mm,m,h}'
    ss.dependency 'WeexSDK/Core'
  end
  s.subspec 'CanvasComponent' do |ss|
    ss.source_files = 'ios/sdk/WeexSDK/Sources/Component/canvas/*.{mm,m,h}'
    ss.frameworks = 'GLKit', 'OpenGLES'
    ss.dependency 'WeexSDK/Core'
  end
  s.subspec 'Header' do |ss|
    ss.source_files = 'ios/sdk/WeexSDK/Sources/Component/header/*.{mm,m,h}'
    ss.dependency 'WeexSDK/Core'
  end
  s.subspec 'Footer' do |ss|
    ss.source_files = 'ios/sdk/WeexSDK/Sources/Component/footer/*.{mm,m,h}'
    ss.dependency 'WeexSDK/Core'
  end

  ## default handlers
  s.subspec 'DefaultHandler' do |ss|
    ss.source_files = 'ios/sdk/WeexSDK/Sources/defaultHandler/*.{mm,m,h}'
    ss.dependency 'WeexSDK/Core'
  end

  ## modules
  s.subspec 'Locale' do |ss|
    ss.source_files = 'ios/sdk/WeexSDK/Sources/Module/locale/*.{mm,m,h}'
    ss.dependency 'WeexSDK/Core'
  end
  s.subspec 'VoiceOver' do |ss|
    ss.source_files = 'ios/sdk/WeexSDK/Sources/Module/voiceOver/*.{mm,m,h}'
    ss.dependency 'WeexSDK/Core'
  end
  s.subspec 'Websocket' do |ss|
    ss.source_files = 'ios/sdk/WeexSDK/Sources/Module/websocket/*.{mm,m,h}'
    ss.dependency 'WeexSDK/Core'
  end
  s.subspec 'Picker' do |ss|
    ss.source_files = 'ios/sdk/WeexSDK/Sources/Module/picker/*.{mm,m,h}'
    ss.dependency 'WeexSDK/InputComponent'
  end
  s.subspec 'GlobalEvent' do |ss|
    ss.source_files = 'ios/sdk/WeexSDK/Sources/Module/globalEvent/*.{mm,m,h}'
    ss.dependency 'WeexSDK/Core'
  end
  s.subspec 'ClipBoard' do |ss|
    ss.source_files = 'ios/sdk/WeexSDK/Sources/Module/clipBoard/*.{mm,m,h}'
    ss.dependency 'WeexSDK/Core'
  end
  s.subspec 'Navigator' do |ss|
    ss.source_files = 'ios/sdk/WeexSDK/Sources/Module/navigator/*.{mm,m,h}'
    ss.dependency 'WeexSDK/Core'
  end
  s.subspec 'Storage' do |ss|
    ss.source_files = 'ios/sdk/WeexSDK/Sources/Module/storage/*.{mm,m,h}'
    ss.dependency 'WeexSDK/Core'
  end
  s.subspec 'Stream' do |ss|
    ss.source_files = 'ios/sdk/WeexSDK/Sources/Module/stream/*.{mm,m,h}'
    ss.dependency 'WeexSDK/Core'
  end

  s.subspec 'Animation' do |ss|
    ss.source_files = 'ios/sdk/WeexSDK/Sources/Module/animation/*.{mm,m,h}'
    ss.dependency 'WeexSDK/Core'
  end
  s.subspec 'InstanceWrap' do |ss|
    ss.source_files = 'ios/sdk/WeexSDK/Sources/Module/instanceWrap/*.{mm,m,h}'
    ss.dependency 'WeexSDK/Core'
  end
  s.subspec 'Dom' do |ss|
    ss.source_files = 'ios/sdk/WeexSDK/Sources/Module/dom/*.{mm,m,h}'
    ss.dependency  'WeexSDK/Core'
  end
  s.subspec 'Timer' do |ss|
    ss.source_files = 'ios/sdk/WeexSDK/Sources/Module/timer/*.{mm,m,h}'
    ss.dependency 'WeexSDK/Core'
  end
  s.subspec 'Modal' do |ss|
    ss.source_files = 'ios/sdk/WeexSDK/Sources/Module/modal/*.{mm,m,h}'
    ss.dependency 'WeexSDK/Core'
  end
  s.subspec 'webModule' do |ss|
    ss.source_files = 'ios/sdk/WeexSDK/Sources/Module/web/*.{mm,m,h}'
    ss.dependency 'WeexSDK/WebComponent'
    ss.dependency 'WeexSDK/Core'
  end

  s.subspec 'CanvasModule' do |ss|
    ss.source_files = 'ios/sdk/WeexSDK/Sources/Module/canvas/*.{mm,m,h}'
    ss.dependency 'WeexSDK/CanvasComponent'
  end
  s.subspec 'Meta' do |ss|
    ss.source_files = 'ios/sdk/WeexSDK/Sources/Module/meta/*.{mm,m,h}'
    ss.dependency 'WeexSDK/Core'
  end
  s.default_subspec = 'Core'
end
