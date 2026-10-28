#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
#
Pod::Spec.new do |s|
  s.name             = 'sdui_engine'
  s.version          = '0.6.1'
  s.summary          = 'Native haptics for the sdui_engine sys_haptic command.'
  s.description      = <<-DESC
Core Haptics taps and continuous patterns for sdui_engine sys_haptic.
                       DESC
  s.homepage         = 'https://github.com/David-Lee-dev/sdui-flutter-engine'
  s.license          = { :file => '../LICENSE' }
  s.author           = 'David-Lee-dev'
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.frameworks = 'CoreHaptics'
  s.platform = :ios, '16.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
