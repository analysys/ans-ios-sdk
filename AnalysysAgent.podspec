Pod::Spec.new do |s|
  s.name         = "AnalysysAgent"
  s.version      = "4.1.0"
  s.summary      = "易观 iOS PaaS 版本SDK，集成方法参考相关版本SDK集成文档。"
  s.homepage     = "https://www.analysys.cn/"
  s.source       = { :git => 'https://github.com/AnalysysSDK/Analysys_SDK_iOS.git', :tag => "v#{s.version}" } 
  s.license      = { :type => "MIT", :file => "LICENSE" } 
  s.author       = { "dushaochong" => "dushaochong@analysys.com.cn" }
  s.platform     = :ios, "7.0"
  s.ios.vendored_frameworks = 'AnalysysSDK/IDFA/*.framework'
  s.frameworks   = 'UIKit', 'Foundation', 'SystemConfiguration', 'CoreTelephony', 'AdSupport'
  s.libraries    = 'z', 'sqlite3', 'icucore'

end
