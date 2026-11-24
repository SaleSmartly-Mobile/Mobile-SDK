Pod::Spec.new do |s|
  s.name                  = 'SalesmartlyChat'
  s.version               = '1.2.0'
  s.summary               = 'SaleSmartly Chat iOS SDK.'
  s.homepage              = 'https://github.com/SaleSmartly-Mobile/Mobile-SDK'
  s.license               = { :type => 'Proprietary' }
  s.author                = 'SaleSmartly'
  s.source                = {
    :http => 'https://raw.githubusercontent.com/SaleSmartly-Mobile/Mobile-SDK/347ccdf6d1bcdb07a9161f250d20340665bce318/ios/sdk/salesmartly-chat-ios-sdk-v1.2.0-send-log-r1.zip',
    :sha256 => '5ce22d20bd5489825e85c1432d4dc27ef620af6b2e13ea5f3173322e24399166',
  }
  s.vendored_frameworks   = 'SalesmartlyChat.xcframework'
  s.platform              = :ios, '15.0'
  s.ios.deployment_target = '15.0'
end
