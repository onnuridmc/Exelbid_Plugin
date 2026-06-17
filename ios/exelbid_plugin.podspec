#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint exelbid_plugin.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'exelbid_plugin'
  s.version          = '2.0.4'
  s.summary          = 'Flutter plugin wrapping the ExelBid iOS/Android SDKs.'
  s.description      = <<-DESC
Flutter plugin that exposes the ExelBid native SDK ad surfaces (banner, native, video, interstitial, mediation) to Dart code.
                       DESC
  s.homepage         = 'https://github.com/onnuridmc/Exelbid_Plugin'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'ExelBid' => 'support@exelbid.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'exelbid_plugin/Sources/exelbid_plugin/**/*.swift'
  s.platform         = :ios, '13.0'
  s.swift_version    = '5.9'

  s.dependency 'Flutter'

  # ExelBidSDK distribution — pulled from the remote CocoaPods spec
  # (prebuilt XCFramework). Mirrors the SwiftPM dependency in
  # `ios/exelbid_plugin/Package.swift`. 3.0.4 is the floor that exposes
  # `nativeCallToActionButton()` (the CTA slot this plugin renders) and
  # matches the mediation adapter's core SDK floor.
  #
  # NOTE on dual declaration — Flutter's plugin integration picks ONE
  # path per plugin based on the host's mode: SwiftPM-enabled hosts use
  # Package.swift and this podspec dependency is never evaluated;
  # SwiftPM-disabled hosts use this podspec and Package.swift is ignored.
  # The dual declaration does NOT, by itself, embed ExelBidSDK twice.
  # Duplication ("Multiple commands produce ExelBidSDK.framework") occurs
  # only when the HOST mixes paths — e.g. directly adding
  # `pod 'ExelBid_iOS_Swift'` while SwiftPM is also active, leaving stale
  # `Pods/`/`Podfile.lock` after switching modes, or adding the mediation
  # adapter via SwiftPM while the plugin runs in CocoaPods mode (or vice
  # versa). See the iOS troubleshooting section in README.md for recovery.
  s.dependency 'ExelBid_iOS_Swift', '>= 3.0.4', '< 4.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386'
  }
end
