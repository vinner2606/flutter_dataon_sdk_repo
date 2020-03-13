#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'pwc'
  s.version          = '0.0.1'
  s.summary          = 'Platware client'
  s.description      = <<-DESC
Platware client
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.dependency 'SwiftyRSA', "~> 1.5.0"
  s.dependency 'CryptoSwift', "~> 0.15.0"
  s.dependency 'SwiftKeychainWrapper', "~> 3.0"
  s.ios.deployment_target = '9.0'
end

