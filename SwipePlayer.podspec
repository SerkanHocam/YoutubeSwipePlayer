Pod::Spec.new do |s|

  s.name         = "SwipePlayer"
  s.version      = "1.0.0"
  s.summary      = "This framework provide a player view seems youtube player."

  s.homepage     = "https://serkanhocam.com/"
  s.license      = "Serkan Kayaduman"
  s.author       = { "Serkan Kayaduman"=>"serkankayaduman@hotmail.com"}
  s.platform     = :ios
  s.swift_version = "5.0"
  s.ios.deployment_target = "16.2"
  s.source       = { :git => "https://github.com/SerkanHocam/YoutubeSwipePlayer.git", :tag => s.version }
  s.source_files = "SwipePlayer/**/*.{h,swift,xib}"

end