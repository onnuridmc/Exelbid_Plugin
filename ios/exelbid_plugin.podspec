Pod::Spec.new do |s|
    s.name = 'exelbid_plugin'
    s.version = '1.1.12'
    s.summary = 'A Flutter plugin for using SDK.'
    s.homepage = 'https://exelbid.com'
    s.license = { :type => 'MIT', :file => 'LICENSE' }
    s.author = {
        'Motiv Intelligence' => 'dev@motiv-i.com'
    }
    s.source = { :path => '.' }
    s.source_files     = 'Classes/**/*'
    s.dependency 'Flutter'
    s.dependency 'ExelBid_iOS_Swift'
    s.ios.deployment_target = '12.0'

    s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
    s.swift_version = '5.0'
end