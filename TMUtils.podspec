Pod::Spec.new do |s|

  s.name         = "TMUtils"
  s.version      = "1.0.0"
  s.summary      = "Common safe methods & utils for NSArray & NSDictionary."
  s.homepage     = "https://github.com/alibaba/LazyScrollView"
  s.license      = {:type => 'MIT'}
  s.author       = { "HarrisonXi" => "gpra8764@gmail.com" }
  s.platform     = :ios
  s.ios.deployment_target = "5.0"
  s.source       = { :git => "https://github.com/alibaba/LazyScrollView.git", :tag => "1.0.0" }
  s.source_files = "TMUtils/*.{h,m}"
  s.requires_arc = true

end
