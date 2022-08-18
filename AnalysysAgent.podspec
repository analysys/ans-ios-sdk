Pod::Spec.new do |s|
  s.name         = "AnalysysAgent"
  s.version      = "4.5.20"
  s.summary      = "易观 iOS PaaS 版本SDK，集成方法参考相关版本SDK集成文档。"
  s.homepage     = "https://github.com/AnalysysSDK/Analysys_SDK_iOS"
  s.social_media_url = "https://ark.analysys.cn/"
  s.source       = { :git => 'https://github.com/AnalysysSDK/Analysys_SDK_iOS.git', :tag => s.version }
  s.license      = "MIT"
  s.author       = { "analysys" => "analysys@analysys.com.cn" }
  s.platform     = :ios, "9.0"

  s.frameworks   = 'UIKit', 'Foundation', 'SystemConfiguration', 'CoreTelephony', 'AdSupport', 'WebKit'
  s.libraries    = 'z', 'sqlite3', 'icucore'
  s.xcconfig     = { "EXCLUDED_ARCHS[sdk=iphonesimulator*]" => "arm64"}
  
  s.subspec 'Agent' do |sp|
    sp.ios.vendored_frameworks = 'AnalysysSDK/AnalysysAgent.framework'
    sp.resource = 'AnalysysSDK/Resources/AnalysysAgent.bundle'
  end
  
  s.subspec 'Encrypt' do |sp|
    sp.ios.vendored_frameworks = 'AnalysysSDK/AnalysysEncrypt.framework'
    sp.dependency 'AnalysysAgent/Agent'
  end
  
  s.subspec 'Push' do |sp|
    sp.ios.vendored_frameworks = 'AnalysysSDK/AnalysysPush.framework'
    sp.dependency 'AnalysysAgent/Agent'
  end
  
  s.subspec 'Visual' do |sp|
    sp.ios.vendored_frameworks = 'AnalysysSDK/AnalysysVisual.framework'
    sp.dependency 'AnalysysAgent/Agent'
  end
  
  #s.default_subspec = 'Agent'


end

 

