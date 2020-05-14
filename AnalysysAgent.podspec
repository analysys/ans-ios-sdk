Pod::Spec.new do |s|
  s.name         = "AnalysysAgent"
  s.version      = "4.4.5.1"
  s.summary      = "易观 iOS PaaS 版本SDK，集成方法参考相关版本SDK集成文档。"
  s.homepage     = "https://github.com/AnalysysSDK/Analysys_SDK_iOS/tree/dev"
  s.social_media_url = "https://ark.analysys.cn/"
  s.source       = { :git => 'https://github.com/AnalysysSDK/Analysys_SDK_iOS.git', :tag => s.version }
  s.license      = "MIT"
  s.author       = { "analysys" => "analysys@analysys.com.cn" }
  s.platform     = :ios, "8.0"

  s.frameworks   = 'UIKit', 'Foundation', 'SystemConfiguration', 'CoreTelephony', 'AdSupport'
  s.libraries    = 'z', 'sqlite3', 'icucore'

  s.ios.vendored_frameworks = 'AnalysysSDK/AnalysysAgent.framework','AnalysysSDK/AnalysysEncrypt.framework','AnalysysSDK/AnalysysVisual.framework','AnalysysSDK/AnalysysPush.framework'

  s.resource = 'AnalysysSDK/Resources/AnalysysAgent.bundle'


end
