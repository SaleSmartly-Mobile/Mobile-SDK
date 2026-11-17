Pod::Spec.new do |s|
  s.name                  = 'SalesmartlyChat'
  s.version               = '1.2.0'
  s.summary               = 'SaleSmartly Chat iOS SDK.'
  s.homepage              = 'https://github.com/SaleSmartly-Mobile/Mobile-SDK'
  s.license               = { :type => 'Proprietary' }
  s.author                = 'SaleSmartly'
  s.source                = {
    :http => 'https://raw.githubusercontent.com/SaleSmartly-Mobile/Mobile-SDK/86d1cf20279209b0feb0e120434870e60a33c367/ios/sdk/salesmartly-chat-ios-sdk-v1.2.0.zip',
    :sha256 => '490ee46e0214298b4bc79f8c742b7392bdb4365994ffe09e0185f464c17f63db',
  }
  s.vendored_frameworks   = 'SalesmartlyChat.xcframework'
  s.platform              = :ios, '15.0'
  s.ios.deployment_target = '15.0'
end
