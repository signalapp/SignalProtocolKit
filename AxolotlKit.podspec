Pod::Spec.new do |s|
  s.name                  = "AxolotlKit"
  s.version               = "0.9.0"
  s.summary               = "AxolotlKit is a Free implementation of the Axolotl protocol in Objective-C"
  s.homepage              = "https://github.com/WhisperSystems/AxolotlKit"
  s.license               = "GPLv2"
  s.license               = { :type => "GPLv2", :file => "LICENSE" }
  s.author                = { "Frederic Jacobs" => "github@fredericjacobs.com" }
  s.social_media_url      = "http://twitter.com/FredericJacobs"
  s.source                = { :git => "https://github.com/WhisperSystems/AxolotlKit.git", :tag => "#{s.version}" }
  s.source_files          = "AxolotlKit/Classes/**/*.{h,m,swift}", "AxolotlKit/Private/*.{h,m,swift}"
  s.public_header_files   = "AxolotlKit/Classes/**/*.{h}"
  s.prefix_header_file    = "AxolotlKit/SPKPrefix.h"
  s.ios.deployment_target = "9.0"
  s.osx.deployment_target = "10.8"
  s.requires_arc          = true
  
  s.dependency            'Curve25519Kit',   '~> 2.1.0'
  s.dependency            'HKDFKit', '~> 0.0.3'
  s.dependency            'CocoaLumberjack'
  s.dependency            'SwiftProtobuf'
  s.dependency            'SignalCoreKit'

  s.test_spec 'Tests' do |test_spec|
    test_spec.source_files = 'AxolotlKitTests/**/*.{h,m,swift}'
  end
end
