Pod::Spec.new do |s|
  s.name             = 'FanBeat'
  s.version          = '0.1.5'
  s.summary          = 'Link to your partner content in the FanBeat app.'

  s.description      = <<-DESC
The FanBeat SDK enables partner apps to link straight to their content in FanBeat without having to worry about whether the user has already installed the FanBeat app.
                       DESC

  s.homepage         = 'http://www.fanbeat.com'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Tony Sullivan' => 'tony.sullivan@fanbeat.com' }
  s.source           = { :git => 'https://bitbucket.org/ingameapp/fanbeat-ios-sdk', :tag => s.version.to_s }

  s.ios.deployment_target = '7.0'

  s.source_files = 'FanBeat/Classes/**/*'

  s.frameworks = 'UIKit', 'StoreKit'
  s.dependency 'Branch', '~> 0.12'
  s.resources = [ 'FanBeat/Assets/*.xcassets', 'FanBeat/Assets/*.storyboard' ]
end
