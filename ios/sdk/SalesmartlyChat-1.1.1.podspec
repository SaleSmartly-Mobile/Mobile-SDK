Pod::Spec.new do |s|
  s.name                  = 'SalesmartlyChat'
  s.version               = '1.1.1'
  s.summary               = 'SaleSmartly Chat iOS SDK.'
  s.homepage              = 'https://github.com/SaleSmartly-Mobile/Mobile-SDK'
  s.license               = { :type => 'Proprietary' }
  s.author                = 'SaleSmartly'
  s.source                = {
    :http => 'https://raw.githubusercontent.com/SaleSmartly-Mobile/Mobile-SDK/130179239110d014a5e446acffdcc051efa56f52/ios/sdk/salesmartly-chat-ios-sdk-v1.1.1.zip',
    :sha256 => '5f076f7313bef6db2363e401bbe5ced0da28b87739e4b985021350c9da51303b',
  }
  s.vendored_frameworks   = 'SalesmartlyChat.xcframework'
  s.platform              = :ios, '15.0'
  s.ios.deployment_target = '15.0'
end
