#
#  Be sure to run `pod spec lint DSNavigationBarTransition.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|
  s.name         = "DSNavigationBarTransition"
  s.version      = "1.0.3"
  s.summary      = "Navigation bar transition category."
  s.description  = <<-DESC
    Navigation bar transition category.一个实现导航栏平滑切换的分类，采用分类的模式，对代码没有侵入。
                   DESC

  s.homepage     = "https://github.com/OuDuShu/DSNavigationTransition/blob/master/DSNavigationBarTransition"
  s.screenshots  = "https://github.com/OuDuShu/DSNavigationTransition/blob/master/DSNavigationBarTransition/simulator.gif?raw=true"

  #s.license      = "MIT"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "欧杜书" => "dushu.ou@gmail.com" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/OuDuShu/DSNavigationTransition.git", :tag => "1.0.3" }
  s.source_files = "DSNavigationBarTransition/DSNavigationBarTransition/*"
  #s.source_files  = "DSNavigationTransition/DSNavigationTransition", "DSNavigationTransition/DSNavigationTransition/DSNavigationTransition/*.{h,m}"
end
