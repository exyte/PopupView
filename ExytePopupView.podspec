Pod::Spec.new do |s|
  s.name             = "ExytePopupView"
  s.version          = "2.3.2"
  s.summary          = "SwiftUI library for toasts, alerts and popups"

  s.homepage         = 'https://github.com/exyte/PopupView.git'
  s.license          = 'MIT'
  s.author           = { 'Exyte' => 'info@exyte.com' }
  s.source           = { :git => 'https://github.com/exyte/PopupView.git', :tag => s.version.to_s }
  s.social_media_url = 'http://exyte.com'

  s.ios.deployment_target = '14.0'
  s.osx.deployment_target = '11.0'
  s.tvos.deployment_target = '14.0'
  
  s.requires_arc = true
  s.swift_version = "5.2"

  s.source_files = [
     'Source/*.h',
     'Source/*.swift',
     'Source/**/*.swift'
  ]

end