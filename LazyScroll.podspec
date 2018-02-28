Pod::Spec.new do |s|

  s.name         = "LazyScroll"
  s.version      = "1.0.0"
  s.summary      = "A ScrollView to resolve the problem of reusability of views."                 
  s.homepage     = "https://github.com/alibaba/LazyScrollView"
  s.license      = { :type => 'MIT' }
  s.author       = { "fydx"       => "lbgg918@gmail.com",
                     "HarrisonXi" => "gpra8764@gmail.com" }
  s.platform     = :ios
  s.ios.deployment_target = "7.0"
  s.source       = { :git => "https://github.com/alibaba/LazyScrollView.git", :tag => "1.0.0" }
  s.source_files = "LazyScrollView/*.{h,m}"
  s.requires_arc = true

  s.dependency 'TMUtils', '~> 1.0.0'

end
