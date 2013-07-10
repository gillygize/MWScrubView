Pod::Spec.new do |s|
  s.name         = "MWScrubView"
  s.version      = "0.0.1"
  s.summary      = "A UIView subclass allowing a developer to easily configure scrubbing through long lists of items."
  s.homepage     = "https://github.com/gillygize/MWScrubView"
  s.license      = { :type => 'BSD', :file => 'LICENSE' }
  s.author       = { "Matthew Gillingham" => "gillygize@gmail.com" }
  s.platform     = :ios, '6.0'
  s.source_files = 'MWScrubView/MWScrubView/**/*.{h,m}'
  s.requires_arc = true
  s.frameworks   = 'UIKit'
end

Pod::Spec.new do |s|
  s.name         = "MWScrubView"
  s.version      = "0.0.1"
  s.summary      = "A UIView subclass allowing a developer to easily configure scrubbing through long lists of items."
  s.homepage     = "https://github.com/gillygize/MWScrubView"
  s.license      = { :type => 'BSD', :file => 'LICENSE' }
  s.authors       = { "Matthew Gillingham" => "gillygize@gmail.com", "Brett Gneiting" => "brett@tokyobits.jp" }
  s.source       = { :git => "http://EXAMPLE/MWScrubView1.git", :tag => "0.0.1" }


  # If this Pod runs only on iOS or OS X, then specify the platform and
  # the deployment target.
  #
  # s.platform     = :ios, '5.0'

  # ――― MULTI-PLATFORM VALUES ――――――――――――――――――――――――――――――――――――――――――――――――― #

  # If this Pod runs on both platforms, then specify the deployment
  # targets.
  #
  # s.ios.deployment_target = '5.0'
  # s.osx.deployment_target = '10.7'

  # A list of file patterns which select the source files that should be
  # added to the Pods project. If the pattern is a directory then the
  # path will automatically have '*.{h,m,mm,c,cpp}' appended.
  #
  s.source_files = 'Classes', 'Classes/**/*.{h,m}'
  s.exclude_files = 'Classes/Exclude'

  # A list of file patterns which select the header files that should be
  # made available to the application. If the pattern is a directory then the
  # path will automatically have '*.h' appended.
  #
  # If you do not explicitly set the list of public header files,
  # all headers of source_files will be made public.
  #
  # s.public_header_files = 'Classes/**/*.h'

  # A list of resources included with the Pod. These are copied into the
  # target bundle with a build phase script.
  #
  # s.resource  = "icon.png"
  # s.resources = "Resources/*.png"

  # A list of paths to preserve after installing the Pod.
  # CocoaPods cleans by default any file that is not used.
  # Please don't include documentation, example, and test files.
  #
  # s.preserve_paths = "FilesToSave", "MoreFilesToSave"

  # Specify a list of frameworks that the application needs to link
  # against for this Pod to work.
  #
  # s.framework  = 'SomeFramework'
  # s.frameworks = 'SomeFramework', 'AnotherFramework'

  # Specify a list of libraries that the application needs to link
  # against for this Pod to work.
  #
  # s.library   = 'iconv'
  # s.libraries = 'iconv', 'xml2'

  # If this Pod uses ARC, specify it like so.
  #
  s.requires_arc = true

  # If you need to specify any other build settings, add them to the
  # xcconfig hash.
  #
  # s.xcconfig = { 'HEADER_SEARCH_PATHS' => '$(SDKROOT)/usr/include/libxml2' }

  # Finally, specify any Pods that this Pod depends on.
  #
  # s.dependency 'JSONKit', '~> 1.4'
end
