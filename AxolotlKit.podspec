Pod::Spec.new do |s|
  s.name         = "AxolotlKit"
  s.version      = "0.0.2"
  s.summary      = "AxolotlKit is a Free implementation of the Axolotl protocol in Objective-C"
  s.homepage     = "https://github.com/WhisperSystems/AxolotlKit"
  s.license      = "GPLv2"
  s.license      = { :type => "GPLv2", :file => "LICENSE" }
  s.author             = { "Frederic Jacobs" => "github@fredericjacobs.com" }
  s.social_media_url   = "http://twitter.com/FredericJacobs"
  s.source       = { :git => "https://github.com/WhisperSystems/AxolotlKit.git", :tag => "#{s.version}" }
  s.source_files  = "AxolotlKit/Classes/*.{h,m}", "AxolotlKit/Classes/**/*.{h,m}"
  s.public_header_files = "AxolotlKit/Classes/*.{h}", "AxolotlKit/Classes/**/*.{h}"
  s.ios.deployment_target = "6.0"
  s.osx.deployment_target = "10.8"
  s.requires_arc = true
  s.dependency   '25519',   '~> 1.8'
  s.dependency   'HKDFKit', '~> 0.0.3'
  s.dependency   'ProtocolBuffers', '~> 1.9.2'
end
