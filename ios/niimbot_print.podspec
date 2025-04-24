Pod::Spec.new do |s|
  s.name             = 'niimbot_print'
  s.version          = '0.0.1'
  s.summary          = 'Niimbot Printer Integration'
  s.description      = <<-DESC
A new Flutter plugin project.
                       DESC
  s.homepage         = 'https://zh4dev.github.io/'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Gerzha Dev' => 'gerzhahp@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.static_framework = true
  s.dependency 'Flutter'
  s.platform = :ios, '11.0'
  s.libraries = 'iconv'

  # Resources Setup
  s.frameworks = ["CoreMedia", "AVFoundation", "CoreBluetooth"]
  s.vendored_libraries = [
    'Resources/JCAPI/libJCAPI.a',
    'Resources/JCAPI/libJCLPAPI.a',
    'Resources/JCAPI/libSkiaRenderLibrary.a',

  ]

  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64',
    'OTHER_LDFLAGS' => '-liconv'
  }

end
