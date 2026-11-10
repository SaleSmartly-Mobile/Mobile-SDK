Pod::Spec.new do |s|
  s.name                  = 'SalesmartlyChat'
  s.version               = '1.0.7'
  s.summary               = 'SaleSmartly Chat iOS SDK.'
  s.homepage              = 'https://github.com/SaleSmartly-Mobile/Mobile-SDK'
  s.license               = { :type => 'Proprietary' }
  s.author                = 'SaleSmartly'
  s.source                = {
    :http => 'https://raw.githubusercontent.com/SaleSmartly-Mobile/Mobile-SDK/b8defdc91e4bdcdc74389c54aefa3dbfc1a84d28/ios/sdk/salesmartly-chat-ios-sdk-v1.0.7.zip',
    :sha256 => 'f90b54184957569d210e2c2e50ad6ee13453dc30cdf3f1e77a2cc5e8e006f968',
  }
  s.vendored_frameworks   = 'SalesmartlyChat.xcframework'
  s.platform              = :ios, '15.0'
  s.ios.deployment_target = '15.0'
end
