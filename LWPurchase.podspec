#
# Be sure to run `pod lib lint LWPurchase.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'LWPurchase'
  s.version          = '1.0.0'
  s.summary          = 'LWPurchase，App非消耗型内购组件，一行代码实现对内购集成。'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
LWPurchase，App非消耗型内购组件，一行代码实现对内购集成。
                       DESC

  s.homepage         = 'https://github.com/luowei/LWPurchase'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'luowei' => 'luowei@wodedata.com' }
  s.source           = { :git => 'https://github.com/luowei/LWPurchase.git'}
  # s.source           = { :git => 'https://gitlab.com/ioslibraries1/liblwpurchase.git' }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'LWPurchase/Classes/**/*'
  
  s.resource_bundles = {
      'LWPurchase' => ['LWPurchase/Assets/**/*']
  #   'LWPurchase' => ['LWPurchase/Assets/*.png']
  }

  s.public_header_files = 'LWPurchase/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'

  s.dependency 'FCAlertView'
  s.dependency 'Masonry'
  s.dependency 'Reachability'
  s.dependency 'LWHUD'
  # s.dependency 'LWSDWebImage'


end
