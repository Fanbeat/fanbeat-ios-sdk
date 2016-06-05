#
# Be sure to run `pod lib lint fanbeat-ios-sdk.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'fanbeat-ios-sdk'
  s.version          = '0.1.0'
  s.summary          = 'Link to your partner content in the FanBeat app.'

  s.description      = <<-DESC
The FanBeat SDK enables partner apps to link straight to their content in FanBeat without having to worry about whether the user has already installed the FanBeat app.
                       DESC

  s.homepage         = 'http://www.fanbeat.com'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Tony Sullivan' => 'tony.sullivan@fanbeat.com' }
  s.source           = { :git => 'https://bitbucket.org/ingameapp/fanbeat-ios-sdk', :tag => s.version.to_s }
  s.ios.deployment_target = '8.0'

  s.source_files = 'fanbeat-ios-sdk/Classes/**/*'
  
  # s.resource_bundles = {
  #   'fanbeat-ios-sdk' => ['fanbeat-ios-sdk/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
