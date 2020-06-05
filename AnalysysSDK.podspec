#
# Be sure to run `pod lib lint AnalysysSDK.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'AnalysysSDK'
  s.version          = '4.4.7'
  s.summary          = 'This is the official iOS SDK for Analysys.'
  s.homepage         = 'https://github.com/analysys/ana-ios-sdk'
  s.license          = { :type => 'GPL', :file => 'LICENSE' }
  s.author           = { 'analysys' => 'analysysSDK@analysys.com.cn' }
  s.source           = { :git => 'https://github.com/analysys/ana-ios-sdk.git', :tag => s.version.to_s }
  s.ios.deployment_target = '8.0'
  
  s.frameworks   = 'UIKit', 'Foundation', 'SystemConfiguration', 'CoreTelephony', 'AdSupport'
  s.libraries    = 'z', 'sqlite3', 'icucore'

  s.source_files = 'AnalysysSDK/Classes/**/*'
  
  s.resource_bundles = {
    'AnalysysAgent' => ['AnalysysSDK/Assets/**/*']
  }
      
   s.public_header_files = 'AnalysysSDK/Classes/AnalysysAgent/{AnalysysAgent.h,ANSConst.h,AnalysysAgentConfig.h}'

end
