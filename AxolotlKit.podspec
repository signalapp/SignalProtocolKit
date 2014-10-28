Pod::Spec.new do |s|
  s.name         = "AxolotlKit"
  s.version      = "0.0.1"
  s.summary      = "AxolotlKit is a Free implementation of the Axolotl protocol in Objective-C"
  s.homepage     = "https://github.com/FredericJacobs/AxolotlKit"
  s.license      = "GPLv2"
  s.license      = { :type => "GPLv2", :file => "LICENSE" }
  s.author             = { "Frederic Jacobs" => "github@fredericjacobs.com" }
  s.social_media_url   = "http://twitter.com/FredericJacobs"
  s.source       = { :git => "https://github.com/FredericJacobs/AxolotlKit.git", :tag => "#{s.version}" }
  s.source_files  = "AxolotlKit/Classes/*.{h,m}", "AxolotlKit/Classes/**/*.{h,m}"
  s.public_header_files = "AxolotlKit/Classes/*.{h}", "AxolotlKit/Classes/**/*.{h}"
  s.dependency   '25519',   '~> 1.8'
  s.dependency   'HKDFKit', '~> 0.0.3'
  s.dependency   'ProtocolBuffers', '~> 1.9.2'
end
