Pod::Spec.new do |s|
  s.name         = "MWScrubView"
  s.version      = "0.0.1"
  s.summary      = "A UIView subclass allowing a developer to easily configure scrubbing through long lists of items."
  s.homepage     = "https://github.com/gillygize/MWScrubView"
  s.license      = { :type => 'BSD', :file => 'LICENSE' }
  s.authors       = { "Matthew Gillingham" => "gillygize@gmail.com", "Brett Gneiting" => "brett@tokyobits.jp" }
  s.platform     = :ios, '6.0'
  s.source_files = 'MWScrubView/MWScrubView/**/*.{h,m}'
  s.requires_arc = true
  s.frameworks   = 'UIKit', 'QuartzCore'
end
