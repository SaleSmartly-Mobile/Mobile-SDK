Pod::Spec.new do |s|
  s.name                  = 'SalesmartlyChat'
  s.version               = '1.1.0'
  s.summary               = 'SaleSmartly Chat iOS SDK.'
  s.homepage              = 'https://github.com/SaleSmartly-Mobile/Mobile-SDK'
  s.license               = { :type => 'Proprietary' }
  s.author                = 'SaleSmartly'
  s.source                = {
    :http => 'https://raw.githubusercontent.com/SaleSmartly-Mobile/Mobile-SDK/cdcb8d3a4aeb8389980398dff84a93e7941a57c2/ios/sdk/salesmartly-chat-ios-sdk-v1.1.0.zip',
    :sha256 => '61bf496924651de279d8c49b449cdd9e319449cf56734464b894fd4674c361ec',
  }
  s.vendored_frameworks   = 'SalesmartlyChat.xcframework'
  s.platform              = :ios, '15.0'
  s.ios.deployment_target = '15.0'
end
