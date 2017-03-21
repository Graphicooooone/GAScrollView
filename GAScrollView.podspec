Pod::Spec.new do |s|
  s.name         = "GAScrollView"
  s.version      = "0.0.1"
  s.summary      = "Based on UICollectionView implementation of infinite wheel control."
  s.homepage     = "https://github.com/graphicOne/GAScrollView.git"
  s.license	  = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "Gra" => "Graphic_one@outlook.com" }
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/graphicOne/GAScrollView.git", :tag => "0.0.1" }
  s.source_files = "GAScrollView/GAScrollView", "GAScrollView/GAScrollView/*.{h,m}"
  s.requires_arc = true
end
