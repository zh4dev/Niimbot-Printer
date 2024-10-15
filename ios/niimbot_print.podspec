#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run pod lib lint niimbot_print.podspec to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'niimbot_print'
  s.version          = '0.0.1'
  s.summary          = 'Niimbot Printer Integration'
  s.description      = <<-DESC
A new flutter plugin project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.static_framework = true
  s.dependency 'Flutter'
  s.platform = :ios, '11.0'

  # Resources Setup
  s.frameworks = ["CoreMedia", "AVFoundation", "CoreBluetooth"]
  s.resources = ['Resources/Source/**/*', 'Resources/JCSDKFont.bundle']
  s.vendored_frameworks = 'Resources/Framework/CocoaAsyncSocket.framework'
  s.vendored_libraries = [
    'Resources/JCAPI/libJCAPI.a',
    'Resources/Source/libbz2.1.0.tbd',
    'Resources/Source/libiconv.2.tbd']
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64' }

end
