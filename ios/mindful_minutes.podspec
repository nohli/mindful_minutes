#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
    s.name             = 'mindful_minutes'
    s.version          = '0.0.1'
    s.summary          = 'A Flutter package for saving mindful minutes to Apple Health.'
    s.description      = <<-DESC
  A new Flutter plugin.
                         DESC
    s.homepage         = 'https://github.com/nohli/mindful_minutes'
    s.license          = { :file => '../LICENSE' }
    s.author           = { 'Joachim Nohl' => 'achimsapps@gmail.com' }
    s.source           = { :path => '.' }
    s.source_files = 'Classes/**/*'
    s.public_header_files = 'Classes/**/*.h'
    s.dependency 'Flutter'
    s.swift_version = '5.0'
    s.ios.deployment_target = '12.0'
  end
