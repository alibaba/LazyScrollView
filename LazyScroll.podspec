Pod::Spec.new do |s|

  s.name         = "LazyScroll"
  s.version      = "1.0"
  s.summary      = "A ScrollView to resolve the problem of reusability of views."

  s.description  = <<-DESC
  It reply an another way to control reuse in a ScrollView, it depends on give a special reuse identifier to every view controlled in LazyScrollView.
                 DESC
                 
  s.homepage     = "https://github.com/alibaba/LazyScrollView"
  s.license      = { :type => 'MIT' }
  s.author       = { "fydx"       => "lbgg918@gmail.com",
                     "HarrisonXi" => "gpra8764@gmail.com" }
  s.platform     = :ios
  s.ios.deployment_target = "5.0"
  s.source       = { :git => "https://github.com/alibaba/LazyScrollView.git", :tag => "1.0" }
  s.source_files = "LazyScrollView/*.{h,m}"
  s.requires_arc = true

  # s.dependency 'TMUtils', '~> 1.0'

end
